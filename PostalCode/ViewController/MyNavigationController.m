//
//  AdNavigationController.m
//  PostalCode
//
//  Created by OCHIISHI Koichiro on 10/9/13.
//  Copyright (c) 2013 OCHIISHI Koichiro. All rights reserved.
//

#import "MyNavigationController.h"

@interface MyNavigationController ()

@property (nonatomic, strong) NADView *adView;
@property (nonatomic, strong) UIView *loadingView;
@property (nonatomic, strong) UIActivityIndicatorView *indicater;

@end

@implementation MyNavigationController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.

    // UINavigationBar の 下 1px の黒線を削除する
    // for (UIView *subview in self.navigationBar.subviews) {
    //     for (UIView *subsubview in subview.subviews) {
    //         if ([subsubview isKindOfClass:[UIImageView class]]) {
    //             // [subsubview removeFromSuperview];
    //             subsubview.hidden = YES;
    //             break;
    //         }
    //     }
    // }
    
    // id UINavigationBarAppearanceProxy = [UINavigationBar appearanceWhenContainedIn:[MyNavigationController class], nil];
    // NSDictionary *attributes = @{NSForegroundColorAttributeName:[UIColor whiteColor]};
    // [UINavigationBarAppearanceProxy setTitleTextAttributes:attributes];
    
    self.navigationBar.tintColor = POSTALCODE_BASE_COLOR;
    // self.navigationBar.translucent = NO;
    self.tabBarController.tabBar.tintColor = POSTALCODE_BASE_COLOR;
    // self.tabBarController.tabBar.translucent = NO;
    
    CGRect bounds = [[UIScreen mainScreen] bounds];
    
    self.loadingView = [[UIView alloc] initWithFrame:CGRectMake(0.f, 65.f, bounds.size.width, bounds.size.height - 65.f - 49.f)];
    self.loadingView.backgroundColor = [UIColor whiteColor];
    self.loadingView.alpha = 0.f;
    [self.view addSubview:self.loadingView];
    
    self.indicater = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.indicater.center = CGPointMake(self.loadingView.frame.size.width / 2.f, self.loadingView.frame.size.height / 2.f);
    [self.indicater startAnimating];
    [self.loadingView addSubview:self.indicater];
    
    CGFloat x = 0;
    CGFloat adHeight = bounds.size.width / 320.f * 50.f;
    CGFloat y = (self.tabBarController) ? bounds.size.height - 49.f - adHeight : bounds.size.height - adHeight;
    
    self.adView = [[NADView alloc] initWithFrame:CGRectMake(x, y, 320.f, 50.f) isAdjustAdSize:true];
    [self.adView setNendID:NEND_API_KEY spotID:NEND_SPOT_ID];
    [self.adView setDelegate:self];
    [self.adView setBackgroundColor:[UIColor whiteColor]];
    [self.adView load];
    [self.view addSubview:self.adView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (self.adView) {
        [self.adView resume];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    if (self.adView) {
        [self.adView pause];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    [self.adView setDelegate:nil];
    self.adView = nil;
}

#pragma mark -

- (void)startLoading
{
    [UIView animateWithDuration:0.2f animations:^{
        self.loadingView.alpha = 1.f;
    }];
}

- (void)stopLoading
{
    [UIView animateWithDuration:0.2f animations:^{
        self.loadingView.alpha = 0.f;
    }];
}

#pragma mark - NADViewDelegate

- (void)nadViewDidFinishLoad:(NADView *)adView
{
    // ...
}

@end
