// CBPhotoBrowserScrollViewCell.m
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

#import <CBPic2ker/CBPhotoBrowserScrollViewCell.h>
#import <CBPic2ker/CBPhotoBrowserAssetModel.h>
#import <Photos/Photos.h>
#import <CBPic2ker/CBPhotoSelecterPhotoLibrary.h>
#import <CBPic2ker/UIView+CBPic2ker.h>

@interface CBPhotoBrowserScrollViewCell() <UIScrollViewDelegate>

@property (nonatomic, strong, readwrite) CBPhotoSelecterPhotoLibrary *photoLibrary;

@end

@implementation CBPhotoBrowserScrollViewCell

#pragma init
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.delegate = self;
        self.bouncesZoom = YES;
        self.maximumZoomScale = 3;
        self.multipleTouchEnabled = YES;
        self.alwaysBounceVertical = NO;
        self.showsVerticalScrollIndicator = YES;
        self.showsHorizontalScrollIndicator = NO;
        
        [self addSubview:self.imageContainerView];
        [self.imageContainerView addSubview:self.imageView];
    }
    return self;
}

#pragma maek - Layout


#pragma mark - Setter && Getter
- (UIImageView *)imageView {
    if (!_imageView) {
        _imageView = [[UIImageView alloc] init];
        _imageView.clipsToBounds = YES;
        _imageView.backgroundColor = [UIColor colorWithWhite:1.000 alpha:0.500];
        _imageView.image = _assetModel.middleSizeImage;
    }
    return _imageView;
}

- (UIView *)imageContainerView {
    if (!_imageContainerView) {
        _imageContainerView = [[UIView alloc] init];
        _imageContainerView.clipsToBounds = YES;
    }
    return _imageContainerView;
}

- (CBPhotoSelecterPhotoLibrary *)photoLibrary {
    if (!_photoLibrary) {
        _photoLibrary = [CBPhotoSelecterPhotoLibrary sharedPhotoLibrary];
    }
    return _photoLibrary;
}

#pragma mark - Public
- (void)configureCellWithModel:(CBPhotoBrowserAssetModel *)model {
    if (!model) { return; }
    
    self.assetModel = model;
    
    [self setZoomScale:1.0 animated:NO];
    self.maximumZoomScale = 3;

    self.imageView.image = model.fullSizeImage ? model.fullSizeImage : model.middleSizeImage;
    
    if (!model.fullSizeImage) {
        [self.photoLibrary getFullSizePhotoWithAsset:model.asset
                                          completion:^(UIImage *photo, NSDictionary *info, BOOL isDegraded) {
                                              self.imageView.image = photo;
                                              model.fullSizeImage = photo;
                                              
                                              [self reLayoutSubviews];
                                          }];
    }
    
    [self reLayoutSubviews];
}

- (void)reLayoutSubviews {
    self.imageContainerView.origin = CGPointZero;
    self.imageContainerView.sizeWidth = self.sizeWidth;
    
    UIImage *image = self.imageView.image;
    if (image.size.height / image.size.width > self.sizeHeight / self.sizeWidth) {
        self.imageContainerView.sizeHeight = floor(image.size.height / (image.size.width / self.sizeWidth));
    } else{
        CGFloat height = floor(image.size.height / image.size.width * self.sizeWidth);
        self.imageContainerView.sizeHeight = height;
        self.imageContainerView.centerY = self.sizeHeight / 2;
    }
    
    self.contentSize = CGSizeMake(self.sizeWidth, MAX(_imageContainerView.sizeHeight, self.sizeHeight));
    [self scrollRectToVisible:self.bounds animated:NO];

    if (_imageContainerView.sizeHeight < self.sizeHeight) {
        self.alwaysBounceVertical = NO;
    } else {
        self.alwaysBounceVertical = YES;
    }

    _imageView.frame = _imageContainerView.bounds;
}

@end
