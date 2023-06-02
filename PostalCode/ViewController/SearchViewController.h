//
//  SearchViewController.h
//  PostalCode
//
//  Created by OCHIISHI Koichiro on 10/10/13.
//  Copyright (c) 2013 OCHIISHI Koichiro. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PostalCodeRepository.h"
#import "DetailViewController.h"
#import "BaseTableViewController.h"

@interface SearchViewController : BaseTableViewController <UISearchBarDelegate>

- (void)searchQuery:(NSString *)query;

@end
