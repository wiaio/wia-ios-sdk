//
//  WiaFunction.m
//  Pods
//
//  Created by Conall Laverty on 18/05/2016.
//
//

#import "WiaFunction.h"

@implementation WiaFunction

@synthesize id, name, device, createdAt, updatedAt;

- (instancetype)initWithDictionary:(NSDictionary *)dict {
    self = [super init];
    if (self) {
        self.id = [dict objectForKey:@"id"];
        self.device = [dict objectForKey:@"device"];
        self.name = [dict objectForKey:@"name"];
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

- (id)copyWithZone:(NSZone *)zone
{
    id copy = [[[self class] alloc] init];
    
    if (copy) {
        [copy setId:self.id];
        [copy setDevice:self.device];
        [copy setName:self.name];
        [copy setCreatedAt:self.createdAt];
        [copy setUpdatedAt:self.updatedAt];
    }
    
    return copy;
}

@end
