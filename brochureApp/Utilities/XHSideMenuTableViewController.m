//
//  XHSideMenuTableViewController.m
//  brochureApp
//
//  Created by Xiaohe Hu on 5/27/15.
//  Copyright (c) 2015 Xiaohe Hu. All rights reserved.
//

#import "XHSideMenuTableViewController.h"
#import "ViewController.h"
@interface XHSideMenuTableViewController () <UISearchBarDelegate, UISearchDisplayDelegate>
{
    NSString            *selectedSearchResult;
    NSMutableArray      *arr_projects;
    NSUserDefaults      *selectedIndexDefault;
    NSMutableArray      *searchResult;
}

@end

@implementation XHSideMenuTableViewController
@synthesize delegate;
- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    arr_projects = [[NSMutableArray alloc] initWithArray:arr_projectNames];
    searchResult = [[NSMutableArray alloc] initWithArray:arr_projects];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.tableView setSeparatorInset:UIEdgeInsetsZero];
    selectedIndexDefault = [NSUserDefaults standardUserDefaults];
    [selectedIndexDefault setObject:[NSNumber numberWithInt:0] forKey:@"selectedIndex"];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
//    int theIndex = (int)[[selectedIndexDefault objectForKey:@"selectedIndex"] integerValue];
//    NSIndexPath *indexPath=[NSIndexPath indexPathForRow:theIndex inSection:0];
//    [self.tableView selectRowAtIndexPath:indexPath animated:NO  scrollPosition:UITableViewScrollPositionNone];
    
    [self.tableView setContentOffset:CGPointMake(0.0, self.searchDisplayController.searchBar.frame.size.height)];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Updated table's content accroding to input array

- (void)updateTableContent:(NSArray *)newContent
{
    [arr_projects removeAllObjects];
    [arr_projects addObjectsFromArray:newContent];
    [self.tableView reloadData];
    
    [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]
                    animated:NO
                    scrollPosition:UITableViewScrollPositionNone];
    
    [self.tableView setContentOffset:CGPointMake(0.0, self.searchDisplayController.searchBar.frame.size.height)];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return [searchResult count];
    } else {
        return [arr_projects count];
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"tableCell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"tableCell"];
    }
    
    cell.backgroundColor = [UIColor redColor];
    
    
//    [cell.textLabel setText: arr_projects[indexPath.row]];
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        [cell.textLabel setText: searchResult[indexPath.row]];
    } else {
        [cell.textLabel setText: arr_projects[indexPath.row]];
    }
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0) {
        cell.layoutMargins = UIEdgeInsetsZero;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    /*
     * If in search mode send selected cell's title to the delegate method
     * Else only sent the index of the cell.
     */
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        UITableViewCell *theCell = [tableView cellForRowAtIndexPath:indexPath];
        selectedSearchResult = [[NSString alloc] initWithString:theCell.textLabel.text];
        [[self delegate] didSelectedTheCell:nil withTitle:theCell.textLabel.text];
    }
    else {
        selectedSearchResult = nil;
        [selectedIndexDefault setValue:[NSNumber numberWithInt:(int)indexPath.row] forKey:@"selectedIndex"];
        [[self delegate] didSelectedTheCell:indexPath withTitle:nil];
    }
}

#pragma mark Content Filtering
-(void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope {
    // Update the filtered array based on the search text and scope.
    // Remove all objects from the filtered search array
    [searchResult removeAllObjects];
    // Filter the array using NSPredicate
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"self contains[c] %@",searchText];
    searchResult = [NSMutableArray arrayWithArray:[arr_projects filteredArrayUsingPredicate:predicate]];
}
#pragma mark - UISearchDisplayController Delegate Methods
-(BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString {
    // Tells the table data source to reload when text changes
    [self filterContentForSearchText:searchString scope:
     [[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:[self.searchDisplayController.searchBar selectedScopeButtonIndex]]];
    // Return YES to cause the search result table view to be reloaded.
    return YES;
}

-(BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption {
    // Tells the table data source to reload when scope bar selection changes
    [self filterContentForSearchText:self.searchDisplayController.searchBar.text scope:
     [[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:searchOption]];
    // Return YES to cause the search result table view to be reloaded.
    return YES;
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{

}

- (void)searchDisplayControllerDidEndSearch:(UISearchDisplayController *)controller
{
    if (selectedSearchResult != nil) {
        int rowNum = (int)[arr_projects indexOfObject:selectedSearchResult];
        NSIndexPath *indexOfWholeTable = [NSIndexPath indexPathForRow:rowNum inSection:0];
        [self.tableView selectRowAtIndexPath:indexOfWholeTable animated:NO scrollPosition:UITableViewScrollPositionNone];
    }

}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
