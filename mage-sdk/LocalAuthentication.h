//
//  Login.h
//  mage-sdk
//
//  Created by Billy Newman on 2/24/14.
//

#import <Foundation/Foundation.h>

#import "Authentication.h"
#import "User.h"

@protocol LoginDelegate <NSObject>

@optional
- (void) loginSuccess: (User *) token;
- (void) loginFailure;

@end

@interface LocalAuthentication : NSObject<Authentication>

- (id) initWithURL: (NSURL *) baseURL andParameters: (NSDictionary *) parameters;

- (void) login;

@property(strong) NSURL *baseURL;
@property(strong) NSDictionary *parameters;
@property(assign) id<LoginDelegate> delegate;

@end