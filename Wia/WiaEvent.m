//
//  WiaEvent.m
//  Pods
//
//  Created by Conall Laverty on 19/10/2015.
//
//

#import "WiaEvent.h"

@implementation WiaEvent

@synthesize device, eventId, deviceKey, name, eventData, timestamp;

- (instancetype)initWithDictionary:(NSDictionary *)dict {
    self = [super init];
    if (self) {
        if ([dict objectForKey:@"device"]) {
            self.device = [[WiaDevice alloc] initWithDictionary:[dict objectForKey:@"device"]];
        }
        self.eventId = [dict objectForKey:@"eventId"];
        self.deviceKey = [dict objectForKey:@"deviceKey"];
        self.name = [dict objectForKey:@"name"];
        self.eventData = [dict objectForKey:@"data"];
        if ([dict objectForKey:@"timestamp"]) {
            NSTimeInterval seconds = [[dict objectForKey:@"timestamp"] doubleValue] / 1000;
            self.timestamp =  [NSDate dateWithTimeIntervalSince1970:seconds];
        }
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone
{
    id copy = [[[self class] alloc] init];
    
    if (copy) {
        [copy setDevice:self.device];
        [copy setEventId:self.eventId];
        [copy setDeviceKey:self.deviceKey];
        [copy setName:self.name];
        [copy setEventData:self.eventData];
        [copy setTimestamp:self.timestamp];
    }
    
    return copy;
}

@end
