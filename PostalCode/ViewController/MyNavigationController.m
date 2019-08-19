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

    self.navigationBar.tintColor = POSTALCODE_BASE_COLOR;
    self.tabBarController.tabBar.tintColor = POSTALCODE_BASE_COLOR;
    

    self.loadingView = [[UIView alloc] initWithFrame:[self loadingViewFrame]];
    if (@available(iOS 13.0, *)) {
        self.loadingView.backgroundColor = UIColor.systemBackgroundColor;
    } else {
        self.loadingView.backgroundColor = UIColor.whiteColor;
    }
    self.loadingView.alpha = 0.f;
    [self.view addSubview:self.loadingView];
    
    self.indicater = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.indicater.center = CGPointMake(self.loadingView.frame.size.width / 2.f, self.loadingView.frame.size.height / 2.f);
    [self.indicater startAnimating];
    [self.loadingView addSubview:self.indicater];
    
    self.adView = [[NADView alloc] initWithFrame:[self adViewFrame] isAdjustAdSize:true];
    [self.adView setNendID:NEND_API_KEY spotID:NEND_SPOT_ID];
    [self.adView setDelegate:self];
    [self.adView setBackgroundColor:[UIColor whiteColor]];
    if (@available(iOS 13.0, *)) {
        [self.adView setBackgroundColor:UIColor.systemBackgroundColor];
    } else {
        [self.adView setBackgroundColor:UIColor.whiteColor];
    }
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

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    self.loadingView.frame = [self loadingViewFrame];
    self.indicater.center = CGPointMake(self.loadingView.frame.size.width / 2.f, self.loadingView.frame.size.height / 2.f);
    self.adView.frame = [self adViewFrame];
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

#pragma

- (CGRect)loadingViewFrame
{
    CGRect bounds = [[UIScreen mainScreen] bounds];
    CGFloat statusBarHeight = 20.f;
    if (@available(iOS 11.0, *)) {
        UIWindow *window = UIApplication.sharedApplication.keyWindow;
        statusBarHeight = window.safeAreaInsets.top;
    }
    CGFloat y = statusBarHeight + self.navigationBar.frame.size.height + 1.f;

    return CGRectMake(0.f, y, bounds.size.width, bounds.size.height - y - 49.f);
}

- (CGRect)adViewFrame
{
    CGRect bounds = [[UIScreen mainScreen] bounds];
    UIEdgeInsets safaAreaInsets = UIEdgeInsetsZero;
    if (@available(iOS 11.0, *)) {
        UIWindow *window = UIApplication.sharedApplication.keyWindow;
        safaAreaInsets = window.safeAreaInsets;
    }

    // https://github.com/fan-ADN/nendSDK-iOS/wiki/About-Ad-Sizes
    CGFloat ratio = MIN(bounds.size.width / 320.f, 1.5f);
    CGFloat width = 320.f * ratio;
    CGFloat height = ratio * 50.f;
    CGFloat x = (bounds.size.width - width) / 2;
    CGFloat y = (self.tabBarController)
        ? bounds.size.height - safaAreaInsets.bottom - 49.f - height
        : bounds.size.height - safaAreaInsets.bottom - height;

    return CGRectMake(x, y, width, height);
}

@end
