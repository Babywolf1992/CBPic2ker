// CBPic2kerNavigationController.m
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

#import <CBPic2ker/CBPic2kerNavigationController.h>
#import <CBPic2ker/CBPic2kerController.h>

@interface CBPic2kerNavigationController () {
    CBPic2kerController *controller;
}

@end

@implementation CBPic2kerNavigationController

- (instancetype)initWithDelegate:(id<CBPickerControllerDelegate>)delegate {
    if (!controller) {
        controller = [[CBPic2kerController alloc] initWithDelegate:delegate];
    }
    self = [super initWithRootViewController:controller];
    return self;
}

- (instancetype)initWithMaxSelectedImagesCount:(NSInteger)maxSelectedImagesCount
                                      delegate:(id<CBPickerControllerDelegate>)delegate {
    self.maxSlectedImagesCount = maxSelectedImagesCount;
    return [self initWithDelegate:delegate];
}

- (instancetype)initWithMaxSelectedImagesCount:(NSInteger)maxSelectedImagesCount
                                  columnNumber:(NSInteger)columnNumber
                                      delegate:(id<CBPickerControllerDelegate>)delegate {
    self.columnNumber = columnNumber;
    return [self initWithMaxSelectedImagesCount:maxSelectedImagesCount
                                       delegate:delegate];
}

- (void)setMaxSlectedImagesCount:(NSInteger)maxSlectedImagesCount {
    _maxSlectedImagesCount = maxSlectedImagesCount;
    controller.maxSlectedImagesCount = maxSlectedImagesCount;
}

- (void)setColumnNumber:(NSInteger)columnNumber {
    _columnNumber = columnNumber;
    controller.columnNumber = columnNumber;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

- (BOOL)shouldAutorotate {
    return NO;
}

@end
