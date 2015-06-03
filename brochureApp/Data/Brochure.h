//
//  Brochure.h
//  brochureApp
//
//  Created by Xiaohe Hu on 6/3/15.
//  Copyright (c) 2015 Xiaohe Hu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Brochure : NSObject

@property (nonatomic, retain) NSString 	*projectName;

@property (nonatomic, retain) NSString 	*projectData;    //mm-dd-yyyy

@property (nonatomic, retain) NSString 	*projectSummary;

@property (nonatomic, retain) NSString 	*projectType;

@property (nonatomic, retain) NSData	*projectThumb;   //image data

@property (nonatomic, retain) NSArray	*projectGallery; // array of image data

@property (nonatomic, retain) NSArray	*projectCompany; // array of strings for company names

@end
