//
//  WiaFunction.m
//  Pods
//
//  Created by Conall Laverty on 19/10/2015.
//
//

#import "WiaFunction.h"

@implementation WiaFunction

@synthesize deviceKey, name, isEnabled, enabledAt, createdAt, updatedAt, data;

- (instancetype)initWithDictionary:(NSDictionary *)dict {
    self = [super init];
    if (self) {
        self.deviceKey = [dict objectForKey:@"deviceKey"];
        self.name = [dict objectForKey:@"name"];
        if ([dict objectForKey:@"isEnabled"]) {
            self.isEnabled = [[dict objectForKey:@"isEnabled"] boolValue];
        }
        if ([dict objectForKey:@"enabledAt"]) {
            NSTimeInterval seconds = [[dict objectForKey:@"enabledAt"] doubleValue] / 1000;
            self.enabledAt =  [NSDate dateWithTimeIntervalSince1970:seconds];
        }
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
        [copy setDeviceKey:self.deviceKey];
        [copy setName:self.name];
        [copy setIsEnabled:self.isEnabled];
        [copy setEnabledAt:self.enabledAt];
        [copy setCreatedAt:self.createdAt];
        [copy setUpdatedAt:self.updatedAt];
    }
    
    return copy;
}

@end
