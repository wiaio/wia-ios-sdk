//
//  WiaDevice.m
//  Wia
//
//  Created by Conall Laverty on 22/09/2015.
//
//

#import "WiaDevice.h"
#import "WiaEvent.h"
#import "WiaSensor.h"

@implementation WiaDevice

@synthesize id, name, isOnline, createdAt, updatedAt, events, public, sensors, location;

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
        if ([dict objectForKey:@"public"]) {
            self.public = [[dict objectForKey:@"public"] boolValue];
        }
        if ([dict objectForKey:@"events"]) {
            NSMutableDictionary *eventsDict = [[NSMutableDictionary alloc] init];
            for (id key in [dict objectForKey:@"events"]) {
                WiaEvent *event = [[WiaEvent alloc] initWithDictionary:[[dict objectForKey:@"events"] objectForKey:key]];
                [eventsDict setValue:event forKey:key];
            }
            self.events = eventsDict;
        }
        if ([dict objectForKey:@"sensors"]) {
            NSMutableDictionary *sensorsDict = [[NSMutableDictionary alloc] init];
            for (id key in [dict objectForKey:@"sensors"]) {
                WiaSensor *sensor = [[WiaSensor alloc] initWithDictionary:[[dict objectForKey:@"sensors"] objectForKey:key]];
                [sensorsDict setValue:sensor forKey:key];
            }
            self.sensors = sensorsDict;
        }
        if ([dict objectForKey:@"location"]) {
            self.location = [[WiaLocation alloc] initWithDictionary:[dict objectForKey:@"location"]];
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
        [copy setSensors:self.sensors];
        [copy setLocation:self.location];
    }
    
    return copy;
}

@end

