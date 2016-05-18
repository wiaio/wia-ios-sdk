//
//  WiaDeviceApiKeys.m
//  Pods
//
//  Created by Conall Laverty on 18/05/2016.
//
//

#import "WiaDeviceApiKeys.h"

@implementation WiaDeviceApiKeys

@synthesize publicKey, secretKey;

- (instancetype)initWithDictionary:(NSDictionary *)dict {
    self = [super init];
    if (self) {
        self.publicKey = [dict objectForKey:@"publicKey"];
        self.secretKey = [dict objectForKey:@"secretKey"];
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone
{
    id copy = [[[self class] alloc] init];
    
    if (copy) {
        [copy setPublicKey:self.publicKey];
        [copy setSecretKey:self.secretKey];
    }
    
    return copy;
}


@end
