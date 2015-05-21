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

#define menuWidth  200.0;

@interface ViewController () <UICollectionViewDelegate, UICollectionViewDataSource>
{
    NSInteger   sectionNum;
    UIView      *uiv_back;
}
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *collectionLeadingConstrain;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *collectionTailingConstrain;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *menuBtnLeadingConstrain;

@property (weak, nonatomic) IBOutlet UICollectionView *uic_mainCollection;

@property (weak, nonatomic) IBOutlet UIButton *uib_menu;
@property (nonatomic, strong) DetailViewController    *detail_vc;
@property (weak, nonatomic) IBOutlet UIView *uiv_menuContainer;


@property (weak, nonatomic) IBOutlet UIButton *uib_project1;
@property (weak, nonatomic) IBOutlet UIButton *uib_project2;
@property (weak, nonatomic) IBOutlet UIButton *uib_project3;
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
    sectionNum = 3;
}

- (void)viewWillLayoutSubviews
{
}

- (IBAction)menuBtnTapped:(id)sender {
    
    if (_uib_menu.selected) {
        _collectionLeadingConstrain.constant -= menuWidth;
        _collectionTailingConstrain.constant -= menuWidth;
        _menuBtnLeadingConstrain.constant -= menuWidth;
        [uiv_back removeFromSuperview];
        uiv_back = nil;
    }
    else {
        _collectionLeadingConstrain.constant += menuWidth;
        _collectionTailingConstrain.constant += menuWidth;
        _menuBtnLeadingConstrain.constant += menuWidth;
        uiv_back = [[UIView alloc] initWithFrame:self.view.bounds];
        uiv_back.backgroundColor = [UIColor colorWithWhite:0.8 alpha:0.8];
        UITapGestureRecognizer *tapBackView = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapOnBackView:)];
        tapBackView.numberOfTapsRequired = 1;
        uiv_back.userInteractionEnabled = YES;
        [uiv_back addGestureRecognizer: tapBackView];
        uiv_back.translatesAutoresizingMaskIntoConstraints = NO;
        [self.view insertSubview:uiv_back aboveSubview:_uic_mainCollection];
        
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

- (void)tapOnBackView:(UIGestureRecognizer *)gesture
{
    [self menuBtnTapped:_uib_menu];
}

- (IBAction)tapPorjectBtns:(id)sender {
    _uib_project1.selected = NO;
    _uib_project2.selected = NO;
    _uib_project3.selected = NO;
    
    UIButton *tappedBtn = sender;
    tappedBtn.selected = YES;
    
    sectionNum = [sender tag];
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
        NSString *title = [[NSString alloc]initWithFormat:@"Porject Name #%i", indexPath.section + 1];
        headerView.title_label.text = title;
        reusableview = headerView;
    }
    return reusableview;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (_detail_vc != nil) {
        [_detail_vc.view removeFromSuperview];
        [_detail_vc removeFromParentViewController];
        _detail_vc = nil;
    }
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    _detail_vc = [storyboard instantiateViewControllerWithIdentifier:@"DetailViewController"];
    _detail_vc.view.frame = self.view.bounds;
    _detail_vc.sectionNum = (int)indexPath.section;
    _detail_vc.rowNum = (int)indexPath.row;
    [self.view addSubview: _detail_vc.view];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
