// CBPic2kerAlbumTableView.m
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

#import <CBPic2ker/CBPic2kerAlbumView.h>
#import <CBPic2ker/CBPic2kerAdapter.h>
#import <CBPic2ker/CBPic2kerAlbumSectionView.h>
#import <CBPic2ker/CBPic2kerPhotoLibrary.h>
#import <CBPic2ker/CBPic2kerCollectionView.h>
#import <CBPic2ker/CBPic2kerAdapter+collectionViewDelegate.h>

@interface CBPic2kerAlbumView() <CBPic2kerAdapterDataSource>

@property (nonatomic, strong, readwrite) CBPic2kerCollectionView *collectionView;
@property (nonatomic, strong, readwrite) CBPic2kerAdapter *adapter;
@property (nonatomic, copy, readwrite) NSArray *albumDataArr;

@property (nonatomic, copy, readwrite) void(^albumBlock)(CBPic2kerAlbumModel *model);

@end

@implementation CBPic2kerAlbumView

- (instancetype)initWithFrame:(CGRect)frame
                   albumArray:(NSArray *)albumArray
        didSelectedAlbumBlock:(void (^)(CBPic2kerAlbumModel *))albumBlock {
    self = [super initWithFrame:frame];
    if (self) {
        self.albumDataArr = albumArray;
        _albumBlock = albumBlock;
        
        [self setUpBlurView];
        
        [self.adapter setDataSource:self];
        [self addSubview:self.collectionView];
    }
    return self;
}

- (void)setUpBlurView {
    UIBlurEffect *blurView = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
    UIVisualEffectView *effectview = [[UIVisualEffectView alloc] initWithEffect:blurView];
    effectview.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    [self addSubview:effectview];
}

- (CBPic2kerAdapter *)adapter {
    if (!_adapter) {
        _adapter = [[CBPic2kerAdapter alloc] initWithViewController:nil];
        _adapter.collectionView = self.collectionView;
    }
    return _adapter;
}

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        _collectionView = [[CBPic2kerCollectionView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
        _collectionView.backgroundColor = [UIColor clearColor];
        _collectionView.alwaysBounceVertical = YES;
    }
    return _collectionView;
}

- (NSArray *)albumDataArr {
    if (!_albumDataArr) {
        _albumDataArr = [[NSMutableArray alloc] init];
    }
    return _albumDataArr;
}

#pragma mark - Adapter DataSource
- (NSArray *)objectsForAdapter:(CBPic2kerAdapter *)adapter {
    return [NSArray arrayWithObjects:self.albumDataArr, nil];
}

- (CBPic2kerSectionController *)adapter:(CBPic2kerAdapter *)adapter
             sectionControllerForObject:(id)object {
    return [[CBPic2kerAlbumSectionView alloc] initWithSelectedAlbumBlock:_albumBlock];
}

@end
