//
//  SelectViewController.m
//  PostalCode
//
//  Created by OCHIISHI Koichiro on 10/22/13.
//  Copyright (c) 2013 OCHIISHI Koichiro. All rights reserved.
//

#import "SelectViewController.h"

@interface SelectViewController ()

@property (nonatomic, strong) NSMutableArray *objects;
@property (nonatomic, strong) NSMutableArray *sectionIndexTitles; // 4文字制限

@end

@implementation SelectViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.objects = [NSMutableArray new];
    self.sectionIndexTitles = [NSMutableArray new];
    self.tableView.sectionIndexTrackingBackgroundColor = [UIColor colorWithRed:206.f/255.f green:203.f/255.f blue:198.f/255.f alpha:.2f];
    
    if (self.selectedAddress != SelectedAddressState) {
        self.navigationItem.leftBarButtonItem = nil;
    }
    
    [(MyNavigationController *)self.navigationController startLoading];
    
    dispatch_queue_t q_global = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_queue_t q_main = dispatch_get_main_queue();
    
    dispatch_async(q_global, ^{
        
        if (self.selectedAddress == SelectedAddressState) {
            self.objects = [[PostalCodeRepository sharedRepository] getStates];
            self.sectionIndexTitles = [[PostalCodeRepository sharedRepository] getStateSectionIndexTitles];
        } else if (self.selectedAddress == SelectedAddressCityTown) {
            self.objects = [[PostalCodeRepository sharedRepository] getCityTownsByState:self.selectedState];
            for (PostalCodeModel *model in self.objects) {
                [self.sectionIndexTitles addObject:[self stringToThreeWithString:model.cityTownK]];
            }
        } else if (self.selectedAddress == SelectedAddressStreet) {
            self.objects = [[PostalCodeRepository sharedRepository] getStreetsByState:self.selectedState byCityAndTown:self.selectedCityTown];
            for (NSMutableArray *models in self.objects) {
                PostalCodeModel *model = [models lastObject];
                if (model.streetH.length) {
                    NSString *string = [model.streetH substringToIndex:1];
                    if (string.length) {
                        [self.sectionIndexTitles addObject:string];
                    }
                }
            }
        }
        dispatch_async(q_main, ^{
            [(MyNavigationController *)self.navigationController stopLoading];
            [self.tableView reloadData];
        });
    });
}

- (void)viewWillDisappear:(BOOL)animated
{
    // 「読み込み中」が表示された状態で「戻る」が押された場合に、「読み込み中」が表示され続けてしまう問題を修正
    // http://ameblo.jp/satoko-ohtsuki/entry-11369448573.html
    if ([self.navigationController.viewControllers indexOfObject:self] == NSNotFound) {
        [(MyNavigationController *)self.navigationController stopLoading];
    }
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -

- (NSString *)stringToThreeWithString:(NSString *)string
{
    return (string.length > 3) ? [string substringToIndex:3] : string;
}

- (NSString *)textLabelText:(NSIndexPath *)indexPath
{
    switch (self.selectedAddress) {
        case SelectedAddressState:
            return self.objects[indexPath.section][indexPath.row];
        case SelectedAddressCityTown: {
            PostalCodeModel *model = self.objects[indexPath.section];
            return model.cityTownK;
        }
        case SelectedAddressStreet: {
            PostalCodeModel *model = self.objects[indexPath.section][indexPath.row];
            return (model.streetK.length) ? model.streetK : model.cityTownK;
        }
        default:
            return @"";
    }
}

- (NSString *)detailTextLabelText:(NSIndexPath *)indexPath
{
    switch (self.selectedAddress) {
        case SelectedAddressCityTown: {
            PostalCodeModel *model = self.objects[indexPath.section];
            return model.cityTownH;
        }
        case SelectedAddressStreet: {
            PostalCodeModel *model = self.objects[indexPath.section][indexPath.row];
            return (model.streetK.length) ? model.streetH : model.cityTownH;
        }
        default:
            return @"";
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.objects.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.selectedAddress == SelectedAddressCityTown) {
        return 1;
    }
    return [self.objects[section] count];
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    return [self.sectionIndexTitles copy];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (self.selectedAddress == SelectedAddressState) {
        return self.sectionIndexTitles[section];
    }
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [DynamicTypeHelper heightWithStyle:UITableViewCellStyleSubtitle
                                          text:[self textLabelText:indexPath]
                                    detailText:[self detailTextLabelText:indexPath]];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];

    // Configure the cell...
    cell = [DynamicTypeHelper setupDynamicTypeCell:cell style:UITableViewCellStyleSubtitle];
    cell.textLabel.text = [self textLabelText:indexPath];
    cell.detailTextLabel.text = [self detailTextLabelText:indexPath];

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (self.selectedAddress) {
        case SelectedAddressState: {
            
            SelectViewController *viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"SelectViewController"];
            viewController.selectedAddress = SelectedAddressCityTown;
            viewController.selectedState = self.objects[indexPath.section][indexPath.row];
            viewController.title = self.objects[indexPath.section][indexPath.row];
            [self.navigationController pushViewController:viewController animated:YES];
            
            break;
        }
        case SelectedAddressCityTown: {

            PostalCodeModel *model = self.objects[indexPath.section];

            SelectViewController *viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"SelectViewController"];
            viewController.selectedAddress = SelectedAddressStreet;
            viewController.selectedState = self.selectedState;
            viewController.selectedCityTown = model.cityTownK;
            viewController.title = model.cityTownK;
            [self.navigationController pushViewController:viewController animated:YES];

            break;
        }
        case SelectedAddressStreet: {

            PostalCodeModel *model = self.objects[indexPath.section][indexPath.row];
            DetailViewController *viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"DetailViewController"];
            viewController.postalCodeModel = model;
            [self.navigationController pushViewController:viewController animated:YES];

            break;
        }
    }
}

@end
