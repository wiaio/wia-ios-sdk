//
//  WiaEvent.m
//  Pods
//
//  Created by Conall Laverty on 19/10/2015.
//
//

#import "WiaEvent.h"

@implementation WiaEvent

@synthesize id, device, deviceKey, name, eventData, timestamp;

- (instancetype)initWithDictionary:(NSDictionary *)dict {
    self = [super init];
    if (self) {
        self.id = [dict objectForKey:@"id"];
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
        [copy setId:self.id];
        [copy setName:self.name];
        [copy setEventData:self.eventData];
        [copy setTimestamp:self.timestamp];
    }
    
    return copy;
}

@end
