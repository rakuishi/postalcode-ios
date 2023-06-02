//
//  DetailViewController.h
//  PostalCode
//
//  Created by OCHIISHI Koichiro on 10/10/13.
//  Copyright (c) 2013 OCHIISHI Koichiro. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import "PostalCodeRepository.h"
#import "MyTableViewController.h"
#import "RightDetailTableViewCell.h"

@interface DetailViewController : MyTableViewController <MFMailComposeViewControllerDelegate>

@property (nonatomic, strong) PostalCodeModel *postalCodeModel;

@end
