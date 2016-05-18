//
//  WiaLocation.m
//  Pods
//
//  Created by Conall Laverty on 18/05/2016.
//
//

#import "WiaLocation.h"

@implementation WiaLocation

@synthesize id, device, latitude, longitude, altitude, timestamp;

- (instancetype)initWithDictionary:(NSDictionary *)dict {
    self = [super init];
    if (self) {
        self.id = [dict objectForKey:@"id"];
        self.device = [dict objectForKey:@"device"];
        self.latitude = [dict objectForKey:@"latitude"];
        self.longitude = [dict objectForKey:@"longitude"];
        self.altitude = [dict objectForKey:@"altitude"];
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
        [copy setDevice:self.device];
        [copy setLatitude:self.latitude];
        [copy setLongitude:self.longitude];
        [copy setAltitude:self.altitude];
        [copy setTimestamp:self.timestamp];
    }
    
    return copy;
}

@end
