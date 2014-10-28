//
//  User+helper.h
//  mage-ios-sdk
//
//  Created by Billy Newman on 6/26/14.
//  Copyright (c) 2014 National Geospatial-Intelligence Agency. All rights reserved.
//

#import "User.h"

@interface User (helper)

+ (User *) insertUserForJson: (NSDictionary *) json;
+ (User *) insertUserForJson: (NSDictionary *) json myself:(BOOL) myself;
+ (User *) fetchUserForId:(NSString *) userId;
+ (User *) fetchCurrentUser;
+ (NSOperation *) operationToFetchUsers;

- (void) updateUserForJson: (NSDictionary *) json;

@end
