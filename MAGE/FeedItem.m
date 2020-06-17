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
    return self.primaryValue || self.secondaryValue || self.iconURL;
}

- (SFGeometry *) simpleFeature {
    return [GeometryUtility toGeometryFromGeometryData:self.geometry];
}

- (void) setSimpleFeature:(SFGeometry *)simpleFeature {
    self.geometry = [GeometryUtility toGeometryDataFromGeometry:simpleFeature];
}

- (NSString *) primaryValue {
    NSDictionary *propertyDictionary = self.properties;
    return [propertyDictionary valueForKey:@"Property 1"];
}

- (NSString *) secondaryValue {
    return [((NSDictionary *)self.properties) valueForKey:@"Property 2"];
}

- (NSURL *) iconURL {
    NSString *urlString = [((NSDictionary *)self.feed.style) valueForKey:@"iconUrl"];
    if (urlString != nil) {
        return [NSURL URLWithString:urlString];
    }
    return nil;
}

- (NSDate *) timestamp {
    return [((NSDictionary *)self.properties) valueForKey:@"timestamp"];
}

- (NSString *) title {
    return self.primaryValue;
}

- (NSString *) subtitle {
    return self.secondaryValue;
}

- (CLLocationCoordinate2D) coordinate {
    SFPoint *centroid = [self.simpleFeature centroid];
    return CLLocationCoordinate2DMake([centroid.y doubleValue], [centroid.x doubleValue]);
}

- (BOOL) isMappable {
    return self.geometry != nil;
}

@end
