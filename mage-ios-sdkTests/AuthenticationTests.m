//
//  mage_ios_sdkTests.m
//  mage-ios-sdkTests
//
//  Created by Billy Newman on 3/4/14.
//  Copyright (c) 2014 National Geospatial-Intelligence Agency. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <UIKit/UIKit.h>

#import "LocalAuthentication.h"

#import "TRVSMonitor.h"

#import <OHHTTPStubs/OHHTTPStubs.h>
#import "OHHTTPStubsResponse+JSON.h"
#import "UserUtility.h"

@interface AuthenticationTests : XCTestCase <AuthenticationDelegate> {
	User *user;
	TRVSMonitor *loginMonitor;
	id<Authentication> authentication;
}

@end

@implementation AuthenticationTests

- (void)setUp {
	[super setUp];
	// Put setup code here. This method is called before the invocation of each test method in the class.
	
	loginMonitor = [TRVSMonitor monitor];
	
	authentication = [Authentication authenticationWithType:LOCAL];
	authentication.delegate = self;
}

- (void)tearDown {
	// Put teardown code here. This method is called after the invocation of each test method in the class.
	[super tearDown];
}


- (void)testLoginSuccess {
	
	NSLog(@"Running login test");
	
	NSString *uid = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
	
	NSDictionary *responseJSON = @{
		@"token": @"12345",
		@"user" : @{
			@"username" : @"test",
			@"firstname" : @"Test",
			@"lastname" : @"Test",
			@"email" : @"test@test.com",
			@"phones": @[@"333-111-4444", @"444-555-6767"]
		}
	};
	
	[OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
		return [request.URL.absoluteString isEqualToString:@"https://***REMOVED***/api/login"];
	} withStubResponse:^OHHTTPStubsResponse*(NSURLRequest *request) {
		OHHTTPStubsResponse *response = [OHHTTPStubsResponse responseWithJSONObject:responseJSON statusCode:200 headers:@{@"Content-Type":@"application/json"}];
		return response;
	}];
	
	NSDictionary *parameters =[[NSDictionary alloc] initWithObjectsAndKeys: @"test", @"username", @"12345", @"password", uid, @"uid", nil];
	
	[authentication loginWithParameters:parameters];

	[loginMonitor waitWithTimeout:5000];
	
	XCTAssertNotNil(user, @"'user' object is nil, login was unsuccessful");
	XCTAssertEqualObjects(user.username, @"test", @"username was not set correctly");
//	XCTAssertEqualObjects(user.firstName, @"Test", @"firstname was not set correctly");
//	XCTAssertEqualObjects(user.lastName, @"Test", @"lastname was not set correctly");
	XCTAssertEqualObjects(user.email, @"test@test.com", @"email was not set correctly");
//	XCTAssertEqualObjects(user.phoneNumbers, ([[NSArray alloc] initWithObjects:@"333-111-4444", @"444-555-6767", nil]), @"phone numbers not set correctly");
}

- (void) authenticationWasSuccessful:(User *)token {
	user = token;
	
	[loginMonitor signal];
}
- (void) authenticationHadFailure {
	[loginMonitor signal];
	
}

@end

