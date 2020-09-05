//
//  InfoViewController.m
//  PostalCode
//
//  Created by OCHIISHI Koichiro on 10/26/13.
//  Copyright (c) 2013 OCHIISHI Koichiro. All rights reserved.
//

#import "AboutViewController.h"

typedef NS_ENUM(NSUInteger, kSection) {
    kSectionAbout,
    kSectionFeedback,
    kSectionCount
};

@implementation AboutViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return kSectionCount;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == kSectionAbout) {
        return 4;
    }
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == kSectionAbout) {

        static NSString *CellIdentifier = @"AboutCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
        
        // Configure the cell...
        if (indexPath.row == 0) {
            cell.textLabel.text = @"バージョン";
            cell.detailTextLabel.text = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
            cell.accessoryType = UITableViewCellAccessoryNone;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        } else if (indexPath.row == 1) {
            cell.textLabel.text = @"郵便番号データ";
            cell.detailTextLabel.text = @"2020年8月31日";
            cell.accessoryType = UITableViewCellAccessoryNone;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        } else if (indexPath.row == 2) {
            cell.textLabel.text = @"開発";
            cell.detailTextLabel.text = @"rakuishi";
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.selectionStyle = UITableViewCellSelectionStyleDefault;
        } else {
            cell.textLabel.text = @"プライバシーポリシー";
            cell.detailTextLabel.text = @"";
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.selectionStyle = UITableViewCellSelectionStyleDefault;
        }
        
        return cell;

    } else {
        
        static NSString *CellIdentifier = @"FeedbackCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section == kSectionAbout && indexPath.row == 2) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://rakuishi.com"] options:@{} completionHandler:nil];
    } else if (indexPath.section == kSectionAbout && indexPath.row == 3) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://rakuishi.github.io/privacy-policy/postalcode.html"] options:@{} completionHandler:nil];
    } else if (indexPath.section == kSectionFeedback) {
        [self sendFeedback];
    }
}

#pragma mark -

- (void)sendFeedback
{
    MFMailComposeViewController *composeViewController = [MFMailComposeViewController new];
    composeViewController.mailComposeDelegate = self;
    
    NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    NSString *body = @"";
    body = [body stringByAppendingString:@"\n\n\n"];
    body = [body stringByAppendingFormat:@"Device: %@\n", [self platform]];
    body = [body stringByAppendingFormat:@"iOS: %@\n", [[UIDevice currentDevice] systemVersion]];
    body = [body stringByAppendingFormat:@"App: 郵便番号検索くん %@", version];
    
    [composeViewController setMessageBody:body isHTML:NO];
    [composeViewController setSubject:@"[郵便番号検索くん Feedback]"];
    [composeViewController setToRecipients:@[@"rakuishi@gmail.com"]];
    [self presentViewController:composeViewController animated:YES completion:nil];
}

- (NSString *)platform
{
    size_t size;
    sysctlbyname("hw.machine", NULL, &size, NULL, 0);
    char *machine = malloc(size);
    sysctlbyname("hw.machine", machine, &size, NULL, 0);
    NSString *platform = [NSString stringWithCString:machine encoding:NSUTF8StringEncoding];
    free(machine);
    
    return platform;
}

#pragma mark - MFMailComposeViewControllerDelegate

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - IBOutlet

- (IBAction)dismissViewController:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
