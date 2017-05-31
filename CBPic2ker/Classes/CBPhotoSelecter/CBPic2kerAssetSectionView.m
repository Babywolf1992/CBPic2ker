// CBPic2kerAssetSectionView.m
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

#import <CBPic2ker/CBPic2kerAssetSectionView.h>
#import <CBPic2ker/CBPic2kerAssetSectionViewCell.h>

@interface CBPic2kerAssetSectionView()

@property (nonatomic, assign, readwrite) NSInteger columNumber;
@property (nonatomic, strong, readwrite) NSMutableArray<CBPic2kerAssetModel *> *currentAlbumAssetsModelsArray;

@property (nonatomic, copy, readwrite) void(^albumButtonTouchActionBlockInternal)(id);
@property (nonatomic, copy, readwrite) void(^assetButtonTouchActionBlockInternal)(id);

@end

@implementation CBPic2kerAssetSectionView

- (UIEdgeInsets)inset {
    return UIEdgeInsetsMake(3, 8, 8, 8);
}

- (CGFloat)minimumLineSpacing {
    return 1;
}

- (instancetype)initWithColumNumber:(NSInteger)columNumber
        albumButtonTouchActionBlock:(void (^)(id))albumButtonTouchActionBlock
        assetButtonTouchActionBlock:(void (^)(id))assetButtonTouchActionBlock {
    self = [super init];
    if (self) {
        _columNumber = columNumber;
        _albumButtonTouchActionBlockInternal = albumButtonTouchActionBlock;
        _assetButtonTouchActionBlockInternal = assetButtonTouchActionBlock;
    }
    return self;
}

- (void)albumAction:(UIButton *)sender {
    !_albumButtonTouchActionBlockInternal ?: _albumButtonTouchActionBlockInternal(sender);
}

- (CGSize)sizeForItemAtIndex:(NSInteger)index {
    return CGSizeMake((self.viewController.view.frame.size.width - (_columNumber - 1) * 1 - 16) / _columNumber, (self.viewController.view.frame.size.width - (_columNumber - 1) * 1 - 16) / _columNumber);
}

- (NSInteger)numberOfItems {
    return _currentAlbumAssetsModelsArray.count;
}

- (void)didUpdateToObject:(id)object {
    _currentAlbumAssetsModelsArray = object;
}

- (UICollectionViewCell *)cellForItemAtIndex:(NSInteger)index {
    if (_currentAlbumAssetsModelsArray.count <= index) { return nil; }
    
    CBPic2kerAssetSectionViewCell *cell = [self.collectionContext dequeueReusableCellOfClass:[CBPic2kerAssetSectionViewCell class]
                                            forSectionController:self
                                                         atIndex:index];
    
    [cell configureWithAssetModel:_currentAlbumAssetsModelsArray[index]
              selectedActionBlock:^(id model) {
                  !_assetButtonTouchActionBlockInternal ?: _assetButtonTouchActionBlockInternal(model);
              }];
    return cell;
}

- (UICollectionReusableView *)viewForSupplementaryElementOfKind:(NSString *)elementKind
                                                        atIndex:(NSInteger)index {
    if ([elementKind isEqualToString:UICollectionElementKindSectionHeader]) {
        UICollectionReusableView *hearderView = [self.collectionContext dequeueReusableSupplementaryViewFromStoryboardOfKind:elementKind viewClass:[UICollectionReusableView class] forSectionController:self atIndex:index];

        if (!_albumButton) {
            _albumButton = [[UIButton alloc] initWithFrame:CGRectMake(8, 0, hearderView.frame.size.width - 16, hearderView.frame.size.height)];
            [_albumButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
            _albumButton.layer.cornerRadius = 3;
            [_albumButton.titleLabel setFont:[UIFont fontWithName:@"AvenirNext-Medium" size:18]];
            [_albumButton addTarget:self
                             action:@selector(albumAction:)
                   forControlEvents:UIControlEventTouchUpInside];
            _albumButton.backgroundColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.15];
            [hearderView addSubview:_albumButton];
        }
        
        return hearderView;
    }
    return nil;
}

- (CGSize)sizeForSupplementaryViewOfKind:(NSString *)elementKind
                                 atIndex:(NSInteger)index {
    if ([elementKind isEqualToString:UICollectionElementKindSectionHeader] && index == self.section) {
        return CGSizeMake(self.viewController.view.frame.size.width - 8, 45);
    } else {
        return CGSizeZero;
    }
}

@end
