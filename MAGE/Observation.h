//
//  Observation.h
//  mage-ios-sdk
//
//  Created by Dan Barela on 6/27/14.
//  Copyright (c) 2014 National Geospatial-Intelligence Agency. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Attachment;

@interface Observation : NSManagedObject

@property (nonatomic, retain) NSString * deviceId;
@property (nonatomic, retain) NSNumber * dirty;
@property (nonatomic, retain) id geometry;
@property (nonatomic, retain) NSDate * lastModified;
@property (nonatomic, retain) NSString * remoteId;
@property (nonatomic, retain) NSNumber * state;
@property (nonatomic, retain) NSString * url;
@property (nonatomic, retain) NSString * userId;
@property (nonatomic, retain) id properties;
@property (nonatomic, retain) NSSet *attachments;
@end

@interface Observation (CoreDataGeneratedAccessors)

- (void)addAttachmentsObject:(Attachment *)value;
- (void)removeAttachmentsObject:(Attachment *)value;
- (void)addAttachments:(NSSet *)values;
- (void)removeAttachments:(NSSet *)values;

@end
