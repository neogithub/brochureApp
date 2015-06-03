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
#import "embEmailData.h"
#import <MessageUI/MessageUI.h>
#import "XHSideMenuTableViewController.h"
#import "LibraryAPI.h"

#define menuWidth  200.0;
#define topGap     30;

NSString        *homePage = @"http://www.neoscape.com";
NSString        *infoEmail = @"info@neoscape.com";
NSString        *requestEmail = @"info@neoscape.com";
NSArray         *arr_demoKeys = nil;
NSArray         *arr_demoValues = nil;

@interface ViewController ()    <UICollectionViewDelegate,
                                UICollectionViewDataSource,
                                sideTableDelegate,
                                MFMailComposeViewControllerDelegate,
                                MFMailComposeViewControllerDelegate>
{
    NSInteger                           sectionNum;
    UIView                              *uiv_back;
    XHSideMenuTableViewController       *sideMenuTable;
    int                                 selectedTableIndex;
}
@property (nonatomic, strong)        embEmailData               *emailData;
@property (weak, nonatomic) IBOutlet UIButton                   *uib_missingFile;

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
    
    /*
     * Init a array as a demo data
     */
    arr_demoKeys = [[NSArray alloc] initWithArray:[[LibraryAPI sharedInstance] getCompanyNames]];
    
    arr_demoValues = [[NSArray alloc] initWithObjects:
                      [NSNumber numberWithInt:10],
                      [NSNumber numberWithInt:30],
                      [NSNumber numberWithInt:50],
                      nil];
    
    
    // Do any additional setup after loading the view, typically from a nib.
    _uic_mainCollection.delegate = self;
    _uic_mainCollection.dataSource = self;
    [self setUpSideTableView];
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
        
        /*
         * Hide the keyborad (if is shown)
         */
        [[self view] endEditing:YES];
        /*
         * Make the search view controller in talbe inactive
         */
        [sideMenuTable.searchDisplayController setActive:NO];
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
 * Tap request a missing file button
 */
- (IBAction)askForAMissingFile:(id)sender {
    _emailData = [[embEmailData alloc] init];
    _emailData.to = @[@"evan.buxton@neoscape.com", @"xiaohe.hu@neoscape.com"];
    _emailData.subject = @"Missing Brochure File Needed";
    _emailData.body = @"Project Name: \n\nFinished Time: \n\nPlease add the file, thank you!";
    [self prepareEmailData];
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
- (void)didSelectedTheCell:(NSIndexPath *)index withTitle:(NSString *)title
{
    if (title == nil) {
        if (index.row == 0) {
            sectionNum = (int)arr_demoKeys.count;
        }
        else {
            sectionNum = 1;
        }
        selectedTableIndex = (int)index.row;
    }
    else {
        sectionNum = 1;
        selectedTableIndex = (int)[arr_demoKeys indexOfObject:title]+1;
    }
    /*
     * Searched "All" is not in keys array
     * Close the menu and return
     */
    if (selectedTableIndex < 0) {
        [self menuBtnTapped:_uib_menu];
        return;
    }
    [_uic_mainCollection reloadData];
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

#pragma mark - Email Delegates
-(void)prepareEmailData
{
    if ([MFMailComposeViewController canSendMail] == YES) {
        
        MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
        picker.mailComposeDelegate = self; // &lt;- very important step if you want feedbacks on what the user did with your email sheet
        
        if(_emailData.to)
            [picker setToRecipients:_emailData.to];
        
        if(_emailData.cc)
            [picker setCcRecipients:_emailData.cc];
        
        if(_emailData.bcc)
            [picker setBccRecipients:_emailData.bcc];
        
        if(_emailData.subject)
            [picker setSubject:_emailData.subject];
        
        if(_emailData.body)
            [picker setMessageBody:_emailData.body isHTML:NO]; // depends. Mostly YES, unless you want to send it as plain text (boring)
        
        
        // attachment code
        if(_emailData.attachment) {
            
            NSLog(@"_receivedData.attachment");
            
            NSString	*filePath;
            NSString	*justFileName;
            NSData		*myData;
            UIImage		*pngImage;
            NSString	*newname;
            //			if (kshowNSLogBOOL) NSLog(@"%@",_receivedData.attachment);
            
            for (id file in _emailData.attachment)
            {
                
                // check if it is a uiimage and handle
                if ([file isKindOfClass:[UIImage class]]) {
                    
                    myData = UIImagePNGRepresentation(file);
                    [picker addAttachmentData:myData mimeType:@"image/png" fileName:@"image.png"];
                    
                    // might be nsdata for pdf
                } else if ([file isKindOfClass:[NSData class]]) {
                    NSLog(@"pdf");
                    myData = [NSData dataWithData:file];
                    NSString *mimeType;
                    mimeType = @"application/pdf";
                    newname = @"Brochure.pdf";
                    [picker addAttachmentData:myData mimeType:mimeType fileName:newname];
                    
                    // it must be another file type?
                } else {
                    
                    justFileName = [[file lastPathComponent] stringByDeletingPathExtension];
                    
                    NSString *mimeType;
                    // Determine the MIME type
                    if ([[file pathExtension] isEqualToString:@"jpg"]) {
                        mimeType = @"image/jpeg";
                    } else if ([[file pathExtension] isEqualToString:@"png"]) {
                        mimeType = @"image/png";
                        pngImage = [UIImage imageNamed:file];
                    } else if ([[file pathExtension] isEqualToString:@"doc"]) {
                        mimeType = @"application/msword";
                    } else if ([[file pathExtension] isEqualToString:@"ppt"]) {
                        mimeType = @"application/vnd.ms-powerpoint";
                    } else if ([[file pathExtension] isEqualToString:@"html"]) {
                        mimeType = @"text/html";
                    } else if ([[file pathExtension] isEqualToString:@"pdf"]) {
                        mimeType = @"application/pdf";
                    } else if ([[file pathExtension] isEqualToString:@"com"]) {
                        mimeType = @"text/plain";
                    }
                    
                    filePath= [[NSBundle mainBundle] pathForResource:justFileName ofType:[file pathExtension]];
                    
                    if (![[file pathExtension] isEqualToString:@"png"]) {
                        myData = [NSData dataWithContentsOfFile:filePath];
                        myData = [NSData dataWithContentsOfFile:filePath];
                    } else {
                        myData = UIImagePNGRepresentation(pngImage);
                    }
                    [picker addAttachmentData:myData mimeType:mimeType fileName:file];
                }
            }
        }
        
        picker.navigationBar.barStyle = UIBarStyleBlack; // choose your style, unfortunately, Translucent colors behave quirky.
        [self presentViewController:picker animated:YES completion:nil];
        
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Status" message:[NSString stringWithFormat:@"Email needs to be configured before this device can send email."]
                                                       delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
    }
}

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
    // Notifies users about errors associated with the interface
    switch (result)
    {
        case MFMailComposeResultCancelled:
            break;
        case MFMailComposeResultSaved:
            break;
        case MFMailComposeResultSent:
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Thank you!" message:@"Email Sent Successfully"
                                                           delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [alert show];
        }
            break;
        case MFMailComposeResultFailed:
            break;
            
        default:
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Status" message:@"Sending Failed - Unknown Error"
                                                           delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [alert show];
        }
            break;
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
