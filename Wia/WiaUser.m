//
//  WiaUser.m
//  Wia
//
//  Created by Conall Laverty on 22/09/2015.
//
//

#import "WiaUser.h"

@implementation WiaUser

@synthesize id, username, fullName, firstName, lastName, createdAt, updatedAt;

- (instancetype)initWithDictionary:(NSDictionary *)dict {
    self = [super init];
    if (self) {
        self.id = [dict objectForKey:@"id"];
        self.username = [dict objectForKey:@"username"];
        self.fullName = [dict objectForKey:@"fullName"];
        self.firstName = [dict objectForKey:@"firstName"];
        self.lastName = [dict objectForKey:@"lastName"];
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
        [copy setFullName:self.fullName];
        [copy setFirstName:self.firstName];
        [copy setLastName:self.lastName];
        [copy setCreatedAt:self.createdAt];
        [copy setUpdatedAt:self.updatedAt];
    }
    
    return copy;
}

@end
