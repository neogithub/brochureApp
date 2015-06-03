//
//  PersistencyManager.h
//  utc
//
//  Created by Evan Buxton on 12/11/14.
//  Copyright (c) 2014 Neoscape. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Brochure.h"

@interface PersistencyManager : NSObject

@property (nonatomic, retain) Brochure  *selectedBrochure;
@property (nonatomic, retain) NSArray   *typeFilterArray;
@property (nonatomic, retain) NSArray   *companyFilterArray;

- (NSArray *)getBrochures;

- (NSMutableArray *)getProjectNames;

- (NSArray *)getSelectedProjectByName:(NSString *)name;

- (NSArray *)getSelectedProjectByCompanyName:(NSString *)companyName;

- (NSArray *)getSelectedProjectByType:(NSString *)projectType;

- (NSArray *)getFilterdPorjectsNames:(NSArray *)filteredProjects;

- (Brochure *)getSelectedBrochureData;

@end
