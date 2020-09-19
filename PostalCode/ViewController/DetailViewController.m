//
//  DetailViewController.m
//  PostalCode
//
//  Created by OCHIISHI Koichiro on 10/10/13.
//  Copyright (c) 2013 OCHIISHI Koichiro. All rights reserved.
//

#import "DetailViewController.h"

typedef NS_ENUM(NSUInteger, kSection) {
    kSectionInfo,
    kSectionAction,
    kSectionCount,
};

@interface DetailViewController ()

@end

@implementation DetailViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if ([self.postalCodeModel.streetK length]) {
        self.title = self.postalCodeModel.streetK;
    } else {
        self.title = self.postalCodeModel.cityTownK;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -

- (NSString *)textLabelText:(NSIndexPath *)indexPath
{
    switch (indexPath.row) {
        case 0:
            return @"郵便番号";
        case 1:
            return @"住所";
        case 2:
            return @"読み";
        default:
            return @"";
    }
}

- (NSString *)detailTextLabelText:(NSIndexPath *)indexPath
{
    switch (indexPath.row) {
        case 0: {
            NSMutableString *postalCode = [NSMutableString stringWithString:self.postalCodeModel.postalCode];
            [postalCode insertString:@"-" atIndex:3];
            return [postalCode copy];
        }
        case 1:
            return [NSString stringWithFormat:@"%@ %@ %@", self.postalCodeModel.stateK, self.postalCodeModel.cityTownK, self.postalCodeModel.streetK];
        case 2:
            return [NSString stringWithFormat:@"%@ %@ %@", self.postalCodeModel.stateH, self.postalCodeModel.cityTownH, self.postalCodeModel.streetH];
        default:
            return @"";
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return kSectionCount;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 3;
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    return (section == kSectionInfo) ? @"項目を長押しでコピーできます。" : nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == kSectionInfo) {
        return [DynamicTypeHelper heightWithStyle:UITableViewCellStyleValue2
                                              text:[self textLabelText:indexPath]
                                        detailText:[self detailTextLabelText:indexPath]];
    } else {
        return [DynamicTypeHelper heightWithStyle:UITableViewCellStyleDefault
                                              text:@"お気に入りに追加する"
                                        detailText:nil];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == kSectionInfo) {
        
        static NSString *CellIdentifier = @"InfoCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
        cell = [DynamicTypeHelper setupDynamicTypeCell:cell style:UITableViewCellStyleValue2];
        
        // Configure the cell...
        cell.textLabel.text = [self textLabelText:indexPath];
        cell.detailTextLabel.text = [self detailTextLabelText:indexPath];
        
        return cell;
        
    } else {
        
        static NSString *CellIdentifier = @"ActionCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
        cell = [DynamicTypeHelper setupDynamicTypeCell:cell style:UITableViewCellStyleDefault];
        
        // Configure the cell...
        switch (indexPath.row) {
            case 0:
                cell.textLabel.text = @"地図で確認する";
                break;
            case 1:
                cell.textLabel.text = @"メールで送信する";
                break;
            default:
                cell.textLabel.text = @"お気に入りに追加する";
                break;
        }
        
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section == kSectionAction) {

        switch (indexPath.row) {
            case 0:
                [self jumpMap];
                break;
            case 1:
                [self sendMail];
                break;
            case 2:
                [self addFavorite];
                break;
        }
    }
}

- (BOOL)tableView:(UITableView *)tableView shouldShowMenuForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return (indexPath.section == kSectionInfo) ? YES : NO;
}

- (BOOL)tableView:(UITableView *)tableView canPerformAction:(SEL)action forRowAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender
{
    if (action == @selector(copy:)) {
        return YES;
    }
    return NO;
}

- (void)tableView:(UITableView *)tableView performAction:(SEL)action forRowAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    UIPasteboard *board = [UIPasteboard generalPasteboard];
    [board setValue:cell.detailTextLabel.text forPasteboardType:@"public.utf8-plain-text"];
}

#pragma mark -

- (void)jumpMap
{
    NSString *q = [NSString stringWithFormat:@"%@%@%@", self.postalCodeModel.stateK, self.postalCodeModel.cityTownK, self.postalCodeModel.streetK];
    q = [q stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet alphanumericCharacterSet]];
    NSString *url;

    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"comgooglemaps://"]] == TRUE) {
        url = [NSString stringWithFormat:@"comgooglemaps://?q=%@", q];
    } else {
        url = [NSString stringWithFormat:@"http://maps.apple.com/?q=%@", q];
    }
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url] options:@{} completionHandler:nil];
}

- (void)sendMail
{
    MFMailComposeViewController *viewController = [MFMailComposeViewController new];
    viewController.mailComposeDelegate = self;
    
    NSMutableString *postalCode = [NSMutableString stringWithString:self.postalCodeModel.postalCode];
    [postalCode insertString:@"-" atIndex:3];
    
    NSString *body = [NSString stringWithFormat:@"郵便番号：%@\n住所：%@ %@ %@", [postalCode copy], self.postalCodeModel.stateK, self.postalCodeModel.cityTownK, self.postalCodeModel.streetK];
    
    [viewController setMessageBody:body isHTML:NO];
    [self presentViewController:viewController animated:YES completion:nil];
}

- (void)addFavorite
{
    BOOL isAlreadyExist = [FavoriteRepository isExistPostalCodeModel:self.postalCodeModel];
    if (isAlreadyExist == NO) {
        [FavoriteRepository addFavoritePostalCodeModel:self.postalCodeModel];
    }
    
    NSString *address = [NSString stringWithFormat:@"%@ %@ %@", self.postalCodeModel.stateK, self.postalCodeModel.cityTownK, self.postalCodeModel.streetK];
    NSString *message = (isAlreadyExist) ? [NSString stringWithFormat:@"\"%@\"は お気に入りに登録されています", address] : [NSString stringWithFormat:@"\"%@\"が お気に入りに登録されました", address];
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"確認" message:message preferredStyle:UIAlertControllerStyleAlert];

    [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
    
    [self presentViewController:alertController animated:YES completion:nil];

}

#pragma mark - MFMailComposeViewControllerDelegate

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
