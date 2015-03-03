//
//  User+helper.m
//  mage-ios-sdk
//
//  Created by Billy Newman on 6/26/14.
//  Copyright (c) 2014 National Geospatial-Intelligence Agency. All rights reserved.
//

#import "User+helper.h"
#import "HttpManager.h"
#import "MageServer.h"

@implementation User (helper)

static User *currentUser = nil;

+ (User *) insertUserForJson: (NSDictionary *) json myself:(BOOL) myself inManagedObjectContext:(NSManagedObjectContext *) context {
    User *user = [User MR_createEntityInContext:context];
    [user setCurrentUser:[NSNumber numberWithBool:myself]];
    [user updateUserForJson:json];
    
    return user;
}

+ (User *) insertUserForJson: (NSDictionary *) json inManagedObjectContext:(NSManagedObjectContext *) context {
	return [User insertUserForJson:json myself:NO inManagedObjectContext:context];
}

+ (User *) fetchCurrentUserInManagedObjectContext:(NSManagedObjectContext *) managedObjectContext {
    return [User MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"currentUser = %@", [NSNumber numberWithBool:YES]] inContext:managedObjectContext];
}

+ (User *) fetchUserForId:(NSString *) userId {
    return [User MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"remoteId = %@", userId]];
}

- (void) updateUserForJson: (NSDictionary *) json {
    [self setRemoteId:[json objectForKey:@"_id"]];
    [self setUsername:[json objectForKey:@"username"]];
    [self setEmail:[json objectForKey:@"email"]];
    [self setName:[NSString stringWithFormat:@"%@ %@", [json objectForKey:@"firstname"], [json objectForKey:@"lastname"]]];
    
    NSArray *phones = [json objectForKey:@"phones"];
    if (phones != nil && [phones count] > 0) {
        NSDictionary *phone = [phones objectAtIndex:0];
        [self setPhone:[phone objectForKey:@"number"]];
    }
    
    [self setIconUrl:[json objectForKey:@"iconUrl"]];
    [self setAvatarUrl:[json objectForKey:@"avatarUrl"]];
}

+ (void) pullUserIcon: (User *) user {
    NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)objectAtIndex:0];
    NSString *userIconRelativePath = [NSString stringWithFormat:@"userIcons/%@", user.remoteId];
    NSString *userIconPath = [NSString stringWithFormat:@"%@/%@", documentsDirectory, userIconRelativePath];
    HttpManager *http = [HttpManager singleton];
    
    NSURLRequest *request = [http.manager.requestSerializer requestWithMethod:@"GET" URLString:user.iconUrl parameters: nil error: nil];
    AFHTTPRequestOperation *operation = [http.manager HTTPRequestOperationWithRequest:request success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
            User *localUser = [user MR_inContext:localContext];
            localUser.iconUrl = userIconRelativePath;
        }];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        //delete the file
        NSError *deleteError;
        [[NSFileManager defaultManager] removeItemAtPath:userIconPath error:&deleteError];
    }];
    NSError *error;
    if (![[NSFileManager defaultManager] fileExistsAtPath:[userIconPath stringByDeletingLastPathComponent]]) {
        NSLog(@"Creating directory %@", [userIconPath stringByDeletingLastPathComponent]);
        [[NSFileManager defaultManager] createDirectoryAtPath:[userIconPath stringByDeletingLastPathComponent] withIntermediateDirectories:YES attributes:nil error:&error];
    }
    
    [[NSFileManager defaultManager] createFileAtPath:userIconPath contents:nil attributes:nil];
    operation.responseSerializer = [AFHTTPResponseSerializer serializer];
    operation.outputStream = [NSOutputStream outputStreamToFileAtPath:userIconPath append:NO];
    
    [operation start];
}

+ (void) pullUserAvatar: (User *) user {
    NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)objectAtIndex:0];
    NSString *userAvatarRelativePath = [NSString stringWithFormat:@"userAvatars/%@", user.remoteId];
    NSString *userAvatarPath = [NSString stringWithFormat:@"%@/%@", documentsDirectory, userAvatarRelativePath];
    
    HttpManager *http = [HttpManager singleton];
    NSURLRequest *request = [http.manager.requestSerializer requestWithMethod:@"GET" URLString:user.avatarUrl parameters: nil error: nil];
    AFHTTPRequestOperation *operation = [http.manager HTTPRequestOperationWithRequest:request success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
            User *localUser = [user MR_inContext:localContext];
            localUser.avatarUrl = userAvatarRelativePath;
            NSLog(@"set the avatar url on the user to: %@", localUser.avatarUrl);
        }];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        //delete the file
        NSError *deleteError;
        [[NSFileManager defaultManager] removeItemAtPath:userAvatarPath error:&deleteError];
    }];
    NSError *error;
    if (![[NSFileManager defaultManager] fileExistsAtPath:[userAvatarPath stringByDeletingLastPathComponent]]) {
        NSLog(@"Creating directory %@", [userAvatarPath stringByDeletingLastPathComponent]);
        [[NSFileManager defaultManager] createDirectoryAtPath:[userAvatarPath stringByDeletingLastPathComponent] withIntermediateDirectories:YES attributes:nil error:&error];
    }
    
    [[NSFileManager defaultManager] createFileAtPath:userAvatarPath contents:nil attributes:nil];
    operation.responseSerializer = [AFHTTPResponseSerializer serializer];
    operation.outputStream = [NSOutputStream outputStreamToFileAtPath:userAvatarPath append:NO];
    
    [operation start];
}

+ (NSOperation *) operationToFetchUsers {
	NSString *url = [NSString stringWithFormat:@"%@/%@", [MageServer baseURL], @"api/users"];
	
	NSLog(@"Trying to fetch users from server %@", url);
	
    HttpManager *http = [HttpManager singleton];
    
    NSURLRequest *request = [http.manager.requestSerializer requestWithMethod:@"GET" URLString:url parameters: nil error: nil];
    NSOperation *operation = [http.manager HTTPRequestOperationWithRequest:request success:^(AFHTTPRequestOperation *operation, id users) {
        
        [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
            // Get the user ids to query
            NSMutableArray *userIds = [[NSMutableArray alloc] init];
            for (NSDictionary *userJson in users) {
                [userIds addObject:[userJson objectForKey:@"_id"]];
            }
            
            NSArray *usersMatchingIDs = [User MR_findAllWithPredicate:[NSPredicate predicateWithFormat:@"(remoteId IN %@)", userIds] inContext:localContext];
            NSMutableDictionary *userIdMap = [[NSMutableDictionary alloc] init];
            for (User* user in usersMatchingIDs) {
                [userIdMap setObject:user forKey:user.remoteId];
            }
            
            for (NSDictionary *userJson in users) {
                // pull from query map
                NSString *userId = [userJson objectForKey:@"_id"];
                User *user = [userIdMap objectForKey:userId];
                if (user == nil) {
                    // not in core data yet need to create a new managed object
                    NSLog(@"Inserting new user into database");
                    user = [User insertUserForJson:userJson inManagedObjectContext:localContext];
                    // go pull their icon and avatar if they have one
                    if (user.iconUrl != nil) {
                        [User pullUserIcon:user];
                    }
                    if (user.avatarUrl != nil) {
                        [User pullUserAvatar:user];
                    }
                } else {
                    // already exists in core data, lets update the object we have
                    NSLog(@"Updating user location in the database");
                    NSString *oldIcon = user.iconUrl;
                    NSString *oldAvatar = user.avatarUrl;
                    
                    [user updateUserForJson:userJson];
                    // go pull their icon and avatar if they got one
                    if ([[oldIcon lowercaseString] hasPrefix:@"http"] || (oldIcon == nil && user.iconUrl != nil)) {
                        [User pullUserIcon:user];
                    } else {
                        user.iconUrl = oldIcon;
                    }
                    if ([[oldAvatar lowercaseString] hasPrefix:@"http"] || (oldAvatar == nil && user.avatarUrl != nil)) {
                        [User pullUserAvatar:user];
                    } else {
                        user.avatarUrl = oldAvatar;
                    }
                }
            }
        }];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
    return operation;
}

@end
