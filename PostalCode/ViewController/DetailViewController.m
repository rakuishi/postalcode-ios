//
//  DetailViewController.m
//  PostalCode
//
//  Created by OCHIISHI Koichiro on 10/10/13.
//  Copyright (c) 2013 OCHIISHI Koichiro. All rights reserved.
//

#import "DetailViewController.h"
#import "PostalCode-Swift.h"

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

    self.tableView.estimatedRowHeight = 44.f;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    
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

- (NSString *)getPrimaryLabelText:(NSIndexPath *)indexPath
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

- (NSString *)getSecondaryLabelText:(NSIndexPath *)indexPath
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

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == kSectionInfo) {
        
        static NSString *CellIdentifier = @"InfoCell";
        RightDetailTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
        
        // Configure the cell...
        cell.primaryLabel.text = [self getPrimaryLabelText:indexPath];
        cell.secondaryLabel.text = [self getSecondaryLabelText:indexPath];
        
        return cell;
        
    } else {
        
        static NSString *CellIdentifier = @"ActionCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
        
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

- (nullable UIContextMenuConfiguration *)tableView:(UITableView *)tableView contextMenuConfigurationForRowAtIndexPath:(nonnull NSIndexPath *)indexPath point:(CGPoint)point
{
    if (indexPath.section != kSectionInfo) return nil;
    
    return [UIContextMenuConfiguration configurationWithIdentifier:nil
                                                   previewProvider:nil
                                                    actionProvider:^UIMenu *(NSArray<UIMenuElement *> *suggestedActions) {

            UIAction *action = [UIAction actionWithTitle:@"コピー"
                                                    image:[UIImage systemImageNamed:@"doc.on.doc"]
                                               identifier:nil
                                                  handler:^(__kindof UIAction * _Nonnull action) {
                RightDetailTableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
                UIPasteboard *board = [UIPasteboard generalPasteboard];
                [board setValue:cell.secondaryLabel.text forPasteboardType:@"public.utf8-plain-text"];
            }];

            return [UIMenu menuWithTitle:@"" children:@[action]];
        }];
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
