// CBPic2kerPhotoLibrary.m
// Copyright (c) 2017 陈超邦.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import <CBPic2ker/CBPic2kerPhotoLibrary.h>
#import <CBPic2ker/CBPic2kerAlbumModel.h>
#import <CBPic2ker/CBPic2kerAssetModel.h>
#import <CBPic2ker/UIImage+CBPic2ker.h>
#import <CBPic2ker/UIImage+CBPic2ker.h>

static CGFloat const kCBPic2kerPhotoLibraryPreviewMaxWidth = 600;

@interface CBPic2kerPhotoLibrary()

@property (nonatomic, assign, readwrite) CGSize gridThumbnailSize;

@end

@implementation CBPic2kerPhotoLibrary

#pragma mark - Public Methods.
+ (instancetype)sharedPhotoLibrary {
    static CBPic2kerPhotoLibrary *photoLibrary;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        photoLibrary = [[CBPic2kerPhotoLibrary alloc] init];
        photoLibrary.columnNumber = 3;
    });
    return photoLibrary;
}

- (void)removeSelectedAssetWithIdentifier:(NSString *)identifier {
    if (!identifier.length) { return; }
    
    if ([self.selectedAssetIdentifierArr containsObject:identifier]) {
        NSInteger index = [self.selectedAssetIdentifierArr indexOfObject:identifier];
        [self.selectedAssetIdentifierArr removeObject:identifier];
        [self.selectedAssetArr removeObjectAtIndex:index];
    }
}

- (void)addSelectedAssetWithModel:(CBPic2kerAssetModel *)assetMdoel {
    if (!assetMdoel) { return; }
    
    if (![self.selectedAssetIdentifierArr containsObject:[assetMdoel.asset localIdentifier]]) {
        [self.selectedAssetIdentifierArr addObject:[assetMdoel.asset localIdentifier]];
        [self.selectedAssetArr addObject:assetMdoel];
    }
}

- (BOOL)authorizationStatusAuthorized {
    NSInteger status = [PHPhotoLibrary authorizationStatus];
    
    if (status == 0) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
                // ...
            }];
        });
    }
    
    return status == 3;
}

- (void)getCameraRollAlbumWithCompletion:(void (^)(CBPic2kerAlbumModel *))completion {
    __block CBPic2kerAlbumModel *model;
    
    PHFetchOptions *option = [[PHFetchOptions alloc] init];
    option.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate"
                                                             ascending:NO]];
    PHFetchResult *smartAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum
                                                                          subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
    for (PHAssetCollection *collection in smartAlbums) {
        if (![collection isKindOfClass:[PHAssetCollection class]]) continue;
        
        if ([self isCameraRollAlbum:collection.localizedTitle]) {
            PHFetchResult *fetchResult = [PHAsset fetchAssetsInAssetCollection:collection options:option];
            model = [CBPic2kerAlbumModel modelWithResult:fetchResult
                                                    name:collection.localizedTitle];
            if (completion) completion(model);
            break;
        }
    }
}

- (void)getAllAlbumsWithCompletion:(void (^)(NSArray<CBPic2kerAlbumModel *> *))completion {
    NSMutableArray *albumArr = [NSMutableArray array];

    PHFetchOptions *option = [[PHFetchOptions alloc] init];
    option.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate"
                                                             ascending:NO]];
    PHFetchResult *myPhotoStreamAlbum = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAlbumMyPhotoStream options:nil];
    PHFetchResult *smartAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
    PHFetchResult *topLevelUserCollections = [PHCollectionList fetchTopLevelUserCollectionsWithOptions:nil];
    PHFetchResult *syncedAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAlbumSyncedAlbum options:nil];
    PHFetchResult *sharedAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAlbumCloudShared options:nil];
    NSArray *allAlbums = @[myPhotoStreamAlbum,smartAlbums,topLevelUserCollections,syncedAlbums,sharedAlbums];
    for (PHFetchResult *fetchResult in allAlbums) {
        for (PHAssetCollection *collection in fetchResult) {
            if (![collection isKindOfClass:[PHAssetCollection class]]) continue;
            PHFetchResult *fetchResult = [PHAsset fetchAssetsInAssetCollection:collection options:option];
            if (fetchResult.count < 1) continue;
            if ([collection.localizedTitle containsString:@"Deleted"] || [collection.localizedTitle isEqualToString:@"最近删除"]) continue;
            if ([self isCameraRollAlbum:collection.localizedTitle]) {
                [albumArr insertObject:[CBPic2kerAlbumModel modelWithResult:fetchResult
                                                                       name:collection.localizedTitle] atIndex:0];
            } else {
                [albumArr addObject:[CBPic2kerAlbumModel modelWithResult:fetchResult
                                                                    name:collection.localizedTitle]];
            }
        }
    }
    if (completion && albumArr.count > 0) completion(albumArr);
}

- (void)getAssetsFromFetchResult:(id)result
                      completion:(void (^)(NSArray<CBPic2kerAssetModel *> *))completion {
    if (!result) { return; }

    NSMutableArray *photoArr = [NSMutableArray array];
    
    if (![result isKindOfClass:[PHFetchResult class]]) { return; }
    
    PHFetchResult *fetchResult = (PHFetchResult *)result;
    [fetchResult enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        CBPic2kerAssetModel *model = [self assetModelWithAsset:obj];
        if ([[[CBPic2kerPhotoLibrary sharedPhotoLibrary] selectedAssetIdentifierArr] containsObject:[(PHAsset *)obj localIdentifier]]) {
            model.isSelected = YES;
        }
        if (model) {
            [photoArr addObject:model];
        }
    }];
    if (completion) completion(photoArr);
}

- (CBPic2kerAssetModel *)assetModelWithAsset:(id)asset {
    if (!asset || ![asset isKindOfClass:[PHAsset class]]) { return nil; }

    CBPic2kerAssetModel *model;
    CBPic2kerAssetModelMediaType type = CBPic2kerAssetModelMediaTypePhoto;
    
    PHAsset *phAsset = (PHAsset *)asset;
    if (phAsset.mediaType == PHAssetMediaTypeVideo)      type = CBPic2kerAssetModelMediaTypeVideo;
    else if (phAsset.mediaType == PHAssetMediaTypeAudio) type = CBPic2kerAssetModelMediaTypeAudio;
    else if (phAsset.mediaType == PHAssetMediaTypeImage) {
        if ([[phAsset valueForKey:@"filename"] hasSuffix:@"GIF"]) {
            type = CBPic2kerAssetModelMediaTypeGif;
        }
    }
    
    if (phAsset.mediaSubtypes == PHAssetMediaSubtypePhotoLive) {
        type = CBPic2kerAssetModelMediaTypeLivePhoto;
    }
    
    NSString *timeLength = type == CBPic2kerAssetModelMediaTypeVideo ? [NSString stringWithFormat:@"%0.0f",phAsset.duration] : @"";
    timeLength = [self getNewTimeFromDurationSecond:timeLength.integerValue];
    model = [CBPic2kerAssetModel modelWithAsset:asset
                                           type:type
                                     timeLength:timeLength];
    
    return model;
}

- (NSString *)getNewTimeFromDurationSecond:(NSInteger)duration {
    NSString *newTime;
    if (duration < 10) {
        newTime = [NSString stringWithFormat:@"0:0%zd",duration];
    } else if (duration < 60) {
        newTime = [NSString stringWithFormat:@"0:%zd",duration];
    } else {
        NSInteger min = duration / 60;
        NSInteger sec = duration - (min * 60);
        if (sec < 10) {
            newTime = [NSString stringWithFormat:@"%zd:0%zd",min,sec];
        } else {
            newTime = [NSString stringWithFormat:@"%zd:%zd",min,sec];
        }
    }
    return newTime;
}

- (void)getPostImageWithAlbumModel:(CBPic2kerAlbumModel *)model
                        completion:(void (^)(UIImage *))completion {
    if (!model) { return; }
    
    id asset = [model.result firstObject];
    [[CBPic2kerPhotoLibrary sharedPhotoLibrary] getPhotoWithAsset:asset
                                                       photoWidth:80
                                                       completion:^(UIImage *photo, NSDictionary *info, BOOL isDegraded) {
                                                           if (completion) completion(photo);
                                                       } progressHandler:nil];
}

- (PHImageRequestID)getPhotoWithAsset:(id)asset
                           photoWidth:(CGFloat)photoWidth
                           completion:(void (^)(UIImage *, NSDictionary *, BOOL))completion
                      progressHandler:(void (^)(double, NSError *, BOOL *, NSDictionary *))progressHandler {
    if (!asset || ![asset isKindOfClass:[PHAsset class]]) { return 0; }
    
    CGSize imageSize;
    if (photoWidth < [UIScreen mainScreen].bounds.size.width && photoWidth < kCBPic2kerPhotoLibraryPreviewMaxWidth) {
        imageSize = _gridThumbnailSize;
    } else {
        PHAsset *phAsset = (PHAsset *)asset;
        CGFloat aspectRatio = phAsset.pixelWidth / (CGFloat)phAsset.pixelHeight;
        CGFloat pixelWidth = photoWidth * 2;
        CGFloat pixelHeight = pixelWidth / aspectRatio;
        imageSize = CGSizeMake(pixelWidth, pixelHeight);
    }
    PHImageRequestOptions *option = [[PHImageRequestOptions alloc] init];
    option.resizeMode = PHImageRequestOptionsResizeModeFast;
    PHImageRequestID imageRequestID = [[PHImageManager defaultManager] requestImageForAsset:asset targetSize:imageSize contentMode:PHImageContentModeAspectFill options:option resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        BOOL downloadFinined = (![[info objectForKey:PHImageCancelledKey] boolValue] && ![info objectForKey:PHImageErrorKey]);
        if (downloadFinined && result) {
            result = [UIImage fixOrientation:result];
            if (completion) completion(result,info,[[info objectForKey:PHImageResultIsDegradedKey] boolValue]);
        }
        // Download image from iCloud / 从iCloud下载图片
        if ([info objectForKey:PHImageResultIsInCloudKey] && !result) {
            PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
            options.progressHandler = ^(double progress, NSError *error, BOOL *stop, NSDictionary *info) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (progressHandler) {
                        progressHandler(progress, error, stop, info);
                    }
                });
            };
            options.networkAccessAllowed = YES;
            options.resizeMode = PHImageRequestOptionsResizeModeFast;
            [[PHImageManager defaultManager] requestImageDataForAsset:asset options:options resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
                UIImage *resultImage = [UIImage imageWithData:imageData scale:0.1];
                resultImage = [UIImage scaleImage:resultImage
                                           toSize:imageSize];
                if (resultImage) {
                    resultImage = [UIImage fixOrientation:resultImage];
                    if (completion) completion(resultImage,info,[[info objectForKey:PHImageResultIsDegradedKey] boolValue]);
                }
            }];
        }
    }];
    return imageRequestID;
}

#pragma mark - Internal.
- (BOOL)isCameraRollAlbum:(NSString *)albumName {
    return [albumName isEqualToString:@"Camera Roll"] || [albumName isEqualToString:@"相机胶卷"] || [albumName isEqualToString:@"所有照片"] || [albumName isEqualToString:@"All Photos"];
}

- (void)setColumnNumber:(NSInteger)columnNumber {
    _columnNumber = columnNumber;
    CGFloat itemWH = ([UIScreen mainScreen].bounds.size.width - _itemSpace * (columnNumber + 1)) / columnNumber;
    _gridThumbnailSize = CGSizeMake(itemWH * 2, itemWH * 2);
}

- (NSMutableArray<CBPic2kerAssetModel *> *)selectedAssetArr {
    if (!_selectedAssetArr) {
        _selectedAssetArr = [[NSMutableArray alloc] init];
    }
    return _selectedAssetArr;
}

- (NSMutableArray<NSString *> *)selectedAssetIdentifierArr {
    if (!_selectedAssetIdentifierArr) {
        _selectedAssetIdentifierArr = [[NSMutableArray alloc] init];
    }
    return _selectedAssetIdentifierArr;
}

@end
