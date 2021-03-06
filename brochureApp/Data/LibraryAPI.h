//
//  LibraryAPI.h
//  utc
//
//  Created by Evan Buxton on 12/11/14.
//  Copyright (c) 2014 Neoscape. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Brochure.h"

@interface LibraryAPI : NSObject

@property (nonatomic, retain) Brochure *selectedBrochure;

+ (LibraryAPI*)sharedInstance;

- (NSArray*)getCompanies;

- (NSMutableArray*)getProjectNames;

- (NSArray *)getProjectTypes;

- (NSArray *)getSelectedProjectByName:(NSString *)name;

- (NSArray*)getSelectedCompanyNamed:(NSString*)name;

- (NSArray *)getSelectedProjectByType:(NSString *)projectType;

- (NSArray *)getFilterdPorjectsNames:(NSArray *)filteredProjects;

- (Brochure *)getSelectedBrochureData;

@end
