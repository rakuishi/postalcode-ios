//
//  AdNavigationController.h
//  PostalCode
//
//  Created by OCHIISHI Koichiro on 10/9/13.
//  Copyright (c) 2013 OCHIISHI Koichiro. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AppTrackingTransparency/AppTrackingTransparency.h>

@interface MyNavigationController : UINavigationController

- (void)startLoading;
- (void)stopLoading;

@end
