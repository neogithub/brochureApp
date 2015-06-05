//
//  Brochure.h
//  brochureApp
//
//  Created by Xiaohe Hu on 6/3/15.
//  Copyright (c) 2015 Xiaohe Hu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Brochure : NSObject

@property (nonatomic, retain) NSString      *projectName;

@property (nonatomic, retain) NSString      *projectDate;       //mm-dd-yyyy

@property (nonatomic, retain) NSDictionary 	*projectSummary;

@property (nonatomic, retain) NSString      *projectType;       // Residence, Commercial, Mixed...

@property (nonatomic, retain) NSString      *projectUrl;        // The link to fentch pdf data

@property (nonatomic, retain) NSData        *projectThumb;      //image data

@property (nonatomic, retain) NSArray       *projectGallery;    // array of image data

@property (nonatomic, retain) NSArray       *projectCompanies;  // array of strings for company names

@end
