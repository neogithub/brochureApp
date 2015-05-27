//
//  XHSideMenuTableViewController.h
//  brochureApp
//
//  Created by Xiaohe Hu on 5/27/15.
//  Copyright (c) 2015 Xiaohe Hu. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol sideTableDelegate <NSObject>
@required
- (void)didSelectedTheCell:(NSIndexPath *)index;
@end


@interface XHSideMenuTableViewController : UITableViewController <UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, weak) id<sideTableDelegate> delegate;
@end
