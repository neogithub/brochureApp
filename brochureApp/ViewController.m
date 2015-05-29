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
#define topGap     30;

NSString        *homePage = @"http://www.neoscape.com";
NSString        *infoEmail = @"info@neoscape.com";
NSString        *requestEmail = @"info@neoscape.com";
NSArray         *arr_demoKeys = nil;
NSArray         *arr_demoValues = nil;

@interface ViewController () <UICollectionViewDelegate, UICollectionViewDataSource, sideTableDelegate>
{
    NSInteger                           sectionNum;
    UIView                              *uiv_back;
    XHSideMenuTableViewController       *sideMenuTable;
    int                                 selectedTableIndex;
}
@property (weak, nonatomic) IBOutlet NSLayoutConstraint         *cvContainerLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint         *cvContainerTrailingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint         *cvContainerTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint         *cvContainerBtmConstraint;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint         *menuBtnLeadingConstrain;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint         *menuContainerLeading;

@property (weak, nonatomic) IBOutlet UIView                     *uiv_collectionContainer;
@property (weak, nonatomic) IBOutlet UICollectionView           *uic_mainCollection;

@property (weak, nonatomic) IBOutlet UIButton                   *uib_menu;
@property (nonatomic, strong)        DetailViewController       *detail_vc;
@property (weak, nonatomic) IBOutlet UIView                     *uiv_menuContainer;
@property (weak, nonatomic) IBOutlet UIView                     *uiv_tableContainer;

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
     * Init a array as a demo data
     */
    arr_demoKeys = [[NSArray alloc] initWithObjects:
                    @"Project #1",
                    @"Project #2",
                    @"Project #3",
                    nil];
    arr_demoValues = [[NSArray alloc] initWithObjects:
                      [NSNumber numberWithInt:10],
                      [NSNumber numberWithInt:30],
                      [NSNumber numberWithInt:50],
                      nil];
    sectionNum = (int)arr_demoKeys.count;
    selectedTableIndex = 0;
    
    [self addScreenEdgeGesture];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
        self.navigationController.interactivePopGestureRecognizer.delegate = nil;
    }
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
        _cvContainerLeadingConstraint.constant  -= menuWidth;
        _cvContainerTrailingConstraint.constant += menuWidth;
        _cvContainerBtmConstraint.constant      -= topGap;
        _cvContainerTopConstraint.constant      -= topGap;
        _menuBtnLeadingConstrain.constant       -= menuWidth;
        _menuContainerLeading.constant          -= menuWidth;
        [uiv_back removeFromSuperview];
        uiv_back = nil;
    }
    /*
     * Side menu is hidden
     * Add new constraints to move in side menu and push the collection view
     * Init the blurred back view (tap to hide side menu)
     */
    else {
        _cvContainerLeadingConstraint.constant  += menuWidth;
        _cvContainerTrailingConstraint.constant -= menuWidth;
        _cvContainerTopConstraint.constant      += topGap;
        _cvContainerBtmConstraint.constant      += topGap;
        _menuBtnLeadingConstrain.constant       += menuWidth;
        _menuContainerLeading.constant          += menuWidth;
        uiv_back = [[UIView alloc] initWithFrame:self.view.bounds];
        uiv_back.backgroundColor = [UIColor clearColor];
        UITapGestureRecognizer *tapBackView = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapOnBackView:)];
        UISwipeGestureRecognizer *swipeLeftBackView = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(tapOnBackView:)];
        swipeLeftBackView.direction = UISwipeGestureRecognizerDirectionLeft;
        uiv_back.userInteractionEnabled = YES;
        [uiv_back addGestureRecognizer: tapBackView];
        [uiv_back addGestureRecognizer: swipeLeftBackView];
        uiv_back.translatesAutoresizingMaskIntoConstraints = NO;
        [self.view insertSubview:uiv_back aboveSubview:_uiv_collectionContainer];
        
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
    
    
    [UIView animateWithDuration:0.33 animations:^(void){
        [self.view layoutIfNeeded];
        /*
         * Scale the collection view as needed
         */
        if (_uib_menu.selected) {
            _uiv_collectionContainer.transform = CGAffineTransformIdentity;
        }
        else {
            _uiv_collectionContainer.transform = CGAffineTransformMakeScale(0.98, 0.98);
        }
    } completion:^(BOOL finished){
        _uib_menu.selected = !_uib_menu.selected;
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
    [vc loadWebPage:theUrl];
    vc.modalPresentationStyle = UIModalPresentationCurrentContext;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"hideNaviBtn" object:self];
    [self presentViewController:vc animated:YES completion:nil];
}

/*
 * Add screen edge gesture to collection view container
 * Swipe to right to open side menu
 */
- (void)addScreenEdgeGesture
{
    UIScreenEdgePanGestureRecognizer *openSideMenu = [[UIScreenEdgePanGestureRecognizer alloc] initWithTarget:self action:@selector(swipeLeftEdge:)];
    [openSideMenu setEdges: UIRectEdgeLeft];
    _uiv_collectionContainer.userInteractionEnabled = YES;
    [_uiv_collectionContainer addGestureRecognizer: openSideMenu];
    
    UISwipeGestureRecognizer *swipRightOnCollectionView = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeRightOnCollectionView:)];
    swipRightOnCollectionView.direction = UISwipeGestureRecognizerDirectionRight;
    [_uic_mainCollection addGestureRecognizer:swipRightOnCollectionView];
}

- (void)swipeLeftEdge:(UIGestureRecognizer *)gesture
{
    if (gesture.state == UIGestureRecognizerStateBegan) {
        [self menuBtnTapped:_uib_menu];
        return;
    }
    else
        return;
}

- (void)swipeRightOnCollectionView:(UIGestureRecognizer *)gesture
{
    [self menuBtnTapped:_uib_menu];
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
        sectionNum = (int)arr_demoKeys.count;
    }
    else {
        sectionNum = 1;
    }
    selectedTableIndex = (int)index.row;
    [_uic_mainCollection reloadData];
    [self menuBtnTapped:_uib_menu];
}

#pragma mark - Collection Delegate Methods
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return sectionNum;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    /*
     * If a section is selected, according to tapped table cell index to load data
     */
    if (sectionNum == 1) {
        return [[arr_demoValues objectAtIndex: selectedTableIndex-1] integerValue];
    }
    /*
     * If selected "All" load all data from Dictionary
     */
    else {
        return [[arr_demoValues objectAtIndex: section] integerValue];
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
        NSString *title = [NSString new];
        /*
         * If selected "All" section
         * Go through all keys
         */
        if (selectedTableIndex == 0) {
            title = [arr_demoKeys objectAtIndex: indexPath.section];
        }
        /*
         * If selected specific one
         * use "selectedTableIndex" to get the key
         */
        else {
            title = [arr_demoKeys objectAtIndex: selectedTableIndex -1];
        }
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
    [self.navigationController pushViewController:_detail_vc animated:YES];
//    [self presentViewController:_detail_vc animated:YES completion:^(void){     }];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
