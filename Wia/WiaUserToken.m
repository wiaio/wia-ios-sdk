//
//  WiaUserToken.m
//  Pods
//
//  Created by Conall Laverty on 21/10/2015.
//
//

#import "WiaUserToken.h"

@implementation WiaUserToken

@synthesize accessToken, tokenType;

- (instancetype)initWithDictionary:(NSDictionary *)dict {
    self = [super init];
    if (self) {
        self.accessToken = [dict objectForKey:@"accessToken"];
        self.tokenType = [dict objectForKey:@"tokenType"];
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone
{
    id copy = [[[self class] alloc] init];
    
    if (copy) {
        [copy setAccessToken:self.accessToken];
        [copy setTokenType:self.tokenType];
    }
    
    return copy;
}

@end
