//
//  FeedItem+CoreDataClass.m
//  mage-ios-sdk
//
//  Created by Daniel Barela on 6/2/20.
//  Copyright © 2020 National Geospatial-Intelligence Agency. All rights reserved.
//
//

#import "FeedItem.h"
#import "GeometryUtility.h"
#import "GeometryDeserializer.h"

@implementation FeedItem

+ (NSArray<FeedItem*> *) getFeedItemsForFeed: (NSNumber *) feedId {
    Feed *feed = [Feed MR_findFirstByAttribute:@"id" withValue:feedId];
    return [FeedItem MR_findAllWithPredicate:[NSPredicate predicateWithFormat:@"(feed == %@)", feed]];
}

- (id) populateObjectFromJson: (NSDictionary *) json withFeed: (Feed *) feed {
    [self setId:[NSNumber numberWithInteger:[[json objectForKey:@"id"] integerValue]]];
    @try {
        SFGeometry * geometry = [GeometryDeserializer parseGeometry:[json valueForKeyPath:@"geometry"]];
        [self setSimpleFeature:geometry];
    }
    @catch (NSException *e){
        NSLog(@"Problem parsing geometry %@", e);
    }
    [self setProperties:[json objectForKey: @"properties"]];
    [self setFeed:feed];
        
    return self;
}

+ (NSNumber *) feedItemIdFromJson:(NSDictionary *) json {
    return [NSNumber numberWithInteger:[[json objectForKey:@"id"] integerValue]];
}

- (BOOL) hasContent {
    return self.primaryValue || self.secondaryValue || ([self isTemporal] && self.timestamp != nil);
}

- (SFGeometry *) simpleFeature {
    return [GeometryUtility toGeometryFromGeometryData:self.geometry];
}

- (void) setSimpleFeature:(SFGeometry *)simpleFeature {
    self.geometry = [GeometryUtility toGeometryDataFromGeometry:simpleFeature];
}

- (nullable NSString *) primaryValue {
    return [((NSDictionary *)self.properties)  valueForKey:self.feed.itemPrimaryProperty];
}

- (nullable NSString *) secondaryValue {
    return [((NSDictionary *)self.properties) valueForKey:self.feed.itemSecondaryProperty];
}

- (nullable NSURL *) iconURL {
    return self.feed.iconURL;
}

- (nullable NSDate *) timestamp {
    NSNumber *epochTime = [((NSDictionary *)self.properties) valueForKey:self.feed.itemTemporalProperty];
    if (epochTime == nil) {
        return nil;
    }
    return [NSDate dateWithTimeIntervalSince1970: epochTime.doubleValue];
}

- (NSString *) title {
    if (self.primaryValue == nil) {
        return @" ";
    }
    return self.primaryValue;
}

- (nullable NSString *) subtitle {
    return self.secondaryValue;
}

- (CLLocationCoordinate2D) coordinate {
    SFPoint *centroid = [self.simpleFeature centroid];
    return CLLocationCoordinate2DMake([centroid.y doubleValue], [centroid.x doubleValue]);
}

- (BOOL) isMappable {
    return self.geometry != nil;
}

- (BOOL) isTemporal {
    return self.feed.itemTemporalProperty != nil;
}

@end
