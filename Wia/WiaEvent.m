//
//  WiaEvent.m
//  Pods
//
//  Created by Conall Laverty on 19/10/2015.
//
//

#import "WiaEvent.h"

@implementation WiaEvent

@synthesize device, name, data, timestamp;

- (instancetype)initWithDictionary:(NSDictionary *)dict {
    self = [super init];
    if (self) {
        if ([dict objectForKey:@"device"]) {
            self.device = [[WiaDevice alloc] initWithDictionary:[dict objectForKey:@"device"]];
        }
        self.name = [dict objectForKey:@"name"];
        self.data = [dict objectForKey:@"data"];
        if ([dict objectForKey:@"timestamp"]) {
            NSTimeInterval seconds = [[dict objectForKey:@"timestamp"] doubleValue] / 1000;
            self.timestamp =  [NSDate dateWithTimeIntervalSince1970:seconds];
        }
    }
    return self;
}

@end
