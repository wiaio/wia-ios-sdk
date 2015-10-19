//
//  WiaDevice.m
//  Wia
//
//  Created by Conall Laverty on 22/09/2015.
//
//

#import "WiaDevice.h"

@implementation WiaDevice

@synthesize deviceKey, name, isOnline, createdAt, updatedAt;

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
    }
    return self;
}

@end

