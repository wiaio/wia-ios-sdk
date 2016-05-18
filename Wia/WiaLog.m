//
//  WiaLog.m
//  Pods
//
//  Created by Conall Laverty on 17/05/2016.
//
//

#import "WiaLog.h"

@implementation WiaLog

- (instancetype)initWithDictionary:(NSDictionary *)dict {
    self = [super init];
    if (self) {
        self.id = [dict objectForKey:@"id"];
        self.device = [dict objectForKey:@"device"];
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
        [copy setId:self.id];
        [copy setDevice:self.device];
        [copy setLevel:self.level];
        [copy setMessage:self.message];
        [copy setLogData:self.logData];
        [copy setTimestamp:self.timestamp];
    }
    
    return copy;
}

@end

