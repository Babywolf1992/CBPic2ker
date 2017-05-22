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
#import <CBPic2ker/CBPic2kerTitleView.h>
#import <CBPic2ker/CBPic2kerAlbumView.h>
#import <CBPic2ker/CBPic2kerAlbumModel.h>
#import <CBPic2ker/CBPic2kerCollectionView.h>
#import <CBPic2ker/CBPic2kerAdapter+collectionViewDelegate.h>
#import <CBPic2ker/CBPic2kerAssetSectionView.h>

static CGFloat const kCBPic2kerControllerAlbumAnimationDuration = 0.25;

@interface CBPic2kerController () <CBPic2kerAdapterDataSource>

@property (nonatomic, strong, readwrite) CBPick2kerPermissionView *permissionView;
@property (nonatomic, strong, readwrite) CBPic2kerCollectionView *collectionView;
@property (nonatomic, strong, readwrite) CBPic2kerTitleView *titleView;
@property (nonatomic, strong, readwrite) CBPic2kerAlbumView *albumView;

@property (nonatomic, strong, readwrite) CBPic2kerAdapter *adapter;

@property (nonatomic, strong, readwrite) NSMutableArray *albumDataArr;
@property (nonatomic, strong, readwrite) CBPic2kerAlbumModel *currentAlbumModel;
@property (nonatomic, strong, readwrite) NSMutableArray<CBPic2kerAssetModel *> *currentAlbumAssetsModelsArray;

@property (nonatomic, strong, readwrite) NSTimer *timer;

@end

@implementation CBPic2kerController

@synthesize currentAlbumModel = _currentAlbumModel;

#pragma mark - Internal.
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setUpNavigation];
    [self setViewsUp];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (![[CBPic2kerPhotoLibrary sharedPhotoLibrary] authorizationStatusAuthorized]) {
        [self.view addSubview:self.permissionView];
        [self.titleView hiddenImageViewWithTitle:@"NO PERMISSION"];
        
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
    [self.titleView hiddenImageViewWithTitle:@"Fetching ..."];
    
    [[CBPic2kerPhotoLibrary sharedPhotoLibrary] getCameraRollAlbumWithCompletion:^(CBPic2kerAlbumModel *model) {
        [self.titleView hiddenImageViewWithTitle:model.name];
        
        self.currentAlbumModel = model;
    }];
    
    [[CBPic2kerPhotoLibrary sharedPhotoLibrary] getAllAlbumsWithCompletion:^(NSArray<CBPic2kerAlbumModel *> *models) {
        [self.titleView unHiddenImageViewWithTitle:self.currentAlbumModel.name];
        
        _albumDataArr = [models mutableCopy];
        
        [self.view addSubview:self.albumView];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)setUpNavigation {
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent
                                                animated:NO];
    
    [self setupNavigationBarTitleView];
    
    NSMutableDictionary *itemStyleDic = [[NSMutableDictionary alloc] init];
    itemStyleDic[NSFontAttributeName] = [UIFont boldSystemFontOfSize:18.f];
    itemStyleDic[NSForegroundColorAttributeName] = [UIColor colorWithRed:(39 / 255.0) green:(164 / 255.0)  blue:(210 / 255.0) alpha:1.0];
    
    UIBarButtonItem *cancelButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                                      target:self
                                                                                      action:@selector(backAction:)];
    [cancelButtonItem setTitleTextAttributes:itemStyleDic forState:UIControlStateNormal];

    self.navigationItem.leftBarButtonItem = cancelButtonItem;
    
    UIBarButtonItem *userButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Use"
                                                                   style:UIBarButtonItemStylePlain
                                                                  target:self
                                                                  action:@selector(useAction:)];
    [userButtonItem setTitleTextAttributes:itemStyleDic forState:UIControlStateNormal];

    self.navigationItem.rightBarButtonItem = userButtonItem;
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:(34 / 255.0) green:(34 / 255.0)  blue:(34 / 255.0) alpha:1.0];
}

- (void)setViewsUp {
    [self.view setBackgroundColor:[UIColor colorWithRed:(34/255.0) green:(34/255.0)  blue:(34/255.0) alpha:1.0]];
    
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

- (void)setupNavigationBarTitleView {
    _titleView = [[CBPic2kerTitleView alloc] initWithFrame:CGRectMake(0, 0, self.navigationController.navigationBar.bounds.size.width, self.navigationController.navigationBar.bounds.size.height) selectedBlock:^{
        [UIView setAnimationDuration:kCBPic2kerControllerAlbumAnimationDuration];
        [UIView animateWithDuration:0
                         animations:^{
                 self.albumView.center = CGPointMake(self.albumView.center.x, self.view.center.y + (self.navigationController.navigationBar.frame.size.height + [[UIApplication sharedApplication] statusBarFrame].size.height) / 2);
             } completion:nil];
    } unSelectedBlock:^{
        [UIView setAnimationDuration:kCBPic2kerControllerAlbumAnimationDuration];
        [UIView animateWithDuration:0
                         animations:^{
                             self.albumView.center = CGPointMake(self.albumView.center.x, self.view.frame.size.height + self.albumView.frame.size.height);
                         }];
    }];;
    
    [_titleView.navigationBarTitleButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_titleView.navigationBarTitleButton setTitle:@"Fetching ..." forState:UIControlStateNormal];
    
    self.navigationItem.titleView = _titleView;
}

- (CBPick2kerPermissionView *)permissionView {
    if (!_permissionView) {
        _permissionView = [[CBPick2kerPermissionView alloc] initWithFrame:CGRectMake(0, self.navigationController.navigationBar.frame.size.height + [[UIApplication sharedApplication] statusBarFrame].size.height, self.view.frame.size.width, self.view.frame.size.height - self.navigationController.navigationBar.frame.size.height - [[UIApplication sharedApplication] statusBarFrame].size.height) grantButtonAction:^{
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
        }];
    }
    return _permissionView;
}

- (CBPic2kerAlbumView *)albumView {
    if (!_albumView) {
        _albumView = [[CBPic2kerAlbumView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height, self.view.frame.size.width, self.view.frame.size.height - self.navigationController.navigationBar.frame.size.height - [[UIApplication sharedApplication] statusBarFrame].size.height) albumArray:_albumDataArr didSelectedAlbumBlock:^(CBPic2kerAlbumModel *model) {
            [self.titleView navigationBarTitleButtonAction:nil];
            
            self.currentAlbumModel = model;
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
        _collectionView = [[CBPic2kerCollectionView alloc] initWithFrame:CGRectMake(0, self.navigationController.navigationBar.frame.size.height + [[UIApplication sharedApplication] statusBarFrame].size.height, self.view.frame.size.width, self.view.frame.size.height - self.navigationController.navigationBar.frame.size.height - [[UIApplication sharedApplication] statusBarFrame].size.height)];
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
    return [[CBPic2kerAssetSectionView alloc] initWithColumNumber:_columnNumber];
}

#pragma mark - Orientation
-(UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

- (BOOL)shouldAutorotate {
    return NO;
}

@end

