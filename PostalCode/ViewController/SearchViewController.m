//
//  SearchViewController.m
//  PostalCode
//
//  Created by OCHIISHI Koichiro on 10/10/13.
//  Copyright (c) 2013 OCHIISHI Koichiro. All rights reserved.
//

#import "SearchViewController.h"

@interface SearchViewController ()

@property (nonatomic, strong) UISearchBar *searchBar;
@property (nonatomic, strong) NSMutableArray *objects; // 都道府県別配列の中に PostalCodeModel の配列
@property (nonatomic, strong) NSMutableArray *sectionIndexTitles;

@end

@implementation SearchViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.tableView.estimatedRowHeight = 44.f;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    self.tableView.sectionIndexTrackingBackgroundColor = [UIColor colorWithRed:206.f/255.f green:203.f/255.f blue:198.f/255.f alpha:.2f];

    self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectZero];
    self.searchBar.delegate = self;
    self.searchBar.placeholder = @"1600000, 新宿区";
    self.searchBar.searchBarStyle = UISearchBarStyleDefault;
    self.searchBar.tintColor = POSTALCODE_BASE_COLOR;
    for (UIView *subview in self.searchBar.subviews) {
        for (UIView *subsubview in subview.subviews) {
            if ([subsubview isKindOfClass:[UITextField class]]) {
                UITextField *textField = (UITextField *)subsubview;
                textField.font = [UIFont systemFontOfSize:16.f];
                textField.backgroundColor = [UIColor colorWithRed:227/255.f green:228.f/255.f blue:230.f/255.f alpha:1.f];
                break;
            }
        }
    }

    self.navigationItem.titleView = self.searchBar;
    self.title = @"検索";
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UISearchBarDelegate

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
    [self searchQuery:searchBar.text];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    if (searchText.length == 0) {
        self.objects = [NSMutableArray new];
        self.sectionIndexTitles = [NSMutableArray new];
        [self.tableView reloadData];
    }
}

#pragma mark -

- (void)searchQuery:(NSString *)query
{
    [self.searchBar setText:query];
    
    // 郵便番号のハイフンを消去
    query = [query stringByReplacingOccurrencesOfString:@"-" withString:@""];
    [(MyNavigationController *)self.navigationController startLoading];
    
    dispatch_queue_t q_global = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_queue_t q_main = dispatch_get_main_queue();
    
    dispatch_async(q_global, ^{
        
        self.objects = [NSMutableArray new];
        self.objects = [[PostalCodeRepository sharedRepository] searchWithQuery:query];
        
        // テーブルビュー右側のセクションインデックスを作成する
        self.sectionIndexTitles = [NSMutableArray new];
        for (NSMutableArray *states in self.objects) {
            PostalCodeModel *model = states[0];
            [self.sectionIndexTitles addObject:[self stringToThreeWithString:model.stateK]];
        }
        
        dispatch_async(q_main, ^{
            [(MyNavigationController *)self.navigationController stopLoading];
            [self.tableView reloadData];
        });
    });
}

- (NSString *)stringToThreeWithString:(NSString *)string
{
    return (string.length > 3) ? [string substringToIndex:3] : string;
}

- (NSString *)textLabelText:(NSIndexPath *)indexPath
{
    NSArray *postalCodeModels = self.objects[indexPath.section];
    PostalCodeModel *model = postalCodeModels[indexPath.row];
    return [NSString stringWithFormat:@"%@ %@ %@", model.stateK, model.cityTownK, model.streetK];
}

- (NSString *)detailTextLabelText:(NSIndexPath *)indexPath
{
    NSMutableArray *postalCodeModels = self.objects[indexPath.section];
    PostalCodeModel *model = postalCodeModels[indexPath.row];
    
    NSMutableString *postalCode = [NSMutableString stringWithString:model.postalCode];
    [postalCode insertString:@"-" atIndex:3];

    return  [postalCode copy];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.objects.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSMutableArray *postalCodeModels = self.objects[section];
    return postalCodeModels.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return self.sectionIndexTitles[section];
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    return [self.sectionIndexTitles copy];
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSMutableArray *postalCodeModels = self.objects[indexPath.section];
    PostalCodeModel *model = postalCodeModels[indexPath.row];

    DetailViewController *viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"DetailViewController"];
    viewController.postalCodeModel = model;
    [self.navigationController pushViewController:viewController animated:YES];
}

@end
