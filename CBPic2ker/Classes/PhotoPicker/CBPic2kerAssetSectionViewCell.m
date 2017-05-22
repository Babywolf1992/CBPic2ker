// CBPic2kerAssetSectionViewCellCollectionViewCell.m
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

#import <CBPic2ker/CBPic2kerAssetSectionViewCell.h>
#import <CBPic2ker/CBPic2kerPhotoLibrary.h>
#import <CBPic2ker/CBPic2kerAssetModel.h>
#import <CBPic2ker/UIImage+CBPic2ker.h>

@interface CBPic2kerAssetSectionViewCell()

@property (nonatomic, strong, readwrite) UIImageView *assetImageView;
@property (nonatomic, strong, readwrite) UIImageView *videoImgView;
@property (nonatomic, strong, readwrite) UIView *bottomView;
@property (nonatomic, strong, readwrite) UILabel *timeLength;

@property (nonatomic, copy, readwrite) NSString *representedAssetIdentifier;
@property (nonatomic, assign, readwrite) PHImageRequestID imageRequestID;
@property (nonatomic, assign, readwrite) CBPic2kerAssetModelMediaType type;

@property (nonatomic, strong, readwrite) CBPic2kerAssetModel *assetModel;

@end

@implementation CBPic2kerAssetSectionViewCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self.contentView addSubview:self.assetImageView];
        [self.contentView addSubview:self.bottomView];
        [self.bottomView addSubview:self.videoImgView];
        [self.bottomView addSubview:self.timeLength];
    }
    return self;
}

- (void)configureWithAssetModel:(CBPic2kerAssetModel *)assetModel {
    if (!assetModel) { return; }
    
    _assetModel = assetModel;
    
    self.representedAssetIdentifier = [(PHAsset *)assetModel.asset localIdentifier];
    self.type = (NSInteger)assetModel.mediaType;

    PHImageRequestID imageRequestID = [[CBPic2kerPhotoLibrary sharedPhotoLibrary] getPhotoWithAsset:assetModel.asset photoWidth:self.frame.size.width completion:^(UIImage *photo, NSDictionary *info, BOOL isDegraded) {
        if ([self.representedAssetIdentifier isEqualToString:[(PHAsset *)assetModel.asset localIdentifier]]) {
            self.assetImageView.image = photo;
        } else {
            [[PHImageManager defaultManager] cancelImageRequest:self.imageRequestID];
        }
    } progressHandler:nil];
    
    self.imageRequestID = imageRequestID;
}

- (UIImageView *)assetImageView {
    if (!_assetImageView) {
        _assetImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
        _assetImageView.contentMode = UIViewContentModeScaleAspectFill;
        _assetImageView.clipsToBounds = YES;
    }
    return _assetImageView;
}

- (UIView *)bottomView {
    if (!_bottomView) {
        _bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, self.frame.size.height - 17, self.frame.size.width, 17)];
        _bottomView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.8];
    }
    return _bottomView;
}

- (void)setType:(CBPic2kerAssetModelMediaType)type {
    _type = type;
    
    switch (_type) {
        case CBPic2kerAssetModelMediaTypeVideo:
            _bottomView.hidden = false;
            _timeLength.text = _assetModel.timeLength;
            break;
        default:
            _bottomView.hidden = true;
            break;
    }
}

- (UIImageView *)videoImgView {
    if (!_videoImgView) {
        _videoImgView = [[UIImageView alloc] initWithFrame:CGRectMake(8, 0, 17, 17)];
        [_videoImgView setImage:[UIImage imageWithContentsOfFile:[[[NSBundle mainBundle] pathForResource:@"CBPic2kerPicker" ofType:@"bundle"] stringByAppendingString:@"/Vid"]]];
        [self.bottomView addSubview:_videoImgView];
    }
    return _videoImgView;
}

- (UILabel *)timeLength {
    if (!_timeLength) {
        _timeLength = [[UILabel alloc] init];
        _timeLength.font = [UIFont boldSystemFontOfSize:11];
        _timeLength.frame = CGRectMake(self.videoImgView.frame.origin.x + self.videoImgView.frame.size.width, 0, self.frame.size.width - self.videoImgView.frame.origin.x - self.videoImgView.frame.size.width - 5, 17);
        _timeLength.textColor = [UIColor whiteColor];
        _timeLength.textAlignment = NSTextAlignmentRight;
    }
    return _timeLength;
}

@end
