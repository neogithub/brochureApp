//
//  xhViewStack.h
//  ballstonDemo
//
//  Created by Xiaohe Hu on 11/13/14.
//  Copyright (c) 2014 Neoscape. All rights reserved.
//

#import <UIKit/UIKit.h>
@class xhViewStack;
@protocol xhViewStackDelegate
- (void)didFinishedSwippingViewStack:(xhViewStack *)viewStack;
@end



@interface xhViewStack : UIView
{
    int                         imgNum;
    NSMutableArray              *arr_scrViews;
}
@property (nonatomic, strong)    id             delegate;
@property (nonatomic, readwrite) int            startIndex;
@property (nonatomic, strong)    UIView         *uiv_topView;

- (id)initWithFrame:(CGRect)frame andImages:(NSArray *)arr_imgs;
- (void)removeOverlays;
- (int)getCurrentPageIndex;
- (void)animateTopView:(UIView *)gestureView directionRight:(BOOL)moveRight;
- (void)animateViewsOnTop:(int)num;
- (void)addHotspotView:(UIView *)hotspotView;
- (void)resetScrollView;
@end
