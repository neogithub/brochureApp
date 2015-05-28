//
//  ViewController.m
//  brochureApp
//
//  Created by Xiaohe Hu on 5/20/15.
//  Copyright (c) 2015 Xiaohe Hu. All rights reserved.
//

#import "ViewController.h"
#import "DetailViewController.h"
#import "CollectionHeaderView.h"
#import "xhWebViewController.h"
#import <MessageUI/MessageUI.h>
#import "XHSideMenuTableViewController.h"

#define menuWidth  200.0;

NSString *homePage = @"http://www.neoscape.com";
NSString *infoEmail = @"info@neoscape.com";
NSString *requestEmail = @"info@neoscape.com";

@interface ViewController () <UICollectionViewDelegate, UICollectionViewDataSource, sideTableDelegate>
{
    NSInteger                           sectionNum;
    UIView                              *uiv_back;
    XHSideMenuTableViewController       *sideMenuTable;
}
@property (weak, nonatomic) IBOutlet NSLayoutConstraint         *collectionLeadingConstrain;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint         *collectionTailingConstrain;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint         *menuBtnLeadingConstrain;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint         *menuContainerLeading;

@property (weak, nonatomic) IBOutlet UICollectionView           *uic_mainCollection;

@property (weak, nonatomic) IBOutlet UIButton                   *uib_menu;
@property (nonatomic, strong)        DetailViewController       *detail_vc;
@property (weak, nonatomic) IBOutlet UIView                     *uiv_menuContainer;
@property (weak, nonatomic) IBOutlet UIView                *uiv_tableContainer;

@end

@implementation ViewController

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    _uic_mainCollection.delegate = self;
    _uic_mainCollection.dataSource = self;
    [self setUpSideTableView];
    /*
     Magic num of section numbers
     */
    sectionNum = 3;
}

- (void)viewDidAppear:(BOOL)animated
{

}

- (void)viewWillLayoutSubviews
{
    
}

#pragma mark - Action of buttons

- (IBAction)menuBtnTapped:(id)sender {
    /*
     * Status: side menu is unhidden
     * Hide side menu
     * Reset constraints of collection view menu button
     * Remove blurred back view
     */
    if (_uib_menu.selected) {
        _collectionLeadingConstrain.constant -= menuWidth;
        _collectionTailingConstrain.constant += menuWidth;
        _menuBtnLeadingConstrain.constant -= menuWidth;
        _menuContainerLeading.constant -= menuWidth;
        [uiv_back removeFromSuperview];
        uiv_back = nil;
    }
    /*
     * Side menu is hidden
     * Add new constraints to move in side menu and push the collection view
     * Init the blurred back view (tap to hide side menu)
     */
    else {
        _collectionLeadingConstrain.constant += menuWidth;
        _collectionTailingConstrain.constant -= menuWidth;
        _menuBtnLeadingConstrain.constant += menuWidth;
        _menuContainerLeading.constant += menuWidth;
        uiv_back = [[UIView alloc] initWithFrame:self.view.bounds];
        uiv_back.backgroundColor = [UIColor colorWithWhite:0.8 alpha:0.8];
        UITapGestureRecognizer *tapBackView = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapOnBackView:)];
        uiv_back.userInteractionEnabled = YES;
        [uiv_back addGestureRecognizer: tapBackView];
        uiv_back.translatesAutoresizingMaskIntoConstraints = NO;
        [self.view insertSubview:uiv_back aboveSubview:_uic_mainCollection];
        
        //X direction constrains
        [self.view addConstraint:[NSLayoutConstraint
                                  constraintWithItem:uiv_back
                                  attribute:NSLayoutAttributeRight
                                  relatedBy:NSLayoutRelationEqual
                                  toItem:self.view
                                  attribute:NSLayoutAttributeRight
                                  multiplier:1.0
                                  constant:0.0]];
        [self.view addConstraint:[NSLayoutConstraint
                                  constraintWithItem:uiv_back
                                  attribute:NSLayoutAttributeLeft
                                  relatedBy:NSLayoutRelationEqual
                                  toItem:self.view
                                  attribute:NSLayoutAttributeLeft
                                  multiplier:1.0
                                  constant:0.0]];
        //Y direction constrains
        [self.view addConstraint:[NSLayoutConstraint
                                  constraintWithItem:uiv_back
                                  attribute:NSLayoutAttributeTop
                                  relatedBy:NSLayoutRelationEqual
                                  toItem:self.view
                                  attribute:NSLayoutAttributeTop
                                  multiplier:1.0
                                  constant:0.0]];
        [self.view addConstraint:[NSLayoutConstraint
                                  constraintWithItem:uiv_back
                                  attribute:NSLayoutAttributeBottom
                                  relatedBy:NSLayoutRelationEqual
                                  toItem:self.view
                                  attribute:NSLayoutAttributeBottom
                                  multiplier:1.0
                                  constant:0.0]];
    }
    
    _uib_menu.selected = !_uib_menu.selected;
    [UIView animateWithDuration:0.33 animations:^(void){
        [self.view layoutIfNeeded];
    }];
}
/*
 * Tap back view to hide side menu 
 * And reset all view's constraints
 */
- (void)tapOnBackView:(UIGestureRecognizer *)gesture
{
    [[self view] endEditing:YES];
    [self menuBtnTapped:_uib_menu];
}

/*
 * Load web view
 * With address: www.neoscape.com
 */
- (IBAction)tapVisitBtn:(id)sender {
    NSString *theUrl = homePage;
    xhWebViewController *vc = [[xhWebViewController alloc] init];
    [vc socialButton:theUrl];
    vc.modalPresentationStyle = UIModalPresentationCurrentContext;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"hideNaviBtn" object:self];
    [self presentViewController:vc animated:YES completion:nil];
}

#pragma mark - Side menu table view
- (void)setUpSideTableView
{
    sideMenuTable = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"XHSideMenuTableViewController"];
    sideMenuTable.tableView.frame = _uiv_tableContainer.bounds;
    [_uiv_tableContainer addSubview: sideMenuTable.tableView];
    sideMenuTable.delegate = self;
    [self addChildViewController: sideMenuTable];
}
/*
 * Delegate method of side table view
 */
- (void)didSelectedTheCell:(NSIndexPath *)index
{
    if (index.row == 0) {
        sectionNum = 3;
    }
    else {
        sectionNum = 1;
    }
    [_uic_mainCollection reloadData];
    [self tapOnBackView:nil];
}

#pragma mark - Collection Delegate Methods
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return sectionNum;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    /*
     * Magic numbers for items in a section (should read from plist or data model)
     */
    switch (section) {
        case 0:
            return 35;
        case 1:
            return 40;
        case 2:
            return 40;
        default:
            break;
    }
    return 0;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                 cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *galleryCell = [collectionView
                                       dequeueReusableCellWithReuseIdentifier:@"myCell"
                                       forIndexPath:indexPath];
    return galleryCell;
}

-(UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    UICollectionReusableView *reusableview = nil;
    
    if (kind == UICollectionElementKindSectionHeader) {
        CollectionHeaderView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"HeaderView" forIndexPath:indexPath];
        NSString *title = [[NSString alloc]initWithFormat:@"Porject Name #%i", (int)indexPath.section + 1];
        headerView.title_label.text = title;
        reusableview = headerView;
    }
    return reusableview;
}

/*
 * Tap a cell to presnet detail viewcontroller's content
 */

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    _detail_vc = [storyboard instantiateViewControllerWithIdentifier:@"DetailViewController"];
    _detail_vc.view.frame = self.view.bounds;
    _detail_vc.sectionNum = (int)indexPath.section;
    _detail_vc.rowNum = (int)indexPath.row;
//    [self presentViewController:_detail_vc animated:YES completion:^(void){     }];
    
    [self.navigationController pushViewController:_detail_vc animated:YES];
//    UINavigationController *detailNavVC = [[UINavigationController alloc] init];
//    detailNavVC.view.frame = self.view.bounds;
//    detailNavVC.view.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
//    [self addChildViewController: detailNavVC];
//    [self.view addSubview: detailNavVC.view];
//    [detailNavVC pushViewController:_detail_vc animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
