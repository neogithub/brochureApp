//
//  XHGalleryViewController.m
//  XHGallery
//
//  Created by Xiaohe Hu on 12/24/14.
//  Copyright (c) 2014 Neoscape. All rights reserved.
//

#import "XHGalleryViewController.h"
#import "embModelController.h"
#import "FGalleryPhotoView.h"
#import "embEmailData.h"
#import <MessageUI/MessageUI.h>

#define kThumbnailSize 75
#define kThumbnailSpacing 4
static float        kTopViewHeight      = 45.0;
static float        kBottomViewHeight   = 45.0;

@interface XHGalleryViewController ()<  UIPageViewControllerDelegate,
                                        FGalleryPhotoViewDelegate,
                                        UIActionSheetDelegate,
                                        MFMailComposeViewControllerDelegate,
                                        MFMailComposeViewControllerDelegate,
                                        UIAlertViewDelegate>
{
    int             itemsNum;
    float           view_width;
    float           view_height;
    NSTimer         *tapTimer;
    BOOL            _isThumbViewShowing;
    NSMutableArray  *_photoThumbnailViews;
    
    NSMutableArray  *arr_captions;
    NSMutableArray  *arr_images;
    NSMutableArray  *arr_fileType;
}

//Top View
@property (nonatomic, strong)           UIView                  *uiv_topView;
@property (nonatomic, strong)           UILabel                 *uil_numLabel;
@property (nonatomic, strong)           UIButton                *uib_back;
@property (nonatomic, strong)           UIButton                *uib_thumbView;
@property (nonatomic, strong)           UIButton                *uib_share;
// Bottom View
@property (nonatomic, strong)           UIView                  *uiv_bottomView;
@property (nonatomic, strong)           UILabel                 *uil_caption;
// Page View
@property (nonatomic, readwrite)        NSInteger               currentPage;
@property (readonly, strong, nonatomic) embModelController		*modelController;
@property (strong, nonatomic)           UIPageViewController	*pageViewController;
// thumbs view
@property (nonatomic, strong)           UIScrollView            *thumbsView;
// play button
@property (nonatomic, strong)           UIImageView             *uiiv_playMovie;
// email view
@property (nonatomic, strong)           embEmailData            *emailData;
@end

@implementation XHGalleryViewController

@synthesize modelController = _modelController;
@synthesize delegate;
@synthesize showCaption, showNavBar;
@synthesize arr_rawData;
@synthesize startIndex;

/*
 * Get data from parent ViewController
 */
- (void)setArr_rawData:(NSArray *)_arr_rawData
{
    arr_rawData = _arr_rawData;
    [self prepareData];
}

- (void)setStartIndex:(int)_startIndex
{
    startIndex = _startIndex;
    _currentPage = startIndex;
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    /*
     * Make the Navi bar and caption is shown as default
     */
    showNavBar = YES;
    showCaption = YES;
    
    self.view.backgroundColor = [UIColor whiteColor];
    _modelController = [[embModelController alloc] init];
    _photoThumbnailViews = [[NSMutableArray alloc] init];
    
    /*
     * Add tap 1 time and 2 times gestures to view
     */
    [self addGestureToView];
    
    // Init thumbs view
    _thumbsView = [[UIScrollView alloc]initWithFrame:self.view.frame];
    int numOfCellEachLine = view_width / (kThumbnailSize + kThumbnailSpacing);
    float blankSapce = (view_width - (kThumbnailSpacing + kThumbnailSize)*numOfCellEachLine + kThumbnailSpacing)/2;
    _thumbsView.contentInset = UIEdgeInsetsMake( kThumbnailSpacing, blankSapce, kThumbnailSpacing, kThumbnailSpacing);
}

- (void)viewWillAppear:(BOOL)animated
{

    // Init model controller
    _modelController = [[embModelController alloc] initWithImage:arr_images];

    [self initPageView:startIndex];
    [self setUpThumbsView];
    
    // Check and load top & bottom views
    if (showCaption) {
        [self createBottomView];
    }
    if (showNavBar) {
        [self createTopView];
    }
    
    [self.view setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
}

- (void)willRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [self.view layoutIfNeeded];
}

//----------------------------------------------------
#pragma mark - Clean memory
//----------------------------------------------------
- (void)viewWillDisappear:(BOOL)animated
{
    [_uiv_topView removeFromSuperview];
    _uiv_topView = nil;
    
    [_uil_numLabel removeFromSuperview];
    _uil_numLabel = nil;
    
    [_uib_back removeFromSuperview];
    _uib_back = nil;
    
    [_uiv_bottomView removeFromSuperview];
    _uiv_bottomView = nil;
    
    [_uil_caption removeFromSuperview];
    _uil_caption = nil;
    
    _modelController = nil;
    
    [_photoThumbnailViews removeAllObjects];
    _photoThumbnailViews = nil;
    
    [_thumbsView removeFromSuperview];
    _thumbsView = nil;
    
    [_uiiv_playMovie removeFromSuperview];
    _uiiv_playMovie = nil;
    
    _isThumbViewShowing = NO;
    
    for (UIView __strong *tmp in [_pageViewController.view subviews]) {
        [tmp removeFromSuperview];
        tmp = nil;
    }
    
    [_pageViewController.view removeFromSuperview];
    _pageViewController.view = nil;
    [_pageViewController removeFromParentViewController];
    _pageViewController = nil;
    
    [arr_images removeAllObjects];
    arr_images = nil;
    
    [arr_captions removeAllObjects];
    arr_captions = nil;
    
    [arr_fileType removeAllObjects];
    arr_fileType = nil;
}

//----------------------------------------------------
#pragma mark - Prepare data
//----------------------------------------------------
- (void)prepareData
{
    arr_images = [[NSMutableArray alloc] init];
    arr_captions = [[NSMutableArray alloc] init];
    arr_fileType = [[NSMutableArray alloc] init];
    
    for (NSDictionary *dict_tmp in arr_rawData) {
        [arr_images addObject: [dict_tmp objectForKey:@"file"]];
        [arr_captions addObject: [dict_tmp objectForKey:@"caption"]];
        [arr_fileType addObject: [dict_tmp objectForKey:@"type"]];
    }
    itemsNum = arr_images.count;
}

//----------------------------------------------------
#pragma mark - Set Up top view
//----------------------------------------------------
- (void)createTopView
{
    _uiv_topView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.view.frame.size.width, kTopViewHeight)];
    _uiv_topView.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.9];
    _uiv_topView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [self.view addSubview: _uiv_topView];
    
    // Width constraint, self.vew width
    [_uiv_topView addConstraint:[NSLayoutConstraint constraintWithItem:_uiv_topView
                                                          attribute:NSLayoutAttributeWidth
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:nil
                                                          attribute:NSLayoutAttributeWidth
                                                         multiplier:1.0
                                                           constant:self.view.frame.size.width]];
    
    // Height constraint, kTopViewHeight
    [_uiv_topView addConstraint:[NSLayoutConstraint constraintWithItem:_uiv_topView
                                                          attribute:NSLayoutAttributeHeight
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:nil
                                                          attribute:NSLayoutAttributeHeight
                                                         multiplier:1.0
                                                           constant:kTopViewHeight]];
    
    // X constraint, 0.0
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_uiv_topView
                                                          attribute:NSLayoutAttributeCenterX
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeCenterX
                                                         multiplier:1.0
                                                           constant:0.0]];
    // Y constraint, 0.0
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_uiv_topView
                                                          attribute:NSLayoutAttributeTop
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeTop
                                                         multiplier:1.0
                                                           constant:0.0]];
    
    
    float labelWidth = 100; // With for top view's buttons and label
    float fontSize = 15.0;
    float buttonGap = 10.0;
    _uil_numLabel = [[UILabel alloc] initWithFrame:CGRectMake((_uiv_topView.frame.size.width-labelWidth)/2, 0, labelWidth, kTopViewHeight)];
    _uil_numLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _uil_numLabel.text = [NSString stringWithFormat:@"%i of %i", (int)_currentPage+1, itemsNum];
    _uil_numLabel.textColor = [UIColor blackColor];
    [_uil_numLabel setFont:[UIFont boldSystemFontOfSize:fontSize]];
    _uil_numLabel.textAlignment = NSTextAlignmentCenter;
    [_uiv_topView addSubview: _uil_numLabel];
    // Width constraint, 100
    [_uil_numLabel addConstraint:[NSLayoutConstraint constraintWithItem:_uil_numLabel
                                                          attribute:NSLayoutAttributeWidth
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:nil
                                                          attribute:NSLayoutAttributeWidth
                                                         multiplier:1.0
                                                           constant:labelWidth]];
    
    // Height constraint, kTopViewHeight
    [_uil_numLabel addConstraint:[NSLayoutConstraint constraintWithItem:_uil_numLabel
                                                          attribute:NSLayoutAttributeHeight
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:nil
                                                          attribute:NSLayoutAttributeHeight
                                                         multiplier:1.0
                                                           constant:kTopViewHeight]];
    
    // X constraint, 0.0
    [_uiv_topView addConstraint:[NSLayoutConstraint constraintWithItem:_uil_numLabel
                                                          attribute:NSLayoutAttributeCenterX
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:_uiv_topView
                                                          attribute:NSLayoutAttributeCenterX
                                                         multiplier:1.0
                                                           constant:0.0]];
    
    // Y constraint, 0.0
    [_uiv_topView addConstraint:[NSLayoutConstraint constraintWithItem:_uil_numLabel
                                                          attribute:NSLayoutAttributeTop
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:_uiv_topView
                                                          attribute:NSLayoutAttributeTop
                                                         multiplier:1.0
                                                           constant:0.0]];
    
    
    
    _uib_back = [UIButton buttonWithType:UIButtonTypeCustom];
    _uib_back.frame = CGRectMake(0.0, 0.0, labelWidth, kTopViewHeight);
    _uib_back.backgroundColor = [UIColor clearColor];
    [_uib_back setTitle:@"﹤ Back" forState:UIControlStateNormal];
    [_uib_back setTitleColor:[UIColor colorWithRed:0.0/255.0 green:122.0/255.0 blue:255.0/255.0 alpha:1.0] forState:UIControlStateNormal];
    [_uib_back setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    [_uib_back.titleLabel setFont:[UIFont boldSystemFontOfSize:fontSize]];
    [_uiv_topView addSubview: _uib_back];
    [_uib_back addTarget:self action:@selector(tapBackButton:) forControlEvents:UIControlEventTouchUpInside];
    
    _uib_share = [UIButton buttonWithType:UIButtonTypeCustom];
    _uib_share.frame = CGRectMake(self.view.frame.size.width-labelWidth, 0.0, labelWidth, kTopViewHeight);
    _uib_share.backgroundColor = [UIColor clearColor];
    [_uib_share setTitle:@"Share" forState:UIControlStateNormal];
    [_uib_share setTitleColor:[UIColor colorWithRed:0.0/255.0 green:122.0/255.0 blue:255.0/255.0 alpha:1.0] forState:UIControlStateNormal];
    [_uib_share setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    [_uib_share.titleLabel setFont:[UIFont boldSystemFontOfSize:fontSize]];
    [_uib_share addTarget:self action:@selector(loadShareOptions:) forControlEvents:UIControlEventTouchUpInside];
    _uib_share.translatesAutoresizingMaskIntoConstraints = NO;
    _uib_share.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [_uiv_topView addSubview: _uib_share];
    
    // Width constraint, less than or equal to 100
    [_uib_share addConstraint:[NSLayoutConstraint constraintWithItem:_uib_share
                                                               attribute:NSLayoutAttributeWidth
                                                               relatedBy:NSLayoutRelationLessThanOrEqual
                                                                  toItem:nil
                                                               attribute:NSLayoutAttributeWidth
                                                              multiplier:1.0
                                                                constant:labelWidth]];
    
    // Height constraint, kTopViewHeight
    [_uib_share addConstraint:[NSLayoutConstraint constraintWithItem:_uib_share
                                                               attribute:NSLayoutAttributeHeight
                                                               relatedBy:NSLayoutRelationEqual
                                                                  toItem:nil
                                                               attribute:NSLayoutAttributeHeight
                                                              multiplier:1.0
                                                                constant:kTopViewHeight]];
    
    // X constraint, 0.0
    [_uiv_topView addConstraint:[NSLayoutConstraint constraintWithItem:_uib_share
                                                             attribute:NSLayoutAttributeTrailing
                                                             relatedBy:NSLayoutRelationEqual
                                                                toItem:_uiv_topView
                                                             attribute:NSLayoutAttributeTrailing
                                                            multiplier:1.0
                                                              constant:0.0]];
    
    // Y constraint, 0.0
    [_uiv_topView addConstraint:[NSLayoutConstraint constraintWithItem:_uib_share
                                                             attribute:NSLayoutAttributeTop
                                                             relatedBy:NSLayoutRelationEqual
                                                                toItem:_uiv_topView
                                                             attribute:NSLayoutAttributeTop
                                                            multiplier:1.0
                                                              constant:0.0]];
    
    _uib_thumbView = [UIButton buttonWithType:UIButtonTypeCustom];
    _uib_thumbView.frame = CGRectMake(self.view.frame.size.width-_uib_share.frame.size.width-10, 0.0, labelWidth, kTopViewHeight);
    _uib_thumbView.backgroundColor = [UIColor clearColor];
    [_uib_thumbView setTitle:@"See All" forState:UIControlStateNormal];
    [_uib_thumbView setTitleColor:[UIColor colorWithRed:0.0/255.0 green:122.0/255.0 blue:255.0/255.0 alpha:1.0] forState:UIControlStateNormal];
    [_uib_thumbView setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    [_uib_thumbView.titleLabel setFont:[UIFont boldSystemFontOfSize:fontSize]];
    [_uib_thumbView addTarget:self action:@selector(loadThumbsView:) forControlEvents:UIControlEventTouchUpInside];
    _uib_thumbView.translatesAutoresizingMaskIntoConstraints = NO;
    _uib_thumbView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [_uiv_topView addSubview: _uib_thumbView];
    
    // Width constraint, less than or equal to 100
    [_uib_thumbView addConstraint:[NSLayoutConstraint constraintWithItem:_uib_thumbView
                                                               attribute:NSLayoutAttributeWidth
                                                               relatedBy:NSLayoutRelationLessThanOrEqual
                                                                  toItem:nil
                                                               attribute:NSLayoutAttributeWidth
                                                              multiplier:1.0
                                                                constant:labelWidth]];
    
    // Height constraint, kTopViewHeight
    [_uib_thumbView addConstraint:[NSLayoutConstraint constraintWithItem:_uib_thumbView
                                                               attribute:NSLayoutAttributeHeight
                                                               relatedBy:NSLayoutRelationEqual
                                                                  toItem:nil
                                                               attribute:NSLayoutAttributeHeight
                                                              multiplier:1.0
                                                                constant:kTopViewHeight]];
    
    // X constraint, horizontal space 10 with share button
    [_uiv_topView addConstraint:[NSLayoutConstraint constraintWithItem:_uib_thumbView
                                                             attribute:NSLayoutAttributeTrailing
                                                             relatedBy:NSLayoutRelationEqual
                                                                toItem:_uib_share
                                                             attribute:NSLayoutAttributeLeading
                                                            multiplier:1.0
                                                              constant:-buttonGap]];
    
    // Y constraint, 0.0
    [_uiv_topView addConstraint:[NSLayoutConstraint constraintWithItem:_uib_thumbView
                                                             attribute:NSLayoutAttributeTop
                                                             relatedBy:NSLayoutRelationEqual
                                                                toItem:_uiv_topView
                                                             attribute:NSLayoutAttributeTop
                                                            multiplier:1.0
                                                              constant:0.0]];
}

//----------------------------------------------------
#pragma mark Load Share menu
//----------------------------------------------------
- (void)loadShareOptions:(id)sender
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                             delegate:self
                                                    cancelButtonTitle:@"Cancle"
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:  @"Email",
                                                                        @"Save to device",
                                                                        nil];
    
    actionSheet.tag = 100;
    
    CGRect frame = _uib_share.frame;
    
    [actionSheet showFromRect:frame inView:self.view animated:YES];

}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 0:
            NSLog(@"Should load email view");
            [self loadEmail];
            break;
        case 1:
            NSLog(@"Should save the image");
            [self saveImage];
            break;
        default:
            break;
    }
}

- (void)saveImage
{
    NSString *fileFullName = arr_images[_currentPage];
    UIImage *saveImage = [UIImage imageNamed: fileFullName];
    UIImageWriteToSavedPhotosAlbum(saveImage, self, @selector(savedPhotoImage:didFinishSavingWithError:contextInfo:), nil);
}

-(void) savedPhotoImage:(UIImage *)image
didFinishSavingWithError:(NSError *)error
            contextInfo:(void *)contextInfo
{
    NSString *message = @"This image cannot be saved to your Photos album";
    if (error) {
        message = [error localizedDescription];
        NSString *alertTitle = @"Gallery Unavailable!";
        NSString *alertBody = @"Go To Settings --> Privacy -->Photos To Fix!";
        float versionNum = [[[UIDevice currentDevice] systemVersion] floatValue];
        
        /*
         * Check device's iOS version
         * If it's 8.0 upper, the "Setting" button will lead to device's setting
         */
        
        if (versionNum < 8.0) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:alertTitle message:alertBody
                                                           delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [alert show];
            alert.delegate = self;
        }
        else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:alertTitle message:alertBody
                                                           delegate:self cancelButtonTitle:@"OK" otherButtonTitles: @"Setting", nil];
            [alert show];
            alert.delegate = self;
        }
        return;
    }
    else{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Congratulations!" message:[NSString stringWithFormat:@"Current image is successfully saved in your device!"]
                                                       delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
    }
}

//----------------------------------------------------
#pragma mark Delegate for Back button
//----------------------------------------------------
- (void)tapBackButton:(id)sender
{
    [self.delegate didRemoveFromSuperView];
}

//----------------------------------------------------
#pragma mark  Set up thumbs view
//----------------------------------------------------

-(void)setUpThumbsView
{
    _thumbsView.backgroundColor = [UIColor whiteColor];
    _thumbsView.hidden = YES;
    _thumbsView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [self.view addSubview: _thumbsView];
    //Width Constrain
    [_thumbsView addConstraint:[NSLayoutConstraint
                               constraintWithItem:_thumbsView
                               attribute:NSLayoutAttributeWidth
                               relatedBy:NSLayoutRelationEqual
                               toItem:nil
                               attribute:NSLayoutAttributeWidth
                               multiplier:1.0
                               constant:self.view.frame.size.width]];
    
    //Height Constrain
    [_thumbsView addConstraint:[NSLayoutConstraint
                                constraintWithItem:_thumbsView
                                attribute:NSLayoutAttributeHeight
                                relatedBy:NSLayoutRelationEqual
                                toItem:nil
                                attribute:NSLayoutAttributeHeight
                                multiplier:1.0
                                constant:self.view.frame.size.height]];
    
    //Top Constrain
    [self.view addConstraint:[NSLayoutConstraint
                                constraintWithItem:_thumbsView
                                attribute:NSLayoutAttributeTop
                                relatedBy:NSLayoutRelationEqual
                                toItem:self.view
                                attribute:NSLayoutAttributeTop
                                multiplier:1.0
                                constant:0.0]];
    
    //Leading Constrain
    [self.view addConstraint:[NSLayoutConstraint
                                constraintWithItem:_thumbsView
                              attribute:NSLayoutAttributeLeading
                                relatedBy:NSLayoutRelationEqual
                                toItem:self.view
                                attribute:NSLayoutAttributeLeading
                                multiplier:1.0
                                constant:0.0]];
    
    // create the thumbnail views
    [self buildThumbsViewPhotos];
}
//----------------------------------------------------
#pragma mark Load thumbs view
//----------------------------------------------------
-(void)loadThumbsView:(id)sender
{
    [self removePlayButton];
    
    if (_isThumbViewShowing) {
        [self hideThumbnailViewWithAnimation:YES];
        _uib_share.hidden = NO;
    }
    else {
        [self showThumbnailViewWithAnimation:YES];
        _uib_share.hidden = YES;
    }
}

- (void)showThumbnailViewWithAnimation:(BOOL)animation
{
    _isThumbViewShowing = YES;
    
    [self layoutThumbs];
    [self.navigationItem.rightBarButtonItem setTitle:NSLocalizedString(@"Close", @"")];
    [_uib_thumbView setTitle:@"Close" forState:UIControlStateNormal];
    if (animation) {
        // do curl animation
        [UIView beginAnimations:@"uncurl" context:nil];
        [UIView setAnimationDuration:.666];
        [UIView setAnimationTransition:UIViewAnimationTransitionCurlDown forView:_thumbsView cache:YES];
        [_thumbsView setHidden:NO];
        [UIView commitAnimations];
    }
    else {
        [_thumbsView setHidden:NO];
    }
}


- (void)hideThumbnailViewWithAnimation:(BOOL)animation
{
    _isThumbViewShowing = NO;
    [self.navigationItem.rightBarButtonItem setTitle:NSLocalizedString(@"See all", @"")];
    [_uib_thumbView setTitle:@"See All" forState:UIControlStateNormal];
    if (animation) {
        // do curl animation
        [UIView beginAnimations:@"curl" context:nil];
        [UIView setAnimationDuration:.666];
        [UIView setAnimationTransition:UIViewAnimationTransitionCurlUp forView:_thumbsView cache:YES];
        [_thumbsView setHidden:YES];
        [UIView commitAnimations];
    }
    else {
        [_thumbsView setHidden:NO];
    }
}

// creates all the image views for this gallery
- (void)buildThumbsViewPhotos
{
    NSUInteger i, count = itemsNum;
    for (i = 0; i < count; i++) {
        
        FGalleryPhotoView *thumbView = [[FGalleryPhotoView alloc] initWithFrame:CGRectZero target:self action:@selector(handleThumbClick:)];
        [thumbView setContentMode:UIViewContentModeScaleAspectFill];
        [thumbView setClipsToBounds:YES];
        [thumbView setTag:i];
        UIImage *rawImage = [UIImage imageNamed:arr_images[i]];
        UIGraphicsBeginImageContext(CGSizeMake(kThumbnailSize,kThumbnailSize));
        [rawImage drawInRect: CGRectMake(0, 0, kThumbnailSize, kThumbnailSize)];
        UIImage *smallImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        thumbView.imageView.image = smallImage;
        [_thumbsView addSubview:thumbView];
        [_photoThumbnailViews addObject:thumbView];
    }
}

- (void)layoutThumbs
{
    float dx = 0.0;
    float dy = 49.0;
    // loop through all thumbs to size and place them
    NSUInteger i, count = [_photoThumbnailViews count];
    for (i = 0; i < count; i++) {
        FGalleryPhotoView *thumbView = [_photoThumbnailViews objectAtIndex:i];
        [thumbView setBackgroundColor:[UIColor grayColor]];
        
        // create new frame
        thumbView.frame = CGRectMake( dx, dy, kThumbnailSize, kThumbnailSize);
        
        // increment position
        dx += kThumbnailSize + kThumbnailSpacing;
        
        // check if we need to move to a different row
        if( dx + kThumbnailSize + kThumbnailSpacing > _thumbsView.frame.size.width - kThumbnailSpacing )
        {
            dx = 0.0;
            dy += kThumbnailSize + kThumbnailSpacing;
        }
    }
    
    // set the content size of the thumb scroller
    [_thumbsView setContentSize:CGSizeMake( _thumbsView.frame.size.width - ( kThumbnailSpacing*2 ), dy + kThumbnailSize + kThumbnailSpacing )];
}

- (void)handleThumbClick:(id)sender
{
    FGalleryPhotoView *photoView = (FGalleryPhotoView*)[(UIButton*)sender superview];
    [self hideThumbnailViewWithAnimation:YES];
    [self loadPage:(int)photoView.tag];
    _currentPage = (int)photoView.tag;
    _uil_numLabel.text = [NSString stringWithFormat:@"%i of %i", (int)_currentPage+1, itemsNum];
    _uil_caption.text = [arr_captions objectAtIndex: _currentPage];
    [self checkPageViewContentType];
    _uib_share.hidden = NO;
}

//----------------------------------------------------
#pragma mark - Set up bottom View
//----------------------------------------------------
-(void)createBottomView
{
    _uiv_bottomView = [[UIView alloc] initWithFrame:CGRectMake(0.0, self.view.frame.size.height - kBottomViewHeight, self.view.frame.size.width, kBottomViewHeight)];
    _uiv_bottomView.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.9];
    _uiv_bottomView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    [self.view addSubview: _uiv_bottomView];
       
    // Height constraint, kTopViewHeight
    [_uiv_bottomView addConstraint:[NSLayoutConstraint constraintWithItem:_uiv_bottomView
                                                             attribute:NSLayoutAttributeHeight
                                                             relatedBy:NSLayoutRelationEqual
                                                                toItem:nil
                                                             attribute:NSLayoutAttributeHeight
                                                            multiplier:1.0
                                                              constant:kBottomViewHeight]];
    
    // X constraint, 0.0
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_uiv_bottomView
                                                          attribute:NSLayoutAttributeLeft
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeLeft
                                                         multiplier:1.0
                                                           constant:0.0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_uiv_bottomView
                                                          attribute:NSLayoutAttributeRight
                                                          relatedBy:NSLayoutRelationEqual
                                                          toItem:self.view
                                                          attribute:NSLayoutAttributeRight
                                                         multiplier:1.0
                                                           constant:0.0]];
    // Y constraint, 0.0
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_uiv_bottomView
                                                          attribute:NSLayoutAttributeBottom
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeBottom
                                                         multiplier:1.0
                                                           constant:0.0]];
    
    
    _uil_caption = [[UILabel alloc] initWithFrame:CGRectMake(20.0, 0.0, 200.0, kBottomViewHeight)];
    _uil_caption.backgroundColor = [UIColor clearColor];
    [_uil_caption setText:[arr_captions objectAtIndex:_currentPage]];
    [_uil_caption setTextColor: [UIColor blackColor]];
    _uil_caption.font = [UIFont systemFontOfSize:13.0];
    [_uiv_bottomView addSubview: _uil_caption];
}

//----------------------------------------------------
#pragma mark - PageViewController

#pragma mark Set up page view
//----------------------------------------------------
- (embModelController *)modelController
{
    // Return the model controller object, creating it if necessary.
    // In more complex implementations, the model controller may be passed to the view controller.
    if (!_modelController) {
        _modelController = [[embModelController alloc] initWithImage:arr_images];
    }
    return _modelController;
}

-(void)initPageView:(NSInteger)index {
    self.pageViewController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll
                                                              navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal
                                                                            options:[NSDictionary dictionaryWithObject:[NSNumber numberWithFloat:40.0f] forKey:UIPageViewControllerOptionInterPageSpacingKey]];
    self.pageViewController.delegate = self;
    self.pageViewController.dataSource = self.modelController;
    self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.view.autoresizesSubviews =YES;
    self.pageViewController.view.frame = self.view.frame;//CGRectMake(0.0, 0.0, view_width, view_height);//self.view.bounds;
    [self.pageViewController didMoveToParentViewController:self];
    [self addChildViewController:self.pageViewController];
    [self.view addSubview: self.pageViewController.view];
    [self.pageViewController.view setBackgroundColor:[UIColor whiteColor]];
    [self loadPage:(int)index];
}

-(void)loadPage:(int)page {
    embDataViewController *startingViewController = [self.modelController viewControllerAtIndex:page storyboard:[UIStoryboard storyboardWithName:@"Main" bundle:nil] andFrame:CGRectMake(0.0, 0.0, view_width, view_height)];
    
    NSArray *viewControllers = @[startingViewController];
    [self.pageViewController setViewControllers:viewControllers
                                      direction:UIPageViewControllerNavigationDirectionForward
                                       animated:NO
                                     completion:nil];
}

//----------------------------------------------------
#pragma mark update page index
//----------------------------------------------------
- (void)pageViewController:(UIPageViewController *)pageViewController willTransitionToViewControllers:(NSArray *)pendingViewControllers
{
    [self removePlayButton];
}

- (void)pageViewController:(UIPageViewController *)pvc didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray *)previousViewControllers transitionCompleted:(BOOL)completed
{
    // If the page did not turn
    if (!completed)
    {
        // You do nothing because whatever page you thought you were on
        // before the gesture started is still the correct page
        NSLog(@"same page");
        [self checkPageViewContentType];
        return;
    }
    // This is where you would know the page number changed and handle it appropriately
    [self setpageIndex];
}

/*
    Up date panel's title text
 */
- (void) setpageIndex
{
    embDataViewController *theCurrentViewController = [self.pageViewController.viewControllers objectAtIndex:0];
    int index = (int)[self.modelController indexOfViewController:theCurrentViewController];
    _currentPage = index;
    _uil_numLabel.text = [NSString stringWithFormat:@"%i of %i", (int)_currentPage+1, itemsNum];
    _uil_caption.text = [arr_captions objectAtIndex: _currentPage];
    [self checkPageViewContentType];
}

//----------------------------------------------------
#pragma mark - Check current content type
//----------------------------------------------------
- (void)checkPageViewContentType
{
    if ([arr_fileType[_currentPage] isEqualToString:@"movie"]) {
        [self createPlayIcon];
    }
}

//----------------------------------------------------
#pragma mark Create play icon for movie files
//----------------------------------------------------

- (void)createPlayIcon
{
    _uiiv_playMovie = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"play_icon.png"]];
    _uiiv_playMovie.frame = CGRectMake(0.0, 0.0, _uiiv_playMovie.frame.size.width, _uiiv_playMovie.frame.size.height);
    _uiiv_playMovie.center = self.view.center;
    _uiiv_playMovie.contentMode = UIViewContentModeScaleAspectFit;
    [_pageViewController.view addSubview: _uiiv_playMovie];
    UIViewController *viewController = _pageViewController.viewControllers[0];
    [viewController.view viewWithTag:100].userInteractionEnabled = NO;
}
// Remove the play icon image when change page or load thumbs view
- (void)removePlayButton
{
    [_uiiv_playMovie removeFromSuperview];
    _uiiv_playMovie = nil;
}

//----------------------------------------------------
#pragma mark Actions for other type of files
//----------------------------------------------------

//----------------------------------------------------
#pragma mark - Set Tap Gesture
//----------------------------------------------------
- (void)addGestureToView
{
    self.view.userInteractionEnabled = YES;
    
    UITapGestureRecognizer *tapOnView = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapOnView:)];
    tapOnView.numberOfTapsRequired = 1;
    tapOnView.numberOfTouchesRequired = 1;
    [self.view addGestureRecognizer: tapOnView];
    
    //Alloc a double tap (does nothing) to avoid confliction between zooming and hiding top view
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] init];
    doubleTap.numberOfTapsRequired = 2;
    [self.view addGestureRecognizer: doubleTap];
    [tapOnView requireGestureRecognizerToFail:doubleTap];
}

- (void)tapOnView:(UIGestureRecognizer *)gesture
{
    // If current type is movie, then play the file
    if ([arr_fileType[_currentPage] isEqualToString:@"movie"] ) {
        // Replace the alert code to play movie code
        UIAlertView *alert =  [[UIAlertView alloc] initWithTitle:@"Movie"
                                                         message:@"Should play a movie"
                                                        delegate:nil
                                               cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
        return;
    }
    
    //If current type is image, tap to hide top and bottom views
    if (!_uiv_topView.hidden) {
        [UIView animateWithDuration:0.33
                         animations:^{
                             _uiv_topView.alpha = 0.0;
                             _uiv_bottomView.alpha = 0.0;
                             _pageViewController.view.backgroundColor = [UIColor blackColor];
                         }
                         completion:^(BOOL finished){
                             _uiv_topView.hidden = YES;
                             _uiv_bottomView.hidden = YES;
                         }];
    }
    else {
        _uiv_topView.hidden = NO;
        _uiv_bottomView.hidden = NO;
        [UIView animateWithDuration:0.33
                         animations:^{
                             _uiv_topView.alpha = 1.0;
                             _uiv_bottomView.alpha = 1.0;
                             _pageViewController.view.backgroundColor = [UIColor whiteColor];
                         }];
    }
}

#pragma mark - Load email view

- (void)loadEmail
{
    _emailData = [[embEmailData alloc] init];
    _emailData.to = nil;
    _emailData.subject = nil;
    _emailData.body = nil;//kMAILBODY;
    UIImage *attachedImage = [UIImage imageNamed:arr_images[_currentPage]];
    _emailData.attachment = @[attachedImage];
    [self prepareEmailData];
}
#pragma mark Email Delegates
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
            [picker setMessageBody:_emailData.body isHTML:YES]; // depends. Mostly YES, unless you want to send it as plain text (boring)
        
        
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
