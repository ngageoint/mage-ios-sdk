//
//  Feed+CoreDataClass.h
//  mage-ios-sdk
//
//  Created by Daniel Barela on 6/2/20.
//  Copyright © 2020 National Geospatial-Intelligence Agency. All rights reserved.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class FeedItem, Event, NSObject;

NS_ASSUME_NONNULL_BEGIN

@interface Feed : NSManagedObject

+ (NSMutableArray *) populateFeedsFromJson: (NSArray *) feeds inEventId: (NSNumber *) eventId inContext: (NSManagedObjectContext *) context;
+ (NSMutableArray *) populateFeedItemsFromJson: (NSArray *) feedItems inFeedId: (NSNumber *) feedId inContext: (NSManagedObjectContext *) context;
+ (NSNumber *) feedIdFromJson:(NSDictionary *) json;
+ (NSURLSessionDataTask *) operationToPullFeedsForEvent: (NSNumber *) eventId success: (void (^)(void)) success failure: (void (^)(NSError *)) failure;
+ (NSURLSessionDataTask *) operationToPullFeedItemsForFeed: (NSNumber *) feedId inEvent: (NSNumber *) eventId success: (void (^)(void)) success failure: (void (^)(NSError *)) failure;
+ (void) refreshFeedsForEvent:(NSNumber *)eventId;
+ (void) pullFeedItemsForFeed:(NSNumber *) feedId inEvent:(NSNumber *) eventId success: (void (^)(void)) success failure: (void (^)(NSError *)) failure;

@end

NS_ASSUME_NONNULL_END

#import "Feed+CoreDataProperties.h"
