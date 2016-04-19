//
//  Role+CoreDataProperties.h
//  mage-ios-sdk
//
//  Created by William Newman on 4/18/16.
//  Copyright © 2016 National Geospatial-Intelligence Agency. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Role.h"

NS_ASSUME_NONNULL_BEGIN

@interface Role (CoreDataProperties)

@property (nullable, nonatomic, retain) id permissions;
@property (nullable, nonatomic, retain) NSString *remoteId;
@property (nullable, nonatomic, retain) NSSet<User *> *user;

@end

@interface Role (CoreDataGeneratedAccessors)

- (void)addUserObject:(User *)value;
- (void)removeUserObject:(User *)value;
- (void)addUser:(NSSet<User *> *)values;
- (void)removeUser:(NSSet<User *> *)values;

@end

NS_ASSUME_NONNULL_END
