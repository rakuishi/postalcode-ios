//
//  BaseTabBarController.m
//  PostalCode
//
//  Created by OCHIISHI Koichiro on 2013/10/22.
//  Copyright (c) 2013年 OCHIISHI Koichiro. All rights reserved.
//

#import "BaseTabBarController.h"
#import "PostalCode-Swift.h"

@implementation BaseTabBarController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleSearchQuery:)
                                                 name:@"handleSearchQuery"
                                               object:nil];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:@"handleSearchQuery"
                                                  object:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - SearchViewController

- (void)handleSearchQuery:(NSNotification *)notification
{
    self.selectedIndex = 1;
    BaseNavigationController *navigationController = (BaseNavigationController *)self.viewControllers[1];
    [navigationController popToRootViewControllerAnimated:NO];
    [self performSelector:@selector(afterDelayHandleSearchQuery:) withObject:notification.object[@"query"] afterDelay:0.f];
}

- (void)afterDelayHandleSearchQuery:(NSString *)query
{
    BaseNavigationController *navigationController = (BaseNavigationController *)self.viewControllers[1];
    SearchViewController *viewController = [navigationController.viewControllers firstObject];
    [viewController searchQuery:query];
}

@end
