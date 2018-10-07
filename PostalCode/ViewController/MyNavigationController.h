//
//  AdNavigationController.h
//  PostalCode
//
//  Created by OCHIISHI Koichiro on 10/9/13.
//  Copyright (c) 2013 OCHIISHI Koichiro. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <NendAd/NADView.h>

@interface MyNavigationController : UINavigationController <NADViewDelegate>

- (void)startLoading;
- (void)stopLoading;

@end
