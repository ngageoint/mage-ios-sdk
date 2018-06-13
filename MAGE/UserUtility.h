//
//  UserUtility.h
//  mage-ios-sdk
//
//

#import <Foundation/Foundation.h>

@interface UserUtility : NSObject

+ (id) singleton;
- (BOOL) isTokenExpired;
- (void) expireToken;
- (void) resetExpiration;
- (void) acceptConsent;
- (void) logout: (void (^)(void)) completion;

@end
