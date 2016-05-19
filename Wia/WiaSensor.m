//
//  WiaSensor.m
//  Pods
//
//  Created by Conall Laverty on 19/05/2016.
//
//

#import "WiaSensor.h"

@implementation WiaSensor

@synthesize id, device, name, data, timestamp;

- (instancetype)initWithDictionary:(NSDictionary *)dict {
    self = [super init];
    if (self) {
        self.id = [dict objectForKey:@"id"];
        self.device = [dict objectForKey:@"device"];
        self.name = [dict objectForKey:@"name"];
        self.data = [dict objectForKey:@"data"];
        if ([dict objectForKey:@"timestamp"]) {
            NSTimeInterval seconds = [[dict objectForKey:@"timestamp"] doubleValue] / 1000;
            self.timestamp =  [NSDate dateWithTimeIntervalSince1970:seconds];
        }
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone
{
    WiaSensor *copy = [[[self class] alloc] init];
    
    if (copy) {
        [copy setId:self.id];
        [copy setDevice:self.device];
        [copy setName:self.name];
        [copy setData:self.data];
        [copy setTimestamp:self.timestamp];
    }
    
    return copy;
}


@end
