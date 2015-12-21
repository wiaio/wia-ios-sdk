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

@synthesize delegate, clientToken, restApiURL, mqttApiURL, mqttSession, clientInfo;

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

- (instancetype)init {
    return [self initWithToken:self.clientToken];
}

- (instancetype)initWithToken:(NSString *)token {
    self = [super init];
    if (self) {
        self.clientToken = token;
        [self getWiaClientInfo];
    }
    return self;
}

-(void)getWiaClientInfo {
    if (self.clientToken) {
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        manager.responseSerializer = [AFJSONResponseSerializer serializer];
        manager.requestSerializer = [AFJSONRequestSerializer serializer];
        [manager.requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@", self.clientToken] forHTTPHeaderField:@"Authorization"];
        
        [manager GET:[NSString stringWithFormat:@"%@/whoami", [self getRestApiEndpoint]] parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
            WiaLogger(@"whoami - %@", responseObject);
            self.clientInfo = responseObject;
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            WiaLogger(@"Error: %@", error);
        }];
    }
}

// Access token
-(void)generateAccessToken:(NSDictionary *)tokenRequest success:(void (^)(WiaAccessToken *accessToken))success
            failure:(void (^)(NSError *error))failure {
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    
    [manager POST:[NSString stringWithFormat:@"%@/auth/token", [self getRestApiEndpoint]] parameters:tokenRequest success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (success) {
            success([[WiaAccessToken alloc] initWithDictionary:responseObject]);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        WiaLogger(@"Error: %@", error);
        if (failure) {
            failure(error);
        }
    }];
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
        WiaLogger(@"Error: %@", error);
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
        WiaLogger(@"Error: %@", error);
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
        WiaLogger(@"Error: %@", error);
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
        WiaLogger(@"Error: %@", error);
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
        WiaLogger(@"Error: %@", error);
        if (failure) {
            failure(error);
        }
    }];
}

// Events
-(void)publishEvent:(nonnull NSDictionary *)event success:(nullable void (^)(WiaEvent * _Nullable event))success
            failure:(nullable void (^)(NSError * _Nullable error))failure {
    WiaLogger(@"Publishing event - %@", event);

    if (self.mqttSession && self.mqttSession.status == MQTTSessionStatusConnected && self.clientInfo) {
        WiaLogger(@"Publishing event on stream.");
        NSDictionary *device = [self.clientInfo objectForKey:@"device"];
        if (!device) {
            WiaLogger(@"Cannot send event. Not a device.");
            return;
        }
        NSString *deviceKey = [device objectForKey:@"deviceKey"];
        if (!deviceKey) {
            WiaLogger(@"Cannot send event. deviceKey not in client info.");
            return;
        }
        WiaLogger(@"Sending event on stream with topic %@", [NSString stringWithFormat:@"devices/%@/events/%@", deviceKey, [event objectForKey:@"name"]]);
        [self.mqttSession publishData:[NSKeyedArchiver archivedDataWithRootObject:event] onTopic:[NSString stringWithFormat:@"devices/%@/events/%@", deviceKey, [event objectForKey:@"name"]] retain:YES qos:MQTTQosLevelAtLeastOnce];
    } else {
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        manager.responseSerializer = [AFJSONResponseSerializer serializer];
        manager.requestSerializer = [AFJSONRequestSerializer serializer];
        [manager.requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@", self.clientToken] forHTTPHeaderField:@"Authorization"];
        
        [manager POST:[NSString stringWithFormat:@"%@/events", [self getRestApiEndpoint]] parameters:event success:^(AFHTTPRequestOperation *operation, id responseObject) {
            if (success) {
                success([[WiaEvent alloc] initWithDictionary:responseObject]);
            }
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            WiaLogger(@"Error: %@", error);
            if (failure) {
                failure(error);
            }
        }];
    }
}

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

// Logs
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

-(void)listLogs:(NSDictionary *)params success:(void (^)(NSArray *logs))success
          failure:(void (^)(NSError *error))failure {
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@", self.clientToken] forHTTPHeaderField:@"Authorization"];
    [manager GET:[NSString stringWithFormat:@"%@/logs", [self getRestApiEndpoint]] parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (success) {
            WiaLogger(responseObject);
            NSMutableArray *logs = [[NSMutableArray alloc] init];
            for (id log in [responseObject objectForKey:@"logs"]) {
                WiaLog *l = [[WiaLog alloc] initWithDictionary:log];
                [logs addObject:l];
            }
            success(logs);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        WiaLogger(@"Error: %@", error);
        if (failure) {
            failure(error);
        }
    }];
}

-(void)listFunctions:(NSDictionary *)params success:(void (^)(NSArray *functions))success
           failure:(void (^)(NSError *error))failure {
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@", self.clientToken] forHTTPHeaderField:@"Authorization"];
    
    [manager GET:[NSString stringWithFormat:@"%@/functions", [self getRestApiEndpoint]] parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (success) {
            NSMutableArray *functions = [[NSMutableArray alloc] init];
            for (id func in [responseObject objectForKey:@"functions"]) {
                WiaFunction *f = [[WiaFunction alloc] initWithDictionary:func];
                [functions addObject:f];
            }
            success(functions);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        WiaLogger(@"Error: %@", error);
        if (failure) {
            failure(error);
        }
    }];
}

-(void)callFunction:(nullable NSDictionary *)params {
    if (!params)
        return;
    if (self.mqttSession && self.mqttSession.status == MQTTSessionStatusConnected) {
        WiaLogger(@"Calling function over stream.");
        NSString *topic = [NSString stringWithFormat:@"devices/%@/functions/%@/call", [params objectForKey:@"deviceKey"], [params objectForKey:@"name"]];
        WiaLogger([NSString stringWithFormat:@"Publishing to topic %@", topic]);
        WiaLogger(@"%@", params);
        [self.mqttSession publishData:[NSKeyedArchiver archivedDataWithRootObject:params] onTopic:topic retain:NO qos:MQTTQosLevelAtLeastOnce];
    } else {
        WiaLogger(@"Calling function over REST.");
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        manager.responseSerializer = [AFJSONResponseSerializer serializer];
        manager.requestSerializer = [AFJSONRequestSerializer serializer];
        [manager.requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@", self.clientToken] forHTTPHeaderField:@"Authorization"];
        
        [manager POST:[NSString stringWithFormat:@"%@/functions/call", [self getRestApiEndpoint]] parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
            WiaLogger(@"Success");
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            WiaLogger(@"Error: %@", error);
        }];
    }
}

// Users
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
        WiaLogger(@"Error: %@", error);
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
    self.clientInfo = nil;
    if (self.delegate && [self.delegate respondsToSelector:@selector(disconnectedFromStream:)]) {
        [self.delegate disconnectedFromStream:error];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:@"WiaStreamConnectionRefused" object:nil];
}

- (void)connectionClosed:(MQTTSession *)session {
    WiaLogger(@"Connection closed.");
    self.clientInfo = nil;
    if (self.delegate && [self.delegate respondsToSelector:@selector(disconnectedFromStream:)]) {
        [self.delegate disconnectedFromStream:nil];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:@"WiaStreamConnectionClose" object:nil];
}

- (void)connectionError:(MQTTSession *)session error:(NSError *)error {
    WiaLogger(@"Connection error.");
    self.clientInfo = nil;
    if (self.delegate && [self.delegate respondsToSelector:@selector(disconnectedFromStream:)]) {
        [self.delegate disconnectedFromStream:nil];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:@"WiaStreamConnectionError" object:nil];
}

- (void)protocolError:(MQTTSession *)session error:(NSError *)error {
    WiaLogger(@"Protocol error.");
    self.clientInfo = nil;
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