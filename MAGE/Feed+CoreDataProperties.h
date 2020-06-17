//
//  Feed+CoreDataProperties.h
//  mage-ios-sdk
//
//  Created by Daniel Barela on 6/2/20.
//  Copyright © 2020 National Geospatial-Intelligence Agency. All rights reserved.
//
//

#import "Feed.h"


NS_ASSUME_NONNULL_BEGIN

@interface Feed (CoreDataProperties)

+ (NSFetchRequest<Feed *> *)fetchRequest;

@property (nullable, nonatomic, retain) NSNumber* id;
@property (nullable, nonatomic, copy) NSString *title;
@property (nullable, nonatomic, copy) NSString *summary;
@property (nullable, nonatomic, retain) id constantParams;
@property (nullable, nonatomic, retain) id variableParams;
@property (nullable, nonatomic, retain) id style;
@property (nullable, nonatomic, retain) NSNumber* pullFrequency;
@property (nullable, nonatomic, retain) NSNumber* updateFrequency;
@property (nullable, nonatomic, retain) NSSet<FeedItem *> *items;
@property (nullable, nonatomic, retain) NSNumber *eventId;


@end

NS_ASSUME_NONNULL_END
