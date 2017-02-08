//
//  HttpManager.h
//  mage-ios-sdk
//
//

#import <Foundation/Foundation.h>
#import <AFNetworking.h>

@interface HttpManager : NSObject

extern NSString * const MAGETokenExpiredNotification;

+ (HttpManager *) singleton;
@property(strong) AFHTTPSessionManager *manager;
@property(strong) AFHTTPSessionManager *sessionManager;
@property(strong) AFHTTPSessionManager *downloadManager;

-(void) setToken: (NSString *) token;

-(void) clearToken;

@end
