//
//  BaseNavigationController.m
//  PostalCode
//
//  Created by OCHIISHI Koichiro on 10/9/13.
//  Copyright (c) 2013 OCHIISHI Koichiro. All rights reserved.
//

#import "BaseNavigationController.h"
@import GoogleMobileAds;

@interface BaseNavigationController ()

@property (nonatomic, strong) GADBannerView *bannerView;
@property (nonatomic, strong) UIView *loadingView;
@property (nonatomic, strong) UIActivityIndicatorView *indicater;

@end

@implementation BaseNavigationController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.

    self.navigationBar.tintColor = POSTALCODE_BASE_COLOR;
    self.tabBarController.tabBar.tintColor = POSTALCODE_BASE_COLOR;

    self.loadingView = [[UIView alloc] initWithFrame:[self loadingViewFrame]];
    self.loadingView.alpha = 0.f;
    [self.view addSubview:self.loadingView];
    
    self.indicater = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleMedium];
    self.indicater.center = CGPointMake(self.loadingView.frame.size.width / 2.f, self.loadingView.frame.size.height / 2.f);
    [self.indicater startAnimating];
    [self.loadingView addSubview:self.indicater];
    
    self.bannerView = [[GADBannerView alloc] initWithFrame:[self adViewFrame]];
    self.bannerView.adUnitID = @"ca-app-pub-9983442877454265/2956248829";
    self.bannerView.rootViewController = self;
    [self.view addSubview:self.bannerView];
    [self.bannerView loadRequest:[GADRequest request]];
    
    [self requestTrackingAuthorizationIfPossible];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    self.loadingView.frame = [self loadingViewFrame];
    self.indicater.center = CGPointMake(self.loadingView.frame.size.width / 2.f, self.loadingView.frame.size.height / 2.f);
    self.bannerView.frame = [self adViewFrame];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    self.bannerView = nil;
}

- (void)requestTrackingAuthorizationIfPossible
{
    if (@available(iOS 14.0, *)) {
        switch ([ATTrackingManager trackingAuthorizationStatus]) {
            case ATTrackingManagerAuthorizationStatusNotDetermined:
                [ATTrackingManager requestTrackingAuthorizationWithCompletionHandler: ^(ATTrackingManagerAuthorizationStatus status) {
                }];
                break;
            default:
                break;
        }
    }
}

#pragma mark - Loading

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

- (CGRect)loadingViewFrame
{
    CGRect bounds = [[UIScreen mainScreen] bounds];
    CGFloat statusBarHeight = 20.f;
    UIEdgeInsets safeAreaInsets = [self getSafeAreaInsets];
    statusBarHeight = safeAreaInsets.top;
    CGFloat y = statusBarHeight + self.navigationBar.frame.size.height + 1.f;

    return CGRectMake(0.f, y, bounds.size.width, bounds.size.height - y - 49.f);
}

- (CGRect)adViewFrame
{
    CGRect bounds = [[UIScreen mainScreen] bounds];
    UIEdgeInsets safeAreaInsets = [self getSafeAreaInsets];

    CGFloat ratio = MIN(bounds.size.width / 320.f, 1.5f);
    CGFloat width = 320.f * ratio;
    CGFloat height = ratio * 50.f;
    CGFloat x = (bounds.size.width - width) / 2;
    CGFloat y = (self.tabBarController)
        ? bounds.size.height - safeAreaInsets.bottom - 49.f - height
        : bounds.size.height - safeAreaInsets.bottom - height;

    return CGRectMake(x, y, width, height);
}

- (UIEdgeInsets )getSafeAreaInsets
{
    NSArray *scenes = [UIApplication.sharedApplication connectedScenes].allObjects;
    if ([scenes.firstObject isKindOfClass:[UIWindowScene class]]) {
        UIWindowScene *scene = (UIWindowScene *)scenes.firstObject;
        return scene.windows.firstObject.safeAreaInsets;
    }

    return UIEdgeInsetsZero;
}

@end
