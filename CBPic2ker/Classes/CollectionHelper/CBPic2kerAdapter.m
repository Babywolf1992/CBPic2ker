// CBPic2kerAdapter.m
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

#import <CBPic2ker/CBPic2kerAdapter.h>
#import <CBPic2ker/CBPic2kerDelegateProxy.h>
#import <CBPic2ker/CBPic2kerAdapterHelper.h>
#import <CBPic2ker/CBPic2kerSectionController.h>

@class CBPic2kerContextProtocol;

@interface CBPic2kerAdapter()

@property (nonatomic, strong, readwrite) CBPic2kerDelegateProxy *delegateProxy;

@end

@implementation CBPic2kerAdapter

#pragma mark - Init
- (instancetype)initWithViewController:(nullable UIViewController *)viewController {
    self = [super init];
    if (self) {
        _viewController = viewController;
    }
    return self;
}

- (void)dealloc {
    self.collectionView.delegate = nil;
    self.collectionView.dataSource = nil;
}

#pragma mark - Setter & Getter
- (void)setCollectionView:(UICollectionView *)collectionView {
    if (_collectionView != collectionView || _collectionView.dataSource != self) {
        _collectionView = collectionView;
        _collectionView.dataSource = (id<UICollectionViewDataSource>)self;
        _collectionView.delegate = (id<UICollectionViewDelegate>)self.delegateProxy ?: (id<UICollectionViewDelegate>)self;
        [_collectionView.collectionViewLayout invalidateLayout];
        
        [self updateAfterPublicSettingsChange];
    }
}

- (void)setCollectionViewDelegate:(id<UICollectionViewDelegate>)collectionViewDelegate {
    _collectionViewDelegate = collectionViewDelegate;
    _collectionView.delegate = (id<UICollectionViewDelegate>)self.delegateProxy ?: (id<UICollectionViewDelegate>)self;
}

- (void)setScrollViewDelegate:(id<UIScrollViewDelegate>)scrollViewDelegate {
    _scrollViewDelegate = scrollViewDelegate;
    _collectionView.delegate = (id<UICollectionViewDelegate>)self.delegateProxy ?: (id<UICollectionViewDelegate>)self;
}

#pragma mark - Data Handler
- (void)setDataSource:(id<CBPic2kerAdapterDataSource>)dataSource {
    _dataSource = dataSource;
    [self updateAfterPublicSettingsChange];
}

- (void)updateAfterPublicSettingsChange {
    if (_dataSource && _collectionView) {
        [self updateObjects:[[_dataSource objectsForAdapter:self] copy] dataSource:_dataSource];
    }
}

- (void)updateObjects:(NSArray *)objects
           dataSource:(id<CBPic2kerAdapterDataSource>)dataSource {
    NSMutableArray *sectionControllers = [NSMutableArray new];
    NSMutableArray *validObjects = [NSMutableArray new];

    for (id object in objects) {
        CBPic2kerSectionController *sectionController = [self.adapterHelper sectionControllerForObject:object];

        if (!sectionController) {
            sectionController = [_dataSource adapter:self
                                  sectionControllerForObject:object];
        }
        
        if (!sectionController) { continue; }
        
        sectionController.viewController = _viewController;
        sectionController.collectionContext = (id <CBPic2kerContextProtocol>)self;

        [sectionControllers addObject:sectionController];
        [validObjects addObject:object];
    }
    
    [self.adapterHelper updateWithObjects:validObjects
                       sectionControllers:sectionControllers];
    
    for (id object in validObjects) {
        [[self.adapterHelper sectionControllerForObject:object] didUpdateToObject:object];
    }
}

//- (void)performUpdatesAnimated:(BOOL)animated
//                    completion:(CBPic2kerUpdaterCompletion)completion {
//    if (_dataSource == nil || _collectionView == nil) {
//        if (completion) {
//            completion(NO);
//        }
//        return;
//    }
//    
//    NSArray *newObjects = [_dataSource objectsForTimelineAdapter:self];
//    if (!newObjects.count) { return; }
//    
//    [self updateObjects:newObjects
//             dataSource:_dataSource];
//    
//    if (animated) {
//        [_collectionView performBatchUpdates:^{
//
//        } completion:nil];
//    } else {
//        [CATransaction begin];
//        [CATransaction setDisableActions:YES];
//        [_collectionView performBatchUpdates:^{
//            
//        } completion:^(BOOL finished) {
//            !completion ?: completion(finished);
//            [CATransaction commit];
//        }];
//    }
//}

- (void)reloadDataWithCompletion:(CBPic2kerUpdaterCompletion)completion {
    if (_dataSource == nil || _collectionView == nil) {
        if (completion) {
            completion(NO);
        }
        return;
    }
    
    NSArray *newObjects = [_dataSource objectsForAdapter:self];
    if (!newObjects.count) { return; }
    
    [self updateObjects:newObjects
             dataSource:_dataSource];
    
    [_collectionView reloadData];
    [_collectionView.collectionViewLayout invalidateLayout];
    [_collectionView layoutIfNeeded];
    
    !completion ?: completion(YES);
}

#pragma mark - Lazy
- (CBPic2kerDelegateProxy *)delegateProxy {
    if (!_delegateProxy) {
        _delegateProxy = [[CBPic2kerDelegateProxy alloc] initWithCollectionViewTarget:_collectionViewDelegate
                                                                 scrollViewTarget:_scrollViewDelegate
                                                                              adapter:self];
    }
    return _delegateProxy;
}

- (CBPic2kerAdapterHelper *)adapterHelper {
    if (!_adapterHelper) {
        _adapterHelper = [[CBPic2kerAdapterHelper alloc] init];
    }
    return _adapterHelper;
}

@end
