// CBPic2kerController.m
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

#import <CBPic2ker/CBPic2kerController.h>
#import <CBPic2ker/CBPic2kerPhotoLibrary.h>
#import <CBPic2ker/UIColor+CBPic2ker.h>
#import <CBPic2ker/CBPick2kerPermissionView.h>
#import <CBPic2ker/CBPic2kerAlbumView.h>
#import <CBPic2ker/CBPic2kerAlbumModel.h>
#import <CBPic2ker/CBPic2kerCollectionView.h>
#import <CBPic2ker/CBPic2kerAdapter+collectionViewDelegate.h>
#import <CBPic2ker/CBPic2kerAssetSectionView.h>
#import <CBPic2ker/UIView+CBPic2ker.h>
#import <CBPic2ker/CBPic2kerAssetModel.h>

static CGFloat const kCBPic2kerControllerAlbumAnimationDuration = 0.25;

@interface CBPic2kerController () <CBPic2kerAdapterDataSource>

@property (nonatomic, strong, readwrite) CBPick2kerPermissionView *permissionView;
@property (nonatomic, strong, readwrite) CBPic2kerCollectionView *collectionView;
@property (nonatomic, strong, readwrite) CBPic2kerAlbumView *albumView;
@property (nonatomic, strong, readwrite) UILabel *titleLableView;

@property (nonatomic, strong, readwrite) CBPic2kerAdapter *adapter;

@property (nonatomic, strong, readwrite) NSMutableArray *albumDataArr;
@property (nonatomic, strong, readwrite) CBPic2kerAlbumModel *currentAlbumModel;
@property (nonatomic, strong, readwrite) NSMutableArray<CBPic2kerAssetModel *> *currentAlbumAssetsModelsArray;

@property (nonatomic, strong, readwrite) NSTimer *timer;

@property (nonatomic, strong, readwrite) CBPic2kerPhotoLibrary *photoLibrary;

@end

@implementation CBPic2kerController {
    CBPic2kerAssetSectionView *assetSectionView;
}

@synthesize currentAlbumModel = _currentAlbumModel;

#pragma mark - Internal.
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setUpNavigation];
    [self setViewsUp];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (![self.photoLibrary authorizationStatusAuthorized]) {
        [self.view addSubview:self.permissionView];
        [self.titleLableView setText:@"NO PERMISSION"];
        
        _timer = [NSTimer scheduledTimerWithTimeInterval:0.2
                                                  target:self
                                                selector:@selector(observeAuthrizationStatusChange)
                                                userInfo:nil
                                                 repeats:YES];
        } else {
            [self fetchDataWhenEntering];
    }
}

- (void)observeAuthrizationStatusChange {
    if ([[CBPic2kerPhotoLibrary sharedPhotoLibrary] authorizationStatusAuthorized]) {
        [self fetchDataWhenEntering];
        
        [self.permissionView removeFromSuperview];
        [_timer invalidate];
        _timer = nil;
    }
}

- (void)fetchDataWhenEntering {
    [self.titleLableView setText:@"Fetching ..."];
    
    [[CBPic2kerPhotoLibrary sharedPhotoLibrary] getCameraRollAlbumWithCompletion:^(CBPic2kerAlbumModel *model) {
        self.currentAlbumModel = model;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            !assetSectionView.albumButton ?: [assetSectionView.albumButton setTitle:_currentAlbumModel.name forState:UIControlStateNormal];
        });
        
        [self.titleLableView setText:@"Select Photos"];
    }];
    [[CBPic2kerPhotoLibrary sharedPhotoLibrary] getAllAlbumsWithCompletion:^(NSArray<CBPic2kerAlbumModel *> *models) {
        self.albumDataArr = [models mutableCopy];
        
        [self.view addSubview:self.albumView];
        [self.titleLableView setText:@"Select Photos"];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)setUpNavigation {
    [self setupNavigationBartitleLableView];

    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault
                                                animated:NO];
    
    NSMutableDictionary *itemStyleDic = [[NSMutableDictionary alloc] init];
    itemStyleDic[NSFontAttributeName] = [UIFont fontWithName:@"Euphemia-UCAS" size:15];
    UIBarButtonItem *cancelButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                                      target:self
                                                                                      action:@selector(backAction:)];
    UIBarButtonItem *userButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Use"
                                                                   style:UIBarButtonItemStylePlain
                                                                  target:self
                                                                  action:@selector(useAction:)];
    [userButtonItem setTitleTextAttributes:itemStyleDic forState:UIControlStateNormal];
    [cancelButtonItem setTitleTextAttributes:itemStyleDic forState:UIControlStateNormal];

    self.navigationItem.leftBarButtonItem = cancelButtonItem;
    self.navigationItem.rightBarButtonItem = userButtonItem;
    self.automaticallyAdjustsScrollViewInsets = NO;
    [[[self.navigationController.navigationBar subviews] objectAtIndex:0] setAlpha:0];
}

- (void)setViewsUp {
    [self.view setBackgroundColor:[UIColor whiteColor]];
    [self.view addSubview:self.collectionView];
    [self.adapter setDataSource:self];
}

- (void)backAction:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)useAction:(id)sender {
    
}

- (void)setCurrentAlbumModel:(CBPic2kerAlbumModel *)currentAlbumModel {
    _currentAlbumModel = currentAlbumModel;
    [[CBPic2kerPhotoLibrary sharedPhotoLibrary] getAssetsFromFetchResult:currentAlbumModel.result
                                                              completion:^(NSArray<CBPic2kerAssetModel *> *models) {
                                                                  _currentAlbumAssetsModelsArray = [models mutableCopy];
                                                                  [self.adapter reloadDataWithCompletion:nil];
                                                              }];
}

- (void)setupNavigationBartitleLableView {
    self.titleLableView = [[UILabel alloc] init];
    [self.titleLableView setFont:[UIFont fontWithName:@"AvenirNext-Medium" size:18]];
    [self.titleLableView setTextAlignment:NSTextAlignmentCenter];
    [self.titleLableView setTextColor:[UIColor lightGrayColor]];
    [self.titleLableView setText:@"Fetching ..."];
    
    self.navigationItem.titleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.titleLableView.sizeWidth, self.titleLableView.sizeHeight)];
    
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        self.titleLableView.frame = CGRectMake(0, [[UIApplication sharedApplication] statusBarFrame].size.height, self.navigationController.navigationBar.sizeWidth, self.navigationController.navigationBar.sizeHeight);
        weakSelf.titleLableView.frame = [weakSelf.view.window convertRect:weakSelf.titleLableView.frame toView:weakSelf.navigationItem.titleView];
        [weakSelf.navigationItem.titleView addSubview:weakSelf.titleLableView];
    });
}

- (CBPick2kerPermissionView *)permissionView {
    if (!_permissionView) {
        _permissionView = [[CBPick2kerPermissionView alloc] initWithFrame:CGRectMake(0, self.navigationController.navigationBar.sizeHeight + [[UIApplication sharedApplication] statusBarFrame].size.height, self.view.sizeWidth, self.view.sizeHeight - self.navigationController.navigationBar.sizeHeight - [[UIApplication sharedApplication] statusBarFrame].size.height) grantButtonAction:^{
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
        }];
    }
    return _permissionView;
}

- (CBPic2kerAlbumView *)albumView {
    if (!_albumView) {
        _albumView = [[CBPic2kerAlbumView alloc] initWithFrame:CGRectMake(8, self.view.frame.size.height, self.view.frame.size.width - 16, self.view.sizeHeight - self.collectionView.originUp) albumArray:_albumDataArr didSelectedAlbumBlock:^(CBPic2kerAlbumModel *model) {
            self.currentAlbumModel = model;
            
            !assetSectionView.albumButton ?: [assetSectionView.albumButton setTitle:model.name forState:UIControlStateNormal];
            
            [UIView animateWithDuration:kCBPic2kerControllerAlbumAnimationDuration
                             animations:^{
                                 self.albumView.frame = CGRectMake(self.albumView.originLeft, self.view.originDown, self.albumView.sizeWidth, self.albumView.sizeHeight);
                             }];
        }];;
    }
    return _albumView;
}

- (NSArray *)albumDataArr {
    if (!_albumDataArr) {
        _albumDataArr = [[NSMutableArray alloc] init];
    }
    return _albumDataArr;
}

- (CBPic2kerPhotoLibrary *)photoLibrary {
    _photoLibrary = [CBPic2kerPhotoLibrary sharedPhotoLibrary];
    return _photoLibrary;
}

- (CBPic2kerAlbumModel *)currentAlbumModel {
    if (!_currentAlbumModel) {
        _currentAlbumModel = [[CBPic2kerAlbumModel alloc] init];
    }
    return _currentAlbumModel;
}

- (NSMutableArray<CBPic2kerAssetModel *> *)currentAlbumAssetsModelsArray {
    if (!_currentAlbumAssetsModelsArray) {
        _currentAlbumAssetsModelsArray = [[NSMutableArray alloc] init];
    }
    return _currentAlbumAssetsModelsArray;
}

- (CBPic2kerCollectionView *)collectionView {
    if (!_collectionView) {
        _collectionView = [[CBPic2kerCollectionView alloc] initWithFrame:CGRectMake(0, self.navigationController.navigationBar.sizeHeight + [[UIApplication sharedApplication] statusBarFrame].size.height, self.view.sizeWidth, self.view.sizeHeight - self.navigationController.navigationBar.sizeHeight - [[UIApplication sharedApplication] statusBarFrame].size.height)];
        _collectionView.showsHorizontalScrollIndicator = YES;
        _collectionView.alwaysBounceVertical = YES;
        _collectionView.backgroundColor = [UIColor clearColor];
    }
    return _collectionView;
}

- (CBPic2kerAdapter *)adapter {
    if (!_adapter) {
        _adapter = [[CBPic2kerAdapter alloc] initWithViewController:self];
        _adapter.collectionView = self.collectionView;
    }
    return _adapter;
}

#pragma mark - Public Methods.
- (instancetype)init {
    return [self initWithDelegate:nil];
}

- (instancetype)initWithDelegate:(id<CBPickerControllerDelegate>)delegate {
    return [self initWithMaxSelectedImagesCount:0
                                       delegate:delegate];
}

- (instancetype)initWithMaxSelectedImagesCount:(NSInteger)maxSelectedImagesCount
                                      delegate:(id<CBPickerControllerDelegate>)delegate {
    return [self initWithMaxSelectedImagesCount:maxSelectedImagesCount
                                   columnNumber:3
                                       delegate:delegate];
}

- (instancetype)initWithMaxSelectedImagesCount:(NSInteger)maxSelectedImagesCount
                                  columnNumber:(NSInteger)columnNumber
                                      delegate:(id<CBPickerControllerDelegate>)delegate {
    self = [super init];
    if (self) {
        _maxSlectedImagesCount = maxSelectedImagesCount;
        _columnNumber = columnNumber;
        _pickerDelegate = delegate;
    }
    return self;
}

#pragma mark - Adapter DataSource
- (NSArray *)objectsForAdapter:(CBPic2kerAdapter *)adapter {
    return [NSArray arrayWithObjects:self.currentAlbumAssetsModelsArray, nil];
}

- (CBPic2kerSectionController *)adapter:(CBPic2kerAdapter *)adapter
             sectionControllerForObject:(id)object {
    if (!assetSectionView) {
        assetSectionView = [[CBPic2kerAssetSectionView alloc] initWithColumNumber:_columnNumber albumButtonTouchActionBlock:^(id albumButton) {
            [UIView animateWithDuration:kCBPic2kerControllerAlbumAnimationDuration
                             animations:^{
                                 self.albumView.frame = CGRectMake(self.albumView.originLeft, self.collectionView.originUp, self.albumView.sizeWidth, self.albumView.sizeHeight);
                             } completion:nil];
        } assetButtonTouchActionBlock:^(CBPic2kerAssetModel *model) {
            if ([self.photoLibrary.selectedAssetIdentifierArr containsObject:[(PHAsset *)model.asset localIdentifier]]) {
                [self.photoLibrary removeSelectedAssetWithIdentifier:[(PHAsset *)model.asset localIdentifier]];
            } else {
                [self.photoLibrary addSelectedAssetWithModel:model];
            }
            self.titleLableView.text = _photoLibrary.selectedAssetArr.count ? [NSString stringWithFormat:@"%lu Photos Selected", (unsigned long)_photoLibrary.selectedAssetArr.count] : @"Select Photos";
        }];
    }
    return assetSectionView;
}

@end

