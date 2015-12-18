//
//  WiaClient.m
//  Wia
//
//  Created by Conall Laverty on 22/09/2015.
//
//

#import "WiaClient.h"
#import "AFNetworking.h"
#import "WiaUtils.h"

static NSString *const restApiProtocol = @"https";
static NSString *const restApiURLBase = @"api.wia.io";
static NSString *const restApiVersion = @"v1";

static NSString *const mqttApiProtocol = @"mqtts";
static NSString *const mqttApiHost = @"api.wia.io";

@implementation WiaClient

@synthesize delegate, clientToken, restApiURL, mqttApiURL, mqttSession;

+(instancetype)sharedInstance
{
    static WiaClient *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[WiaClient alloc] init];
        // Do any other initialisation stuff here
    });
    return sharedInstance;
}

+(void)debug:(BOOL)showDebugLogs {
    WiaSetShowDebugLogs(showDebugLogs);
}

- (instancetype)initWithToken:(NSString *)token {
    self = [super init];
    if (self) {
        self.clientToken = token;
    }
    return self;
}

// Stream
-(void)connectToStream {
    if (!self.mqttSession) {
        self.mqttSession = [[MQTTSession alloc] init];
    }
    
    [self.mqttSession setDelegate:self];
    [self.mqttSession setUserName:self.clientToken];
    [self.mqttSession setPassword:@" "];
    [self.mqttSession connectAndWaitToHost:mqttApiHost port:8883  usingSSL:YES];
}

-(void)disconnectFromStream {
    if (self.mqttSession) {
        [self.mqttSession close];
    }
}

// Events
-(void)subscribeToEvents:(nonnull NSDictionary *)params {
    if ([params objectForKey:@"deviceKey"]) {
        if ([params objectForKey:@"name"]) {
            [self.mqttSession subscribeToTopic:[NSString stringWithFormat:@"devices/%@/events/%@", [params objectForKey:@"deviceKey"], [params objectForKey:@"name"]] atLevel:MQTTQosLevelAtLeastOnce];
        } else {
            [self.mqttSession subscribeToTopic:[NSString stringWithFormat:@"devices/%@/events/+", [params objectForKey:@"deviceKey"]] atLevel:MQTTQosLevelAtLeastOnce];
        }
    }
}


-(void)unsubscribeFromEvents:(nonnull NSDictionary *)params {
    if ([params objectForKey:@"deviceKey"]) {
        if ([params objectForKey:@"name"]) {
            [self.mqttSession unsubscribeTopic:[NSString stringWithFormat:@"devices/%@/events/%@", [params objectForKey:@"deviceKey"], [params objectForKey:@"name"]]];
        } else {
            [self.mqttSession unsubscribeTopic:[NSString stringWithFormat:@"devices/%@/events/+", [params objectForKey:@"deviceKey"]]];
        }
    }
}

// Events
-(void)subscribeToLogs:(nonnull NSDictionary *)params {
    if ([params objectForKey:@"deviceKey"]) {
        if ([params objectForKey:@"level"]) {
            [self.mqttSession subscribeToTopic:[NSString stringWithFormat:@"devices/%@/logs/%@", [params objectForKey:@"deviceKey"], [params objectForKey:@"level"]] atLevel:MQTTQosLevelAtLeastOnce];
        } else {
            [self.mqttSession subscribeToTopic:[NSString stringWithFormat:@"devices/%@/logs/+", [params objectForKey:@"deviceKey"]] atLevel:MQTTQosLevelAtLeastOnce];
        }
    }
}


-(void)unsubscribeFromLogs:(nonnull NSDictionary *)params {
    if ([params objectForKey:@"deviceKey"]) {
        if ([params objectForKey:@"level"]) {
            [self.mqttSession unsubscribeTopic:[NSString stringWithFormat:@"devices/%@/logs/%@", [params objectForKey:@"deviceKey"], [params objectForKey:@"level"]]];
        } else {
            [self.mqttSession unsubscribeTopic:[NSString stringWithFormat:@"devices/%@/logs/+", [params objectForKey:@"deviceKey"]]];
        }
    }
}

// Devices
-(void)createDevice:(NSDictionary *)device success:(void (^)(WiaDevice *device))success
            failure:(void (^)(NSError *error))failure {
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@", self.clientToken] forHTTPHeaderField:@"Authorization"];
    
    [manager POST:[NSString stringWithFormat:@"%@/devices", [self getRestApiEndpoint]] parameters:device success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (success) {
            success([[WiaDevice alloc] initWithDictionary:responseObject]);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        if (failure) {
            failure(error);
        }
    }];
}

-(void)retrieveDevice:(NSString *)deviceKey success:(void (^)(WiaDevice *))success failure:(void (^)(NSError *))failure {
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@", self.clientToken] forHTTPHeaderField:@"Authorization"];
    
    [manager GET:[NSString stringWithFormat:@"%@/devices/%@", [self getRestApiEndpoint], deviceKey] parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (success) {
            success([[WiaDevice alloc] initWithDictionary:responseObject]);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        if (failure) {
            failure(error);
        }
    }];
}

-(void)updateDevice:(NSString *)deviceKey fields:(NSDictionary *)fields success:(void (^)(WiaDevice *))success failure:(void (^)(NSError *))failure {
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@", self.clientToken] forHTTPHeaderField:@"Authorization"];
    
    [manager PUT:[NSString stringWithFormat:@"%@/devices/%@", [self getRestApiEndpoint], deviceKey] parameters:fields success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (success) {
            success([[WiaDevice alloc] initWithDictionary:responseObject]);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        if (failure) {
            failure(error);
        }
    }];
}

-(void)deleteDevice:(NSString *)deviceKey success:(void (^)(WiaDevice *))success failure:(void (^)(NSError *))failure {
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@", self.clientToken] forHTTPHeaderField:@"Authorization"];
    
    [manager DELETE:[NSString stringWithFormat:@"%@/devices/%@", [self getRestApiEndpoint], deviceKey] parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (success) {
            success([[WiaDevice alloc] initWithDictionary:responseObject]);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        if (failure) {
            failure(error);
        }
    }];
}

-(void)listDevices:(NSDictionary *)params success:(void (^)(NSArray *devices))success
           failure:(void (^)(NSError *error))failure {
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@", self.clientToken] forHTTPHeaderField:@"Authorization"];
    
    [manager GET:[NSString stringWithFormat:@"%@/devices", [self getRestApiEndpoint]] parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (success) {
            NSMutableArray *devices = [[NSMutableArray alloc] init];
            for (id device in [responseObject objectForKey:@"devices"]) {
                WiaDevice *d = [[WiaDevice alloc] initWithDictionary:device];
                [devices addObject:d];
            }
            success(devices);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        if (failure) {
            failure(error);
        }
    }];
}


-(void)getUserMe:(void (^)(WiaUser *user))success
         failure:(void (^)(NSError *error))failure {
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@", self.clientToken] forHTTPHeaderField:@"Authorization"];
    
    [manager GET:[NSString stringWithFormat:@"%@/users/me", [self getRestApiEndpoint]] parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (success) {
            success([[WiaUser alloc] initWithDictionary:responseObject]);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        if (failure) {
            failure(error);
        }
    }];
}

// Helpers
-(NSString *)getRestApiEndpoint {
    return [NSString stringWithFormat:@"%@://%@/%@", restApiProtocol, restApiURLBase, restApiVersion];
}

// MQTTSessionDelegate
- (void)connected:(MQTTSession *)session {
    WiaLogger(@"Connected to stream.");
    if (self.delegate && [self.delegate respondsToSelector:@selector(connectedToStream)]) {
        [self.delegate connectedToStream];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:@"WiaStreamConnected" object:nil];
}

- (void)connectionRefused:(MQTTSession *)session error:(NSError *)error {
    WiaLogger(@"Connection refused.");
    if (self.delegate && [self.delegate respondsToSelector:@selector(disconnectedFromStream:)]) {
        [self.delegate disconnectedFromStream:error];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:@"WiaStreamConnectionRefused" object:nil];
}

- (void)connectionClosed:(MQTTSession *)session {
    WiaLogger(@"Connection closed.");
    if (self.delegate && [self.delegate respondsToSelector:@selector(disconnectedFromStream:)]) {
        [self.delegate disconnectedFromStream:nil];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:@"WiaStreamConnectionClose" object:nil];
}

- (void)connectionError:(MQTTSession *)session error:(NSError *)error {
    WiaLogger(@"Connection error.");
    if (self.delegate && [self.delegate respondsToSelector:@selector(disconnectedFromStream:)]) {
        [self.delegate disconnectedFromStream:nil];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:@"WiaStreamConnectionError" object:nil];
}

- (void)protocolError:(MQTTSession *)session error:(NSError *)error {
    WiaLogger(@"Protocol error.");
    if (self.delegate && [self.delegate respondsToSelector:@selector(disconnectedFromStream:)]) {
        [self.delegate disconnectedFromStream:nil];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:@"WiaStreamProtocolError" object:nil];
}

- (void)newMessage:(MQTTSession *)session data:(NSData *)data onTopic:(NSString *)topic qos:(MQTTQosLevel)qos retained:(BOOL)retained mid:(unsigned int)mid {
    WiaLogger(@"New message received. topic - %@, data - %@", topic, data);
    
    NSRange searchedRange = NSMakeRange(0, [topic length]);
    NSError *error = nil;
    
    NSRegularExpression* regex = [NSRegularExpression regularExpressionWithPattern:@"devices/(.*?)/events/(.*)" options:0 error:&error];
    NSTextCheckingResult *match = [regex firstMatchInString:topic options:0 range: searchedRange];
    
    if (match) {
        WiaLogger(@"WiaNewEvent");
        NSString *deviceKey = [topic substringWithRange:[match rangeAtIndex:1]];
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(newEvent:)]) {
            WiaEvent *event = [[WiaEvent alloc] initWithDictionary:[NSJSONSerialization JSONObjectWithData:data options:0 error:nil]];
            event.deviceKey = deviceKey;
            [self.delegate newEvent:event];
        }
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"WiaNewEvent" object:self
                                                          userInfo:[NSJSONSerialization JSONObjectWithData:data
                                                                                                   options:NSJSONReadingMutableContainers error:&error]];
        return;
    }
 
    regex = [NSRegularExpression regularExpressionWithPattern:@"devices/(.*?)/logs/(.*)" options:0 error:&error];
    match = [regex firstMatchInString:topic options:0 range: searchedRange];

    if (match) {
        WiaLogger(@"WiaNewLog");
        NSString *deviceKey = [topic substringWithRange:[match rangeAtIndex:1]];
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(newLog:)]) {
            WiaLog *log = [[WiaLog alloc] initWithDictionary:[NSJSONSerialization JSONObjectWithData:data options:0 error:nil]];
            log.deviceKey = deviceKey;
            [self.delegate newLog:log];
        }
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"WiaNewLog" object:self
                                                          userInfo:[NSJSONSerialization JSONObjectWithData:data
                                                                                                   options:NSJSONReadingMutableContainers error:&error]];
        return;
    }
}

- (void)handleEvent:(MQTTSession *)session event:(MQTTSessionEvent)eventCode error:(NSError *)error {
    WiaLogger(@"handleEvent. eventCode: %d\terror: %@\t", eventCode, error);
}

- (void)session:(MQTTSession*)session handleEvent:(MQTTSessionEvent)eventCode {
    WiaLogger(@"handleEvent. eventCode: %d", eventCode);
}

- (void)messageDelivered:(MQTTSession *)session msgID:(UInt16)msgID {
    WiaLogger(@"messageDelivered.");
}

- (void)subAckReceived:(MQTTSession *)session msgID:(UInt16)msgID grantedQoss:(NSArray<NSNumber *> *)qoss {
    WiaLogger(@"subAckReceived.");
}

- (void)unsubAckReceived:(MQTTSession *)session msgID:(UInt16)msgID {
    WiaLogger(@"unsubAckReceived.");
}

- (void)sending:(MQTTSession *)session type:(int)type qos:(MQTTQosLevel)qos retained:(BOOL)retained duped:(BOOL)duped mid:(UInt16)mid data:(NSData *)data {
    WiaLogger(@"sending.");
}

- (void)received:(MQTTSession *)session type:(int)type qos:(MQTTQosLevel)qos retained:(BOOL)retained duped:(BOOL)duped mid:(UInt16)mid data:(NSData *)data {
    WiaLogger(@"received.");
}

@end