// CBPhotoSelecterPreSectionViewCell.m
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

#import <CBPic2ker/CBPhotoSelecterPreSectionViewCell.h>
#import <Photos/Photos.h>
#import <CBPic2ker/CBPhotoSelecterPhotoLibrary.h>

@interface CBPhotoSelecterPreSectionViewCell()

@property (nonatomic, strong, readwrite) UIImageView *imageView;

@property (nonatomic, strong, readwrite) CBPhotoSelecterAssetModel *assetModel;
@property (nonatomic, strong, readwrite) NSString *representedAssetIdentifier;
@property (nonatomic, assign, readwrite) int imageRequestID;

@end

@implementation CBPhotoSelecterPreSectionViewCell

- (void)configureWithAssetModel:(CBPhotoSelecterAssetModel *)assetModel
            selectedActionBlock:(void (^)(id))selectedActionBlock {
    if (!assetModel) { return; }
    
    self.assetModel = assetModel;
    self.representedAssetIdentifier = [(PHAsset *)assetModel.asset localIdentifier];
    
    switch (assetModel.mediaType) {
        case CBPhotoSelecterAssetModelMediaTypePhoto:
            [self.contentView addSubview:self.imageView];
            self.imageView.image = _assetModel.fullSizeImage ? _assetModel.fullSizeImage : (_assetModel.middleSizeImage ? _assetModel.middleSizeImage: _assetModel.smallSizeImage);
            break;
        default:
            break;
    }
    
    PHImageRequestID imageRequestID = [[CBPhotoSelecterPhotoLibrary sharedPhotoLibrary] getPhotoWithAsset:assetModel.asset photoWidth:self.frame.size.width completion:^(UIImage *photo, NSDictionary *info, BOOL isDegraded) {
        if ([self.representedAssetIdentifier isEqualToString:[(PHAsset *)assetModel.asset localIdentifier]]) {
            self.imageView.image = photo;
            assetModel.smallSizeImage = photo;
        } else {
            [[PHImageManager defaultManager] cancelImageRequest:self.imageRequestID];
        }
    } progressHandler:nil];
    
    self.imageRequestID = imageRequestID;
}

- (UIImageView *)imageView {
    if (!_imageView) {
        _imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        _imageView.clipsToBounds = YES;
    }
    return _imageView;
}

@end
