//
//  WiaCustomer.m
//  Wia
//
//  Created by Conall Laverty on 22/09/2015.
//
//

#import "WiaCustomer.h"

@implementation WiaCustomer

@synthesize id, username, email, fullName, avatar, createdAt, updatedAt;

- (instancetype)initWithDictionary:(NSDictionary *)dict {
    self = [super init];
    if (self) {
        self.id = [dict objectForKey:@"id"];
        self.username = [dict objectForKey:@"username"];
        self.email = [dict objectForKey:@"email"];
        self.fullName = [dict objectForKey:@"fullName"];
        self.avatar = [dict objectForKey:@"avatar"];
        if ([dict objectForKey:@"createdAt"]) {
            NSTimeInterval seconds = [[dict objectForKey:@"createdAt"] doubleValue] / 1000;
            self.createdAt =  [NSDate dateWithTimeIntervalSince1970:seconds];
        }
        if ([dict objectForKey:@"updatedAt"]) {
            NSTimeInterval seconds = [[dict objectForKey:@"updatedAt"] doubleValue] / 1000;
            self.updatedAt =  [NSDate dateWithTimeIntervalSince1970:seconds];
        }
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone
{
    id copy = [[[self class] alloc] init];
    
    if (copy) {
        [copy setId:self.id];
        [copy setUsername:self.username];
        [copy setEmail:self.email];
        [copy setFullName:self.fullName];
        [copy setAvatar:self.avatar];
        [copy setCreatedAt:self.createdAt];
        [copy setUpdatedAt:self.updatedAt];
    }
    
    return copy;
}

@end

