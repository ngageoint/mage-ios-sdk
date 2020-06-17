//
//  Feed+CoreDataProperties.m
//  mage-ios-sdk
//
//  Created by Daniel Barela on 6/2/20.
//  Copyright © 2020 National Geospatial-Intelligence Agency. All rights reserved.
//
//

#import "Feed+CoreDataProperties.h"

@implementation Feed (CoreDataProperties)

+ (NSFetchRequest<Feed *> *)fetchRequest {
	return [NSFetchRequest fetchRequestWithEntityName:@"Feed"];
}

@dynamic id;
@dynamic title;
@dynamic summary;
@dynamic constantParams;
@dynamic variableParams;
@dynamic style;
@dynamic updateFrequency;
@dynamic pullFrequency;
@dynamic items;
@dynamic eventId;

@end
