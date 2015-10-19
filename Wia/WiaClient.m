//
//  WiaClient.m
//  Wia
//
//  Created by Conall Laverty on 22/09/2015.
//
//

#import "WiaClient.h"
#import "AFNetworking.h"

static NSString *const restApiURLBase = @"api.wia.io";
static NSString *const restApiVersion = @"v1";
static NSString *const mqttApiURLBase = @"api.wia.io";
static NSString *const mqttAPIPort = @"1883";
static NSString *const mqttAPIPortSecure = @"8883";

@implementation WiaClient

@synthesize clientToken, restApiURL, mqttApiURL;

- (instancetype)init {
    return [self initWithToken:self.clientToken];
}

- (instancetype)initWithToken:(NSString *)token {
    self = [super init];
    if (self) {
        self.clientToken = token;
        self.restApiURL = [[NSURL URLWithString:[NSString stringWithFormat:@"https://%@", restApiURLBase]] URLByAppendingPathComponent:restApiVersion];
        self.mqttApiURL = [NSURL URLWithString:[NSString stringWithFormat:@"mqtt://%@:%@", mqttApiURLBase, mqttAPIPort]];
    }
    return self;
}

@end