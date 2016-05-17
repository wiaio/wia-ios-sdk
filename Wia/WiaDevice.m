//
//  WiaDevice.m
//  Wia
//
//  Created by Conall Laverty on 22/09/2015.
//
//

#import "WiaDevice.h"
#import "WiaEvent.h"

@implementation WiaDevice

@synthesize id, name, isOnline, createdAt, updatedAt, events;

- (instancetype)initWithDictionary:(NSDictionary *)dict {
    self = [super init];
    if (self) {
        self.id = [dict objectForKey:@"id"];
        self.name = [dict objectForKey:@"name"];
        if ([dict objectForKey:@"isOnline"]) {
            self.isOnline = [[dict objectForKey:@"isOnline"] boolValue];
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
        [copy setId:self.id];
        [copy setName:self.name];
        [copy setIsOnline:self.isOnline];
        [copy setCreatedAt:self.createdAt];
        [copy setUpdatedAt:self.updatedAt];
        [copy setEvents:self.events];
    }
    
    return copy;
}

@end

