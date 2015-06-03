//
//  PersistencyManager.m
//  utc
//
//  Created by Evan Buxton on 12/11/14.
//  Copyright (c) 2014 Neoscape. All rights reserved.
//

#import "PersistencyManager.h"

@implementation PersistencyManager
{
	// an array of all albums
	NSMutableArray *brochures;
}

- (id)init
{
	self = [super init];
	if (self) {
        brochures = [[NSMutableArray alloc] init];
		
        Brochure *brochure_sample1 = [[Brochure alloc] init];
        brochure_sample1.projectName = @"Victory Center";
        brochure_sample1.projectDate = @"04-15-2015";
        brochure_sample1.projectType = @"Master Plan";
        brochure_sample1.projectSummary = @"Victory Center Project Summary";
        brochure_sample1.projectUrl = @"www.neoscape.com";
        brochure_sample1.projectGallery = @[@"image1", @"image2"];
        brochure_sample1.projectCompanies = @[@"company1", @"company2"];
        brochure_sample1.projectThumb = nil;
        
        Brochure *brochure_sample2 = [[Brochure alloc] init];
        brochure_sample2.projectName = @"Ballston Quarter";
        brochure_sample2.projectDate = @"05-30-2015";
        brochure_sample2.projectType = @"Commercial";
        brochure_sample2.projectSummary = @"Ballston Quarter Project Summary";
        brochure_sample2.projectUrl = @"www.neoscape.com";
        brochure_sample2.projectGallery = @[@"image1", @"image2"];
        brochure_sample2.projectCompanies = @[@"company1", @"company2"];
        brochure_sample2.projectThumb = nil;
        
        Brochure *brochure_sample3 = [[Brochure alloc] init];
        brochure_sample3.projectName = @"1325 Boylston";
        brochure_sample3.projectDate = @"06-30-2014";
        brochure_sample3.projectType = @"Master Plan";
        brochure_sample3.projectSummary = @"1325 Boylston Summary";
        brochure_sample3.projectUrl = @"www.neoscape.com";
        brochure_sample3.projectGallery = @[@"image1", @"image2"];
        brochure_sample3.projectCompanies = @[@"company1", @"company2"];
        brochure_sample3.projectThumb = nil;
        
        [brochures addObject: brochure_sample1];
        [brochures addObject: brochure_sample2];
        [brochures addObject: brochure_sample3];
	}
	return self;
}

- (NSArray*)getBrochures
{
	return brochures;
}

- (NSMutableArray*)getProjectNames
{
	
	NSMutableArray *arr_names= [[NSMutableArray alloc] init];
	
	for (int i = 0; i < [brochures count]; i++) {
		Brochure *tmpBrochure = brochures [i];
		[arr_names addObject:tmpBrochure.projectName];
	}
	
	return arr_names;
}

- (NSArray*)getSelectedProjectByName:(NSString*)name
{
	NSArray *filtered = [brochures filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"(name == %@)", name]];
	
	NSDictionary *data = filtered[0];
	
    _selectedBrochure = [[Brochure alloc] init];
    
    _selectedBrochure.projectName = [data objectForKey:@"name"];
    
    _selectedBrochure.projectDate = [data objectForKey:@"date"];
    
    _selectedBrochure.projectSummary = [data objectForKey:@"summary"];
    
    _selectedBrochure.projectType = [data objectForKey:@"type"];
    
    _selectedBrochure.projectUrl = [data objectForKey:@"url"];
    
    _selectedBrochure.projectThumb = [data objectForKey:@"thumb"];
    
    _selectedBrochure.projectGallery = [data objectForKey:@"gallery"];
    
    _selectedBrochure.projectCompanies = [data objectForKey:@"companies"];
    
	return filtered;
}

- (NSArray *)getSelectedProjectByCompanyName:(NSString *)companyName
{
    NSPredicate *companyPredicate = [NSPredicate predicateWithFormat:@"companies contains[c] %@", companyName];
    _companyFilterArray = [[NSArray alloc] initWithArray:[brochures filteredArrayUsingPredicate:companyPredicate]];
    return _companyFilterArray;
}
- (NSArray *)getSelectedProjectByType:(NSString *)projectType
{
    NSPredicate *typePredicate = [NSPredicate predicateWithFormat:@"companies contains[c] %@", projectType];
    _typeFilterArray = [[NSArray alloc] initWithArray:[brochures filteredArrayUsingPredicate:typePredicate]];
    return _typeFilterArray;
}

-(Brochure*)getSelectedBrochureData
{
	return _selectedBrochure;
}

@end
