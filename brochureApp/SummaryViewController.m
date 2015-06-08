//
//  SummaryViewController.m
//  brochureApp
//
//  Created by Xiaohe Hu on 5/21/15.
//  Copyright (c) 2015 Xiaohe Hu. All rights reserved.
//

#import "SummaryViewController.h"
#import "summaryCell.h"

@interface SummaryViewController () <UICollectionViewDelegate,
                                     UICollectionViewDataSource>
{
    NSArray         *arr_summaryKeys;
    NSMutableArray  *arr_summaryValues;
}
@property (weak, nonatomic) IBOutlet UICollectionView *uic_summaryColletion;

@end

@implementation SummaryViewController

@synthesize dict_summaryData;

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _uic_summaryColletion.delegate = self;
    _uic_summaryColletion.dataSource = self;
    
}

- (void)viewWillAppear:(BOOL)animated
{
    arr_summaryKeys = [[NSArray alloc] initWithArray:
                       [[dict_summaryData allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)]];
    
    arr_summaryValues = [NSMutableArray new];
    for (int i = 0; i < arr_summaryKeys.count; i++) {
        [arr_summaryValues addObject:[dict_summaryData objectForKey:arr_summaryKeys[i]]];
    }
}

- (IBAction)closeSummary:(id)sender {
    [self dismissViewControllerAnimated:YES completion:^(void){ }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Summary collection view delegate methods
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return arr_summaryKeys.count;
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    summaryCell *summaryCell = [collectionView
                                         dequeueReusableCellWithReuseIdentifier:@"summaryCell"
                                         forIndexPath:indexPath];
    summaryCell.cellTitle.text = [arr_summaryValues objectAtIndex: indexPath.row];
    
    return summaryCell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{

}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
