//
//  SelectViewController.h
//  PostalCode
//
//  Created by OCHIISHI Koichiro on 10/22/13.
//  Copyright (c) 2013 OCHIISHI Koichiro. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PostalCodeRepository.h"
#import "PostalCode-Swift.h"
#import "BaseTableViewController.h"

typedef NS_ENUM(NSUInteger, SelectedAddress) {
    SelectedAddressState    = 0,    // 都道府県
    SelectedAddressCityTown = 1,    // 市町村
    SelectedAddressStreet   = 2,    // 区群
};

@interface SelectViewController : BaseTableViewController

@property (nonatomic, assign) SelectedAddress selectedAddress;
@property (nonatomic, strong) NSString *selectedState;
@property (nonatomic, strong) NSString *selectedCityTown;

@end
