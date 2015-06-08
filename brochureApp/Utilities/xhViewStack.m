//
//  xhViewStack.m
//  ballstonDemo
//
//  Created by Xiaohe Hu on 11/13/14.
//  Copyright (c) 2014 Neoscape. All rights reserved.
//

#import "xhViewStack.h"
#import "ebZoomingScrollView.h"

static float    backAlpha                   = 1.7;

@interface xhViewStack()<UIScrollViewAccessibilityDelegate, UIGestureRecognizerDelegate, ebZoomingScrollViewDelegate>
@property (nonatomic, strong) NSArray                  *arr_rawImg;
@property (nonatomic, strong) NSArray                  *arr_mapImg;
@end

@implementation xhViewStack
@synthesize startIndex;
@synthesize uiv_topView;
@synthesize delegate;

- (id)initWithFrame:(CGRect)frame andImages:(NSArray *)arr_imgs
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.clipsToBounds = NO;
        imgNum = (int)arr_imgs.count;
        _arr_rawImg = [[NSArray alloc] initWithArray:arr_imgs];
        uiv_topView = [[UIView alloc] init];
    }
    return self;
}

- (void)didMoveToSuperview
{
    [self rebuildImageArray];
    [self setZoomingScrViews];
}

#pragma mark - Rebuilding the image array according to the first image index
- (void)rebuildImageArray
{
    if (startIndex == 0)
    {
        _arr_mapImg = [[_arr_rawImg reverseObjectEnumerator] allObjects];
    }
    else
    {
        NSMutableArray *arr_part1 = [[NSMutableArray alloc] init];
        
        for (int i = startIndex; i < _arr_rawImg.count ; i++) {
            [arr_part1 addObject: _arr_rawImg[i]];
        }
        for (int i = 0; i < startIndex; i++) {
            [arr_part1 addObject: _arr_rawImg[i]];
        }
        _arr_mapImg = [[arr_part1 reverseObjectEnumerator] allObjects];
    }
}

#pragma mark - Create zooming scroll views
- (void)setZoomingScrViews
{
    arr_scrViews = [[NSMutableArray alloc] init];
    for (int i = 0; i < imgNum; i++)
    {
        UIView *uiv_container = [[UIView alloc] initWithFrame:self.bounds];
        uiv_container.clipsToBounds = YES;
        uiv_container.layer.masksToBounds = NO;
        uiv_container.layer.shadowOffset = CGSizeMake(-10, -10);
        uiv_container.layer.shadowRadius = 15;
        uiv_container.layer.shadowOpacity = 0.4;
        uiv_container.layer.shadowColor = [UIColor blackColor].CGColor;
        uiv_container.tag = i+10;
        
        ebZoomingScrollView *uis_scrollView = [[ebZoomingScrollView alloc] initWithFrame:uiv_container.bounds image:_arr_mapImg[i] shouldZoom:YES];
        uis_scrollView.clipsToBounds = YES;
        uis_scrollView.userInteractionEnabled = YES;
        uis_scrollView.delegate = self;
        uis_scrollView.tag = 1;
        
        if (i != _arr_mapImg.count - 1) {
            uiv_container.center = CGPointMake(uiv_container.center.x, uiv_container.center.y - 40);
            uiv_container.transform = CGAffineTransformMakeScale(0.95, 0.98);
            uiv_container.alpha = backAlpha;
            uiv_container.layer.shadowColor = [UIColor clearColor].CGColor;
            uiv_container.layer.borderWidth = 2.0;
            uiv_container.layer.borderColor = [UIColor lightGrayColor].CGColor;
        }
        [self addSwipeToScr:uiv_container];
        
        [uiv_container addSubview: uis_scrollView];
        [self addSubview: uiv_container];
    }
    [self updateTopView];
}

#pragma mark Add hotspots view to zooming scroll view
- (void)addHotspotView:(UIView *)hotspotView
{
    [self updateTopView];
    //Olny the views with tag larger than 100 will keep the scale
    hotspotView.tag = 101;
    [uiv_topView insertSubview:hotspotView atIndex:101];
}

#pragma mark Added swipe pan gesture to the view
- (void)addSwipeToScr:(UIView *)view
{
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(photoPanned:)];
    [panGesture setMinimumNumberOfTouches:1];
    [panGesture setMaximumNumberOfTouches:3];
    panGesture.delegate = self;
    [view addGestureRecognizer:panGesture];
}

#pragma mark When pen gesture distance > 300 make the animation
- (void)photoPanned:(UIPanGestureRecognizer *)gesture
{
    UIView *topPhoto = gesture.view;
    CGPoint velocity = [gesture velocityInView:self];
    CGPoint translation = [gesture translationInView:self];
    
    if(gesture.state == UIGestureRecognizerStateChanged) {
        
        CGFloat xPos = topPhoto.center.x + translation.x;
        CGFloat yPos = topPhoto.center.y + translation.y;
        
        topPhoto.center = CGPointMake(xPos, yPos);
        [gesture setTranslation:CGPointMake(0, 0) inView:self];
        
    } else if(gesture.state == UIGestureRecognizerStateEnded || gesture.state == UIGestureRecognizerStateCancelled) {
        
        if(velocity.x > 300) {
            [self animateTopView:topPhoto directionRight:YES];
            
        } else if (velocity.x < -300) {
            [self animateTopView:topPhoto directionRight:NO];
            
        } else {
            [self returnTopView:topPhoto];
            
        }
        
    }
    
}

- (void)returnTopView:(UIView *)gestureView
{
    [UIView animateWithDuration:0.2 animations:^{
        gestureView.frame = self.bounds;
    }];
}

#pragma mark Make the current top view move to the bottom of the stack
- (void)animateTopView:(UIView *)gestureView directionRight:(BOOL)moveRight
{
    CGPoint newCenter = CGPointZero;
    if (moveRight) {
        newCenter = CGPointMake(self.center.x + self.frame.size.width - 60, gestureView.center.y);
    }
    else {
        newCenter = CGPointMake(self.center.x - self.frame.size.width - 90, gestureView.center.y);
    }
    
    [UIView animateWithDuration:0.3 animations:^{
        gestureView.center = newCenter;
    } completion:^(BOOL finished){
        gestureView.layer.shadowColor = [UIColor clearColor].CGColor;
        [UIView animateWithDuration:0.3 animations:^{
            [self sendSubviewToBack:gestureView];
            [self resetTopPosition];
            for (UIView *tmp in [self subviews]) {
                tmp.frame = self.bounds;
            }

            
        } completion:^(BOOL finished){
            [self removeOverlays];
            [self updateTopView];
            for (UIView *tmp in [self restPotos]) {
                tmp.alpha = 1.0;
                tmp.transform = CGAffineTransformIdentity;
                tmp.frame = self.bounds;
            }
            [self scaleBackViews];
            [self.delegate didFinishedSwippingViewStack:self];
        }];
    }];
}

#pragma mark get the second image move to the first place
- (void)resetTopPosition
{
    UIView *topView = [self topPhoto];
    topView.transform = CGAffineTransformIdentity;
    topView.frame = self.bounds;
    topView.alpha = 1.0;
    topView.layer.shadowColor = [UIColor blackColor].CGColor;
    topView.layer.borderWidth = 0.0;
}

- (void)scaleBackViews
{
    [UIView animateWithDuration:0.33 animations:^{
        for (UIView *tmp in [self restPotos]) {
            tmp.center = CGPointMake(tmp.center.x, tmp.center.y - 40);
            tmp.transform = CGAffineTransformMakeScale(0.95, 0.98);
            tmp.alpha = backAlpha;
            tmp.layer.borderWidth = 2.0;
            tmp.layer.borderColor = [UIColor lightGrayColor].CGColor;
        }
    }];
}

- (UIView *)topPhoto {
    return [self.subviews objectAtIndex:[self.subviews count]-1];
}

- (int)getCurrentPageIndex
{
    UIView *top = [self topPhoto];
    return (int)top.tag;
}

- (void)resetScrollView
{
    UIView *top = [self topPhoto];
    for (ebZoomingScrollView *scroll in [top subviews]) {
        [scroll resetScroll];
    }
}

- (NSArray *)restPotos {
    NSRange range = NSMakeRange(0, [self.subviews count]-1);
    return [self.subviews subarrayWithRange:range];
}

- (void)updateTopView
{
    uiv_topView = [[[self.subviews objectAtIndex:[self.subviews count]-1] viewWithTag:1] viewWithTag:2];
}

- (void)removeOverlays
{
    for (UIView *tmp in [uiv_topView subviews]) {
        if (tmp.tag < 100) {
            [tmp removeFromSuperview];
        }
    }
}

- (void)animateViewsOnTop:(int)num
{
    if (num == 1) {
        [self animateTopView:[self.subviews objectAtIndex:self.subviews.count - 1] directionRight:YES];
        return;
    }
    
    UIView *theView = [self viewWithTag:num];
    int layerIndex = (int)[[self subviews] indexOfObject:theView];
    for (int i = 0; i < self.subviews.count - 1 - layerIndex ; i++) {
        UIView *tmp = [self.subviews objectAtIndex:(self.subviews.count - 1 - i)];
        [self animateTopView:tmp directionRight:YES];
    }
}

#pragma mark scroll delegates
-(void)didRemove:(ebZoomingScrollView *)customClass
{

}

#pragma mark - clean memory
- (void)removeFromSuperview
{
    _arr_rawImg = nil;
    _arr_mapImg = nil;
    
    for (UIView __strong *tmp in [self subviews]) {
        [tmp removeFromSuperview];
        tmp = nil;
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
