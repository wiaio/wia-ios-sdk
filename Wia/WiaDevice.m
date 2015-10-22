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

@synthesize deviceKey, name, isOnline, createdAt, updatedAt, events;

- (instancetype)initWithDictionary:(NSDictionary *)dict {
    self = [super init];
    if (self) {
        self.deviceKey = [dict objectForKey:@"deviceKey"];
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
        if ([dict objectForKey:@"events"]) {
            self.events = [[NSArray alloc] init];
            
            NSMutableArray *eventsArray = [[NSMutableArray alloc] init];
            NSDictionary *eventsDict = [dict objectForKey:@"events"];
            NSArray *arrayKeys = [eventsDict allKeys];
            
            for (NSString *k in arrayKeys) {
                NSMutableDictionary *eventObj = [[eventsDict objectForKey:k] mutableCopy];
                WiaEvent *e = [[WiaEvent alloc] init];
                e.name = k;
                
                NSTimeInterval seconds = [[eventObj objectForKey:@"timestamp"] doubleValue] / 1000;
                e.timestamp =  [NSDate dateWithTimeIntervalSince1970:seconds];
                
                [eventObj removeObjectForKey:@"timestamp"];
                
                e.eventData = eventObj;
                
                [eventsArray addObject:e];
            }
            self.events = [eventsArray copy];
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
        [copy setIsOnline:self.isOnline];
        [copy setCreatedAt:self.createdAt];
        [copy setUpdatedAt:self.updatedAt];
        [copy setEvents:self.events];
    }
    
    return copy;
}

@end

