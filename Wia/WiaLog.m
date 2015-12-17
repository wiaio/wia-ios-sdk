//
//  WiaLog.m
//  Pods
//
//  Created by Conall Laverty on 17/12/2015.
//
//

#import "WiaLog.h"

@implementation WiaLog

@synthesize logId, deviceKey, level, message, logData, timestamp;

- (instancetype)initWithDictionary:(NSDictionary *)dict {
    self = [super init];
    if (self) {
        self.logId = [dict objectForKey:@"logId"];
        self.deviceKey = [dict objectForKey:@"deviceKey"];
        self.level = [dict objectForKey:@"level"];
        self.message = [dict objectForKey:@"message"];
        self.logData = [dict objectForKey:@"data"];
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
        [copy setLogId:self.logId];
        [copy setDeviceKey:self.deviceKey];
        [copy setLevel:self.level];
        [copy setMessage:self.message];
        [copy setLogData:self.logData];
        [copy setTimestamp:self.timestamp];
    }
    
    return copy;
}

@end
