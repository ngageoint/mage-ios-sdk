//
//  LoginInfo.m
//  mage-sdk
//
//  Created by Billy Newman on 2/24/14.
//

#import "User.h"

@implementation User

- (id) initWithJSON: (NSDictionary *) json {
	if (self = [super init]) {
		_token = [json objectForKey:@"token"];
		
		NSDictionary *user = [json objectForKey:@"user"];
		
		_username = [user objectForKey:@"username"];
		_firstName = [user objectForKey:@"firstname"];
		_lastName = [user objectForKey:@"lastname"];
		_email = [user objectForKey:@"email"];
		NSArray *a = [user objectForKey:@"phones"];
		_phoneNumbers = a;
	}
	
	return self;
}


@end
