//
//  FavoriteViewController.m
//  PostalCode
//
//  Created by OCHIISHI Koichiro on 10/10/13.
//  Copyright (c) 2013 OCHIISHI Koichiro. All rights reserved.
//

#import "FavoriteViewController.h"

@interface FavoriteViewController ()

@property (nonatomic, strong) NSMutableArray *objects;
@property (nonatomic, strong) UIBarButtonItem *deleteButtonItem;

@end

@implementation FavoriteViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tableView.estimatedRowHeight = 44.f;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    
    self.deleteButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"消去"
                                                             style:UIBarButtonItemStylePlain
                                                            target:self
                                                            action:@selector(deleteAllData)];
    self.navigationItem.leftBarButtonItem = self.deleteButtonItem;

    [self reloadAllData];
}

- (void)viewWillAppear:(BOOL)animated
{
    // UITableViewController は clearsSelectionOnViewWillAppear により、
    // super 時に、選択中の Row を非選択状態に戻すため、super 前に選択中の Row があるかを取得しておく
    bool hasSelectedRow = self.tableView.indexPathForSelectedRow != nil;
    [super viewWillAppear:animated];

    // self.tableView deselectRowAtIndexPath: animated: を有効にする為に、
    // 他 UITabBarController.viewControllers から選択された場合のみ、reload 処理を行う
    if (!hasSelectedRow) {
        [self reloadAllData];
    }
    
    self.deleteButtonItem.enabled = (self.objects.count) ? YES : NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -

- (void)reloadAllData
{
    self.objects = [FavoriteRepository getFavorites];
    [self.tableView reloadData];
}

- (void)deleteAllData
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];

    [alertController addAction:[UIAlertAction actionWithTitle:@"すべての項目を削除" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
        [FavoriteRepository deleteAllFavorite];
        [self reloadAllData];
        self.deleteButtonItem.enabled = NO;
    }]];
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"キャンセル" style:UIAlertActionStyleCancel handler:nil]];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

- (NSString *)textLabelText:(NSIndexPath *)indexPath
{
    NSData *data = self.objects[indexPath.row];
    PostalCodeModel *model = (PostalCodeModel *)[NSKeyedUnarchiver unarchiveObjectWithData:data];
    return [NSString stringWithFormat:@"%@ %@ %@", model.stateK, model.cityTownK, model.streetK];
}

- (NSString *)detailTextLabelText:(NSIndexPath *)indexPath
{
    NSData *data = self.objects[indexPath.row];
    PostalCodeModel *model = (PostalCodeModel *)[NSKeyedUnarchiver unarchiveObjectWithData:data];
    
    NSMutableString *postalCode = [NSMutableString stringWithString:model.postalCode];
    [postalCode insertString:@"-" atIndex:3];
    
    return  [postalCode copy];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.objects.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    cell.textLabel.text = [self textLabelText:indexPath];
    cell.detailTextLabel.text = [self detailTextLabelText:indexPath];
    
    return cell;
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView beginUpdates];

        [FavoriteRepository deleteFavoritePostalCodeModel:indexPath.row];
        
        [self.objects removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
        
        [tableView endUpdates];
    }
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSData *data = self.objects[indexPath.row];
    PostalCodeModel *model = (PostalCodeModel *)[NSKeyedUnarchiver unarchiveObjectWithData:data];
    
    DetailViewController *viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"DetailViewController"];
    viewController.postalCodeModel = model;
    [self.navigationController pushViewController:viewController animated:YES];
}

@end
