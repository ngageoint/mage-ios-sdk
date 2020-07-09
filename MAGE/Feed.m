//
//  Feed+CoreDataClass.m
//  mage-ios-sdk
//
//  Created by Daniel Barela on 6/2/20.
//  Copyright © 2020 National Geospatial-Intelligence Agency. All rights reserved.
//
//

#import "Feed.h"
#import "FeedItem.h"
#import "MageSessionManager.h"
#import "MageServer.h"

@implementation Feed

- (id) populateObjectFromJson: (NSDictionary *) json withEventId: (NSNumber *) eventId {
    [self setId:[NSNumber numberWithInteger:[[json objectForKey:@"id"] integerValue]]];
    [self setTitle:[json objectForKey:@"title"]];
    [self setSummary:[json objectForKey:@"summary"]];
    [self setConstantParams:[json objectForKey:@"constantParams"]];
    [self setVariableParams:[json objectForKey:@"variableParams"]];
    [self setUpdateFrequency:[json objectForKey:@"updateFrequency"]];
    [self setPullFrequency:[json objectForKey:@"updateFrequency"]];
    [self setStyle:[json objectForKey:@"style"]];
    [self setItemPrimaryProperty:[json objectForKey:@"itemPrimaryProperty"]];
    [self setItemSecondaryProperty:[json objectForKey:@"itemSecondaryProperty"]];
    [self setItemTemporalProperty:[json objectForKey:@"itemTemporalProperty"]];
    [self setItemsHaveIdentity:[json objectForKey:@"itemsHaveIdentity"]];
    [self setItemsHaveSpatialDimension:[[json objectForKey:@"itemsHaveSpatialDimension"] boolValue] ];
    [self setEventId:eventId];
    
    return self;
}

- (nullable NSURL *) iconURL {
    NSString *urlString = [((NSDictionary *)self.style) valueForKey:@"iconUrl"];
    if (urlString != nil) {
        return [NSURL URLWithString:urlString];
    }
    return nil;
}

+ (NSNumber *) feedIdFromJson:(NSDictionary *) json {
    return [NSNumber numberWithInteger:[[json objectForKey:@"id"] integerValue]];
}

+ (NSArray *) getMappableFeeds: (NSNumber *) eventId {
    return [Feed MR_findAllWithPredicate:[NSPredicate predicateWithFormat:@"(itemsHaveSpatialDimension == YES AND eventId == %@)", eventId]];
}

+ (NSMutableArray *) populateFeedsFromJson: (NSArray *) feeds inEventId: (NSNumber *) eventId inContext: (NSManagedObjectContext *) context {
    NSMutableArray *feedRemoteIds = [[NSMutableArray alloc] init];
    NSMutableDictionary *selectedFeedsPerEvent = [[NSUserDefaults.standardUserDefaults objectForKey:@"selectedFeeds"] mutableCopy];
    if (selectedFeedsPerEvent == nil) {
        selectedFeedsPerEvent = [[NSMutableDictionary alloc] init];
    }
    NSMutableArray *selectedFeedsForEvent = [[selectedFeedsPerEvent objectForKey:[eventId stringValue]] mutableCopy];
    if (selectedFeedsForEvent == nil) {
        selectedFeedsForEvent = [[NSMutableArray alloc] init];
    }
    for (id feed in feeds) {
        NSNumber *remoteFeedId = [Feed feedIdFromJson:feed];
        [feedRemoteIds addObject:remoteFeedId];
        Feed *f = [Feed MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"(id == %@ AND eventId == %@)", remoteFeedId, eventId] inContext:context];
        if (f == nil) {
            f = [Feed MR_createEntityInContext:context];
            [selectedFeedsForEvent addObject:remoteFeedId];
        }
        
        [f populateObjectFromJson:feed withEventId:eventId];
    }
    
    [Feed MR_deleteAllMatchingPredicate:[NSPredicate predicateWithFormat:@"(NOT (id IN %@)) AND eventId == %@", feedRemoteIds, eventId] inContext:context];
    
    [selectedFeedsForEvent filterUsingPredicate:[NSPredicate predicateWithFormat:@"self in %@", feedRemoteIds]];
    [selectedFeedsPerEvent setObject:selectedFeedsForEvent forKey:[eventId stringValue]];
    [NSUserDefaults.standardUserDefaults setObject:selectedFeedsPerEvent forKey:@"selectedFeeds"];
    [NSUserDefaults.standardUserDefaults synchronize];
    return feedRemoteIds;
}

+ (NSMutableArray *) populateFeedItemsFromJson: (NSArray *) feedItems inFeedId: (NSNumber *) feedId inContext: (NSManagedObjectContext *) context {
    NSMutableArray *feedItemRemoteIds = [[NSMutableArray alloc] init];
    Feed *feed = [Feed MR_findFirstByAttribute:@"id" withValue:feedId inContext:context];
    for (id feedItem in feedItems) {
        NSNumber *remoteFeedItemId = [FeedItem feedItemIdFromJson:feedItem];
        [feedItemRemoteIds addObject:remoteFeedItemId];
        FeedItem *fi = [FeedItem MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"(id == %@ AND feed == %@)", remoteFeedItemId, feed] inContext:context];
        if (fi == nil) {
            fi = [FeedItem MR_createEntityInContext:context];
        }
        
        [fi populateObjectFromJson:feedItem withFeed:feed];
    }
    
    [FeedItem MR_deleteAllMatchingPredicate:[NSPredicate predicateWithFormat:@"(NOT (id IN %@)) AND feed == %@", feedItemRemoteIds, feed] inContext:context];
    
    return feedItemRemoteIds;
}

+ (void) refreshFeedsForEvent:(NSNumber *)eventId {
    MageSessionManager *manager = [MageSessionManager manager];
    NSURLSessionDataTask *task = [Feed operationToPullFeedsForEvent:eventId success:^{
    } failure:^(NSError *error) {
    }];
    [manager addTask:task];
}

+ (void) pullFeedItemsForFeed:(NSNumber *) feedId inEvent:(NSNumber *) eventId success: (void (^)(void)) success failure: (void (^)(NSError *)) failure {
    MageSessionManager *manager = [MageSessionManager manager];
    NSURLSessionDataTask *task = [Feed operationToPullFeedItemsForFeed:feedId inEvent:eventId success:success failure:failure];
    [manager addTask:task];
}

+ (NSURLSessionDataTask *) operationToPullFeedsForEvent: (NSNumber *) eventId success: (void (^)(void)) success failure: (void (^)(NSError *)) failure {
    
    NSString *url = [NSString stringWithFormat:@"%@/api/events/%@/feeds", [MageServer baseURL], eventId];
    
    MageSessionManager *manager = [MageSessionManager manager];
    NSURLSessionDataTask *task = [manager GET_TASK:url parameters:nil progress:nil success:^(NSURLSessionTask *task, id responseObject) {
        [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
            NSMutableArray *feedRemoteIds = [Feed populateFeedsFromJson:responseObject inEventId:eventId inContext:localContext];
        } completion:^(BOOL contextDidSave, NSError *error) {
            if (error) {
                if (failure) {
                    failure(error);
                }
            } else if (success) {
                NSArray *feeds = [Feed MR_findAll];
                for (Feed *feed in feeds) {
                    [Feed pullFeedItemsForFeed:feed.id inEvent:eventId success:^{
                    } failure:^(NSError *error) {
                    }];
                }
                success();
            }
        }];
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        if (failure) {
            failure(error);
        }
    }];
    
    return task;
}

+ (NSURLSessionDataTask *) operationToPullFeedItemsForFeed: (NSNumber *) feedId inEvent: (NSNumber *) eventId success: (void (^)(void)) success failure: (void (^)(NSError *)) failure {
    NSString *url = [NSString stringWithFormat:@"%@/api/events/%@/feeds/%@/items", [MageServer baseURL], eventId, feedId];
    
    MageSessionManager *manager = [MageSessionManager manager];
    NSURLSessionDataTask *task = [manager GET_TASK:url parameters:nil progress:nil success:^(NSURLSessionTask *task, id responseObject) {
        [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
            NSMutableArray *feedRemoteIds = [Feed populateFeedItemsFromJson:responseObject inFeedId:feedId inContext:localContext];
        } completion:^(BOOL contextDidSave, NSError *error) {
            if (error) {
                if (failure) {
                    failure(error);
                }
            } else if (success) {
                success();
            }
        }];
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        if (failure) {
            failure(error);
        }
    }];
    
    return task;
}

@end
