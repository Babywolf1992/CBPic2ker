// CBPic2kerAssetModel.h
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

#import <Foundation/Foundation.h>

/**
 Asset type.

 - CBPic2kerAssetModelMediaTypePhoto: Photo type.
 - CBPic2kerAssetModelMediaTypeLivePhoto: Live photo.
 - CBPic2kerAssetModelMediaTypeGif: Gif photo.
 - CBPic2kerAssetModelMediaTypeVideo: Video.
 - CBPic2kerAssetModelMediaTypeAudio: Audio.
 */
typedef NS_ENUM(NSInteger, CBPic2kerAssetModelMediaType) {
    CBPic2kerAssetModelMediaTypePhoto,
    CBPic2kerAssetModelMediaTypeLivePhoto,
    CBPic2kerAssetModelMediaTypeGif,
    CBPic2kerAssetModelMediaTypeVideo,
    CBPic2kerAssetModelMediaTypeAudio
};

@interface CBPic2kerAssetModel : NSObject

/**
 Asset data.
 */
@property (nonatomic, strong, readwrite) id asset;

/**
 Judge if the specified photo is selected.
 */
@property (nonatomic, assign, readwrite) BOOL isSelected;

/**
 Judge the asset type.
 */
@property (nonatomic, assign, readwrite) CBPic2kerAssetModelMediaType mediaType;

/**
 Time length.
 */
@property (nonatomic, copy, readwrite) NSString *timeLength;

/**
 Image, set when mediatype is image.
 */
@property (nonatomic, strong, readwrite) UIImage *smallSizeImage;
@property (nonatomic, strong, readwrite) UIImage *middleSizeImage;
@property (nonatomic, strong, readwrite) UIImage *fullSizeImage;

/**
 Init a photo dataModel With a asset.

 @param asset PHAsset instance.
 @param type Media type.
 @return DataModel instance.
 */
+ (instancetype)modelWithAsset:(id)asset
                          type:(CBPic2kerAssetModelMediaType)type;

/**
 Init a photo dataModel With a asset.

 @param asset PHAsset instance.
 @param type Media type.
 @param timeLength Time length.
 @return DataModel instance.
 */
+ (instancetype)modelWithAsset:(id)asset
                          type:(CBPic2kerAssetModelMediaType)type
                    timeLength:(NSString *)timeLength;


@end
