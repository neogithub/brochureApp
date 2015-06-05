//
//  DetailViewController.h
//  brochureApp
//
//  Created by Xiaohe Hu on 5/20/15.
//  Copyright (c) 2015 Xiaohe Hu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Brochure.h"
@interface DetailViewController : UIViewController
@property (nonatomic, strong)        Brochure   *projectBrochure;
@property (weak, nonatomic) IBOutlet UILabel    *uil_title;
@end
