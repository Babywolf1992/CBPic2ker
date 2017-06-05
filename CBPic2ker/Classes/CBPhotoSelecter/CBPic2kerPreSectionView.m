// CBPic2kerPreSectionView.m
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

#import <CBPic2ker/CBPic2kerPreSectionView.h>
#import <CBPic2ker/CBPic2kerController.h>
#import <CBPic2ker/CBPic2kerPreSectionViewCell.h>

@interface CBPic2kerPreSectionView()

@property (nonatomic, strong, readwrite) NSMutableArray *currentSelectedPhotosArr;

@end

@implementation CBPic2kerPreSectionView

- (UIEdgeInsets)inset {
    if (_currentSelectedPhotosArr.count == 1) {
        return UIEdgeInsetsMake(2, self.collectionContext.containerSize.width * 0.125, 2, 2);
    } else {
        return UIEdgeInsetsMake(2, 2, 2, 2);
    }
}

- (CGFloat)minimumLineSpacing {
    return 2;
}

- (CGSize)sizeForItemAtIndex:(NSInteger)index {
    return CGSizeMake(self.collectionContext.containerSize.width * 0.75, self.collectionContext.containerSize.height - 4);
}

- (NSInteger)numberOfItems {
    return _currentSelectedPhotosArr.count;
}

- (void)didUpdateToObject:(id)object {
    _currentSelectedPhotosArr = object;
}

- (UICollectionViewCell *)cellForItemAtIndex:(NSInteger)index {
    CBPic2kerPreSectionViewCell *cell = [self.collectionContext dequeueReusableCellOfClass:[CBPic2kerPreSectionViewCell class]
                                                                      forSectionController:self
                                                                                   atIndex:index];
    if (index < _currentSelectedPhotosArr.count) {
        [cell configureWithAssetModel:_currentSelectedPhotosArr[index] selectedActionBlock:^(id model) {
            
        }];
    }
    return cell;
}

- (void)didSelectItemAtIndex:(NSInteger)index {
}

@end
