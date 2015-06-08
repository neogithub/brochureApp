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
		
        NSData *allCoursesData = [[NSData alloc] initWithContentsOfURL:
                                  [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"brochure" ofType:@"json"]]];
        NSError *error;
        NSArray *rawData = [NSJSONSerialization
                                           JSONObjectWithData:allCoursesData
                                           options:NSJSONReadingMutableContainers
                                           error:&error];
        
        
        for (int i = 0; i < rawData.count; i++) {
            Brochure *brochure = [[Brochure alloc] init];
            NSDictionary *brochureData = rawData[i];
            brochure.projectName = brochureData[@"name"];
            brochure.projectDate = brochureData[@"date"];
            brochure.projectType = brochureData[@"type"];
            brochure.projectPdfFiles = brochureData[@"pdf"];
            brochure.projectSummary = brochureData[@"summary"];
            brochure.projectUrl = brochureData[@"shareUrl"];
            brochure.projectGallery = brochureData[@"gallery"];
            brochure.projectThumbs = brochureData[@"thumbs"];
            //Need to add to json
            brochure.projectCompanies = @[@"company1", @"company2"];
            [brochures addObject:brochure];
        }
        
//        Brochure *brochure_sample1 = [[Brochure alloc] init];
//        brochure_sample1.projectName = @"Victory Center";
//        brochure_sample1.projectDate = @"04-15-2015";
//        brochure_sample1.projectType = @"residence";
//        brochure_sample1.projectPdfFile = @"ballston leasing book with cards-2.pdf";
//        brochure_sample1.projectSummary = @{
//                                            @"location" : @"the location of this project",
//                                            @"price" : @"the price of this project",
//                                            @"description" : @"the description of this project"
//                                            };
//        brochure_sample1.projectUrl = @"www.neoscape.com";
//        brochure_sample1.projectGallery = @[@"grfx_launching.jpg", @"grfx_launching.png"];
//        brochure_sample1.projectCompanies = @[@"company1", @"company2"];
//        brochure_sample1.projectThumb = nil;
//        
//        Brochure *brochure_sample2 = [[Brochure alloc] init];
//        brochure_sample2.projectName = @"Ballston Quarter";
//        brochure_sample2.projectDate = @"05-30-2015";
//        brochure_sample2.projectType = @"commercial";
//        brochure_sample2.projectPdfFile = @"ballston leasing book with cards-2.pdf";
//        brochure_sample2.projectSummary = @{
//                                            @"location" : @"the location of this project",
//                                            @"price" : @"the price of this project",
//                                            @"description" : @"the description of this project"
//                                            };
//        brochure_sample2.projectUrl = @"www.neoscape.com";
//        brochure_sample2.projectGallery = @[@"grfx_launching.jpg", @"grfx_launching.png"];
//        brochure_sample2.projectCompanies = @[@"company1", @"company2"];
//        brochure_sample2.projectThumb = nil;
//        
//        Brochure *brochure_sample3 = [[Brochure alloc] init];
//        brochure_sample3.projectName = @"1325 Boylston";
//        brochure_sample3.projectDate = @"06-30-2014";
//        brochure_sample3.projectType = @"master plan";
//        brochure_sample3.projectPdfFile = @"ballston leasing book with cards-2.pdf";
//        brochure_sample3.projectSummary = @{
//                                            @"location" : @"the location of this project",
//                                            @"price" : @"the price of this project",
//                                            @"description" : @"the description of this project"
//                                            };
//        brochure_sample3.projectUrl = @"www.neoscape.com";
//        brochure_sample3.projectGallery = @[@"grfx_launching.jpg", @"grfx_launching.png"];
//        brochure_sample3.projectCompanies = @[@"company1", @"company2"];
//        brochure_sample3.projectThumb = nil;
//        
//        Brochure *brochure_sample4 = [[Brochure alloc] init];
//        brochure_sample4.projectName = @"Pike and Rose";
//        brochure_sample4.projectDate = @"01-30-2012";
//        brochure_sample4.projectType = @"mixed";
//        brochure_sample4.projectPdfFile = @"ballston leasing book with cards-2.pdf";
//        brochure_sample4.projectSummary = @{
//                                            @"location" : @"the location of this project",
//                                            @"price" : @"the price of this project",
//                                            @"description" : @"the description of this project"
//                                            };
//        brochure_sample4.projectUrl = @"www.neoscape.com";
//        brochure_sample4.projectGallery = @[@"grfx_launching.jpg", @"grfx_launching.png"];
//        brochure_sample4.projectCompanies = @[@"company1", @"company2"];
//        brochure_sample4.projectThumb = nil;
//        
//        Brochure *brochure_sample5 = [[Brochure alloc] init];
//        brochure_sample5.projectName = @"Assembly Row";
//        brochure_sample5.projectDate = @"09-30-2012";
//        brochure_sample5.projectType = @"master plan";
//        brochure_sample5.projectPdfFile = @"ballston leasing book with cards-2.pdf";
//        brochure_sample5.projectSummary = @{
//                                            @"location" : @"the location of this project",
//                                            @"price" : @"the price of this project",
//                                            @"description" : @"the description of this project"
//                                            };
//        brochure_sample5.projectUrl = @"www.neoscape.com";
//        brochure_sample5.projectGallery = @[@"grfx_launching.jpg", @"grfx_launching.png"];
//        brochure_sample5.projectCompanies = @[@"company1", @"company2"];
//        brochure_sample5.projectThumb = nil;
//        
//        Brochure *brochure_sample6 = [[Brochure alloc] init];
//        brochure_sample6.projectName = @"Skanska";
//        brochure_sample6.projectDate = @"11-30-2014";
//        brochure_sample6.projectType = @"master plan";
//        brochure_sample6.projectPdfFile = @"ballston leasing book with cards-2.pdf";
//        brochure_sample6.projectSummary = @{
//                                            @"location" : @"the location of this project",
//                                            @"price" : @"the price of this project",
//                                            @"description" : @"the description of this project"
//                                            };
//        brochure_sample6.projectUrl = @"www.neoscape.com";
//        brochure_sample6.projectGallery = @[@"grfx_launching.jpg", @"grfx_launching.png"];
//        brochure_sample6.projectCompanies = @[@"company1", @"company2"];
//        brochure_sample6.projectThumb = nil;
//        
//        [brochures addObject: brochure_sample1];
//        [brochures addObject: brochure_sample2];
//        [brochures addObject: brochure_sample3];
//        [brochures addObject: brochure_sample4];
//        [brochures addObject: brochure_sample5];
//        [brochures addObject: brochure_sample6];
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
	
	for (int i = 0; i < [brochures count]; i++)
    {
		Brochure *tmpBrochure = brochures [i];
		[arr_names addObject:tmpBrochure.projectName];
	}
	
	return arr_names;
}

- (NSArray *)getProjectTypes
{
    NSMutableArray *types = [[NSMutableArray alloc] init];
    for (Brochure *tmpBrochure in brochures) {
        [types addObject: tmpBrochure.projectType];
    }
    NSOrderedSet *orderedSet = [NSOrderedSet orderedSetWithArray:types];
    return [orderedSet array];
}


- (NSArray*)getSelectedProjectByName:(NSString*)name
{
	NSArray *filtered = [brochures filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"(projectName == %@)", name]];
	
	NSDictionary *data = filtered[0];
	
    _selectedBrochure = [[Brochure alloc] init];
    
    _selectedBrochure.projectName = [data objectForKey:@"name"];
    
    _selectedBrochure.projectDate = [data objectForKey:@"date"];
    
    _selectedBrochure.projectSummary = [data objectForKey:@"summary"];
    
    _selectedBrochure.projectType = [data objectForKey:@"type"];
    
    _selectedBrochure.projectUrl = [data objectForKey:@"url"];
    
    _selectedBrochure.projectThumbs = [data objectForKey:@"thumb"];
    
    _selectedBrochure.projectGallery = [data objectForKey:@"gallery"];
    
    _selectedBrochure.projectCompanies = [data objectForKey:@"companies"];
    
    _selectedBrochure.projectPdfFiles = [data objectForKey:@"pdf"];
    
	return filtered;
}

- (NSArray *)getSelectedProjectByCompanyName:(NSString *)companyName
{
    NSPredicate *companyPredicate = [NSPredicate predicateWithFormat:@"(projectName == %@)", companyName];
    _companyFilterArray = [[NSArray alloc] initWithArray:[brochures filteredArrayUsingPredicate:companyPredicate]];
    return _companyFilterArray;
}
- (NSArray *)getSelectedProjectByType:(NSString *)projectType
{
    NSPredicate *typePredicate = [NSPredicate predicateWithFormat:@"(projectType == %@)", projectType];
    _typeFilterArray = [[NSArray alloc] initWithArray:[brochures filteredArrayUsingPredicate:typePredicate]];
    return _typeFilterArray;
}

- (NSArray *)getFilterdPorjectsNames:(NSArray *)filteredProjects
{
    NSMutableArray *projectNames = [NSMutableArray new];
    for (Brochure *tmpBrochure in filteredProjects) {
        [projectNames addObject: tmpBrochure.projectName];
    }
    return projectNames;
}

-(Brochure*)getSelectedBrochureData
{
	return _selectedBrochure;
}

@end
