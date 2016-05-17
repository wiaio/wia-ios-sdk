//
//  WiaAccessToken.m
//  Pods
//
//  Created by Conall Laverty on 07/12/2015.
//
//

#import "WiaAccessToken.h"

@implementation WiaAccessToken

@synthesize accessToken, tokenType, expiresIn, refreshToken, scope;

- (instancetype)initWithDictionary:(NSDictionary *)dict {
    self = [super init];
    if (self) {
        self.accessToken = [dict objectForKey:@"accessToken"];
        self.refreshToken = [dict objectForKey:@"refreshToken"];
        self.tokenType = [dict objectForKey:@"tokenType"];
        self.expiresIn = [dict objectForKey:@"expiresIn"];
        self.scope = [dict objectForKey:@"scope"];
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone
{
    id copy = [[[self class] alloc] init];
    
    if (copy) {
        [copy setAccessToken:self.accessToken];
        [copy setRefreshToken:self.refreshToken];
        [copy setTokenType:self.tokenType];
        [copy setExpiresIn:self.expiresIn];
        [copy setScope:self.scope];
    }
    
    return copy;
}

@end
