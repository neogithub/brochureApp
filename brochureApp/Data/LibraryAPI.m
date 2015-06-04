//
//  LibraryAPI.m
//  utc
//
//  Created by Evan Buxton on 12/11/14.
//  Copyright (c) 2014 Neoscape. All rights reserved.
//

#import "LibraryAPI.h"
#import "PersistencyManager.h"

@implementation LibraryAPI
{
	PersistencyManager *persistencyManager;
}

+ (LibraryAPI*)sharedInstance
{
	// 1
	static LibraryAPI *_sharedInstance = nil;
 
	// 2
	static dispatch_once_t oncePredicate;
 
	// 3
	dispatch_once(&oncePredicate, ^{
		_sharedInstance = [[LibraryAPI alloc] init];
	});
	return _sharedInstance;
}

- (id)init
{
	self = [super init];
	if (self) {
		persistencyManager = [[PersistencyManager alloc] init];
	}
	return self;
}

- (NSArray*)getCompanies
{
	return [persistencyManager getBrochures];
}

- (NSMutableArray*)getProjectNames
{
	return [persistencyManager getProjectNames];
}

- (NSArray *)getProjectTypes
{
    return [persistencyManager getProjectTypes];
}

- (NSArray*)getSelectedCompanyNamed:(NSString*)name
{
	return [persistencyManager getSelectedProjectByCompanyName:name];
}

- (NSArray *)getSelectedProjectByName:(NSString *)name
{
    return [persistencyManager getSelectedProjectByCompanyName:name];
}

- (NSArray *)getSelectedProjectByType:(NSString *)projectType
{
    return [persistencyManager getSelectedProjectByType:projectType];
}

- (NSArray *)getFilterdPorjectsNames:(NSArray *)filteredProjects
{
    return [persistencyManager getFilterdPorjectsNames:filteredProjects];
}

- (Brochure *)getSelectedBrochureData
{
    return [persistencyManager getSelectedBrochureData];
}


@end
