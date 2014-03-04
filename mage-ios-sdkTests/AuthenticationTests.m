//
//  mage_ios_sdkTests.m
//  mage-ios-sdkTests
//
//  Created by Billy Newman on 3/4/14.
//  Copyright (c) 2014 National Geospatial-Intelligence Agency. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "LocalAuthentication.h"

#import "TRVSMonitor.h"

#import <URLMock/URLMock.h>

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
	
	[UMKMockURLProtocol enable];
	[UMKMockURLProtocol setVerificationEnabled:YES];
	[UMKMockURLProtocol reset];
	
	loginMonitor = [TRVSMonitor monitor];
	
	authentication = [Authentication authenticationWithType:LOCAL url:[NSURL URLWithString:@"https://***REMOVED***"]];
	authentication.delegate = self;
}

- (void)tearDown {
	// Put teardown code here. This method is called after the invocation of each test method in the class.
	[UMKMockURLProtocol setVerificationEnabled:NO];
	[UMKMockURLProtocol disable];
	
	[super tearDown];
}


- (void)testLoginSuccess {
	
	NSLog(@"Running login test");
	
	NSString *uid = @"123"; //[[[UIDevice currentDevice] identifierForVendor] UUIDString];
	
	
	NSURL *URL = [NSURL URLWithString:@"https://***REMOVED***/api/login"];
	id requestJSON = @{
		 @"username": @"test",
		 @"password": @"12345",
		 @"uid": uid
	};
	id responseJSON = @{
		@"token": @"12345",
		@"user" : @{ @"username" : @"test",
								 @"firstname" : @"Test",
								 @"lastname" : @"Test",
								 @"email" : @"test@test.com",
								 @"phones": @[@"333-111-4444", @"444-555-6767"]}
	};
	
	[UMKMockURLProtocol expectMockHTTPPostRequestWithURL:URL requestJSON:requestJSON responseStatusCode:200 responseJSON:responseJSON];
	
	
	NSDictionary *parameters =[[NSDictionary alloc] initWithObjectsAndKeys: @"test", @"username", @"12345", @"password", uid, @"uid", nil];
	
	
	[authentication loginWithParameters:parameters];

	[loginMonitor waitWithTimeout:5];
	
	XCTAssertNotNil(user, @"'user' object is nil, login was unsuccessful");
	XCTAssertEqualObjects(user.username, @"test", @"username was not set correctly");
	XCTAssertEqualObjects(user.firstName, @"Test", @"firstname was not set correctly");
	XCTAssertEqualObjects(user.lastName, @"Test", @"lastname was not set correctly");
	XCTAssertEqualObjects(user.email, @"test@test.com", @"email was not set correctly");
	XCTAssertEqualObjects(user.phoneNumbers, ([[NSArray alloc] initWithObjects:@"333-111-4444", @"444-555-6767", nil]), @"phone numbers not set correctly");
}

- (void) authenticationWasSuccessful:(User *)token {
	user = token;
	
	[loginMonitor signal];
}
- (void) authenticationHadFailure {
	[loginMonitor signal];
	
}

@end

