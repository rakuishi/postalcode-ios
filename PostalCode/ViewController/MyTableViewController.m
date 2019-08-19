//
//  MyTableViewController.m
//  PostalCode
//
//  Created by OCHIISHI Koichiro on 4/5/14.
//  Copyright (c) 2014 OCHIISHI Koichiro. All rights reserved.
//

#import "MyTableViewController.h"

@implementation MyTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    CGRect bounds = [[UIScreen mainScreen] bounds];
    CGFloat adHeight = bounds.size.width / 320.f * 50.f;
    
    self.tableView.contentInset = UIEdgeInsetsMake(0.f, 0.f, adHeight, 0.f);
    self.tableView.scrollIndicatorInsets = UIEdgeInsetsMake(0.f, 0.f, adHeight, 0.f);
    self.tableView.sectionIndexColor = POSTALCODE_BASE_COLOR;
    
    if (@available(iOS 13.0, *)) {
        self.tableView.sectionIndexBackgroundColor = [UIColor.systemBackgroundColor colorWithAlphaComponent:0.5f];
    } else {
        self.tableView.sectionIndexBackgroundColor = [UIColor.whiteColor colorWithAlphaComponent:0.5f];
    }

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(preferredContentSizeChanged:)
                                                 name:UIContentSizeCategoryDidChangeNotification
                                               object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow]
                                  animated:YES];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIContentSizeCategoryDidChangeNotification
                                                  object:nil];
}

- (void)preferredContentSizeChanged:(NSNotification *)notification
{
    [self.tableView reloadData];
}

@end
