// CBPic2kerPreCollectionSectionView.m
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

#import <CBPic2ker/CBPic2kerPreCollectionSectionView.h>
#import <CBPic2ker/UIView+CBPic2ker.h>
#import <CBPic2ker/CBCollectionViewAdapter.h>
#import <CBPic2ker/CBPic2kerAssetSectionView.h>
#import <CBPic2ker/CBPic2kerPhotoLibrary.h>
#import <CBPic2ker/CBCollectionView.h>
#import <CBPic2ker/CBPic2kerPreSectionView.h>
#import <CBPic2ker/NSArray+CBPic2ker.h>

@interface CBPic2kerPreCollectionSectionView() <CBCollectionViewAdapterDataSource>

@property (nonatomic, assign, readwrite) NSInteger preViewHeightInternal;

@property (nonatomic, strong, readwrite) CBCollectionViewAdapter *adapter;
@property (nonatomic, strong, readwrite) CBCollectionView *collectionView;
@property (nonatomic, strong, readwrite) CBPic2kerPreSectionView *preSectionView;

@property (nonatomic, strong, readwrite) CBPic2kerPhotoLibrary *photoLibrary;

@property (nonatomic, strong, readwrite) NSArray *selectedPhotosArrInternal;

@end

@implementation CBPic2kerPreCollectionSectionView

- (instancetype)initWithPreViewHeight:(NSInteger)preViewHeight {
    self = [super init];
    if (self) {
        _preViewHeightInternal = preViewHeight;
    }
    return self;
}

- (void)changeCollectionViewLocation {
    if (!_selectedPhotosArrInternal.count) { return; }
    
    if (!self.photoLibrary.isInsetAsset || _selectedPhotosArrInternal.count != 1)  {
        [_collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:_selectedPhotosArrInternal.count - 1 inSection:0] atScrollPosition:UICollectionViewScrollPositionRight animated:YES];
    } else {
        _collectionView.frame = CGRectMake(self.viewController.view.frame.size.width, 0, _collectionView.frame.size.width * 0.8, _collectionView.frame.size.height * 0.8);
        _collectionView.center = CGPointMake(_collectionView.center.x, _preViewHeightInternal / 2);

        [_collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:_selectedPhotosArrInternal.count - 1 inSection:0] atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:NO];
        
        [UIView animateWithDuration:0.5
                              delay:0
             usingSpringWithDamping:0.8
              initialSpringVelocity:20
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             _collectionView.frame = CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, _preViewHeightInternal);
                         } completion:nil];
    }
}

- (CBPic2kerPhotoLibrary *)photoLibrary {
    _photoLibrary = [CBPic2kerPhotoLibrary sharedPhotoLibrary];
    return _photoLibrary;
}

- (CBCollectionView *)collectionView {
    if (!_collectionView) {
        _collectionView = [[CBCollectionView alloc] initWithFrame:CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, _preViewHeightInternal) direction:CBPic2kerCollectionDirectionHorizontal];
        _collectionView.backgroundColor = [UIColor clearColor];
        _collectionView.alwaysBounceHorizontal = YES;
        _collectionView.showsHorizontalScrollIndicator = NO;
    }
    return _collectionView;
}

- (CBCollectionViewAdapter *)adapter {
    if (!_adapter) {
        _adapter = [[CBCollectionViewAdapter alloc] initWithViewController:self.viewController];
        _adapter.collectionView = self.collectionView;
        _adapter.dataSource = self;
    }
    return _adapter;
}

- (CBPic2kerPreSectionView *)preSectionView {
    if (!_preSectionView) {
        _preSectionView = [[CBPic2kerPreSectionView alloc] init];
    }
    return _preSectionView;
}

- (CGSize)sizeForItemAtIndex:(NSInteger)index {
    return CGSizeMake([[UIScreen mainScreen] bounds].size.width, _preViewHeightInternal);
}

- (NSInteger)numberOfItems {
    return 1;
}

- (void)didUpdateToObject:(id)object {
    NSInteger changedIndex = [(NSArray *)object findDelectedOrInsertedIndexByComparingWithOldArray:_selectedPhotosArrInternal];
    
    self.selectedPhotosArrInternal = [object mutableCopy];
    [self.adapter updateObjects:[self objectsForAdapter:self.adapter]
                     dataSource:self];
    
    if (changedIndex != NSNotFound) {
        if (changedIndex == 0 && _selectedPhotosArrInternal.count == 1) {
            [self.adapter reloadDataWithCompletion:nil]; return;
        }
        
        if (!self.photoLibrary.isInsetAsset) {
            [self.collectionView deleteItemsAtIndexPaths:[NSArray arrayWithObjects:[NSIndexPath indexPathForRow:changedIndex inSection:0], nil]];
        } else {
            [self.collectionView insertItemsAtIndexPaths:[NSArray arrayWithObjects:[NSIndexPath indexPathForRow:changedIndex inSection:0], nil]];
        }
    }
}

- (UICollectionViewCell *)cellForItemAtIndex:(NSInteger)index {
    UICollectionViewCell *cell = [self.collectionContext dequeueReusableCellOfClass:[UICollectionViewCell class]
                                                               forSectionController:self
                                                                            atIndex:index];
    [cell.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
         [obj removeFromSuperview];
    }];
    [cell addSubview:self.collectionView];
    return cell;
}

- (void)didSelectItemAtIndex:(NSInteger)index {
}

- (NSArray *)objectsForAdapter:(CBCollectionViewAdapter *)adapter {
    return [NSMutableArray arrayWithObjects:_selectedPhotosArrInternal, nil];
}

- (CBCollectionViewSectionController *)adapter:(CBCollectionViewAdapter *)adapter
                    sectionControllerForObject:(id)object {
    return self.preSectionView;
}

@end
