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

static NSString *const DEFAULT_REST_API_PROTOCOL = @"https";
static NSString *const DEFAULT_REST_API_HOST = @"api.wia.io";
static NSString *const DEFAULT_REST_API_PORT = @"443";
static NSString *const DEFAULT_REST_API_VERSION = @"v1";

static NSString *const DEFAULT_MQTT_API_PROTOCOL = @"mqtts";
static NSString *const DEFAULT_MQTT_API_HOST = @"api.wia.io";
static NSString *const DEFAULT_MQTT_API_PORT = @"8883";
static BOOL const DEFAULT_MQTT_API_SECURE = true;

@implementation WiaClient

@synthesize delegate, publicKey, secretKey = _secretKey, mqttTransport, mqttSession, clientInfo, restApiProtocol, restApiHost, restApiPort, restApiVersion, mqttApiProtocol, mqttApiHost, mqttApiPort, mqttApiSecure;

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
    self.restApiProtocol = DEFAULT_REST_API_PROTOCOL;
    self.restApiHost = DEFAULT_REST_API_HOST;
    self.restApiPort = DEFAULT_REST_API_PORT;
    self.restApiVersion = DEFAULT_REST_API_VERSION;
    
    self.mqttApiProtocol = DEFAULT_MQTT_API_PROTOCOL;
    self.mqttApiHost = DEFAULT_MQTT_API_HOST;
    self.mqttApiPort = DEFAULT_MQTT_API_PORT;
    self.mqttApiSecure = DEFAULT_MQTT_API_SECURE;
    
    return [self initWithToken:self.secretKey];
}

- (instancetype)initWithToken:(NSString *)secretKey {
    self = [super init];
    if (self) {
        self.secretKey = secretKey;
        [self getWiaClientInfo];
    }
    return self;
}


- (instancetype)initWithApplicationKey:(NSString *)applicationKey {
    self = [super init];
    if (self) {
        self.applicationKey = applicationKey;
    }
    return self;
}

-(void)getWiaClientInfo {
    if (self.secretKey) {
        AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
        manager.responseSerializer = [AFJSONResponseSerializer serializer];
        manager.requestSerializer = [AFJSONRequestSerializer serializer];
        [manager.requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@", self.secretKey] forHTTPHeaderField:@"Authorization"];
        
        [manager GET:[NSString stringWithFormat:@"%@/whoami", [self getRestApiEndpoint]] parameters:nil progress:nil success:^(NSURLSessionTask *operation, id responseObject) {
            WiaLogger(@"whoami - %@", responseObject);
            self.clientInfo = responseObject;
        } failure:^(NSURLSessionTask *operation, NSError *error) {
            WiaLogger(@"Error: %@", error);
        }];
    }
}

-(void)setSecretKey:(NSString *)secretKey {
    if (![_secretKey isEqualToString:secretKey]) {
        _secretKey = secretKey;
        [self getWiaClientInfo];
    }
}

-(void)reset {
    self.restApiProtocol = DEFAULT_REST_API_PROTOCOL;
    self.restApiHost = DEFAULT_REST_API_HOST;
    self.restApiPort = DEFAULT_REST_API_PORT;
    self.restApiVersion = DEFAULT_REST_API_VERSION;
    
    self.mqttApiProtocol = DEFAULT_MQTT_API_PROTOCOL;
    self.mqttApiHost = DEFAULT_MQTT_API_HOST;
    self.mqttApiPort = DEFAULT_MQTT_API_PORT;
    self.mqttApiSecure = DEFAULT_MQTT_API_SECURE;
}

// Access token
-(void)generateAccessToken:(NSDictionary *)params success:(void (^)(WiaAccessToken *accessToken))success
            failure:(void (^)(NSError *error))failure {
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    if (self.applicationKey)
        [manager.requestSerializer setValue:self.applicationKey forHTTPHeaderField:@"x-app-key"];

    [manager POST:[NSString stringWithFormat:@"%@/auth/token", [self getRestApiEndpoint]] parameters:params progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (success) {
            success([[WiaAccessToken alloc] initWithDictionary:responseObject]);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        WiaLogger(@"Error: %@", error);
        if (failure) {
            failure(error);
        }
    }];
}

// Stream
-(void)connectToStream {
    NSNumberFormatter* formatter = [[NSNumberFormatter alloc] init];

    if (!self.mqttTransport) {
        if ([self.mqttApiProtocol isEqualToString:@"mqtt"] || [self.mqttApiProtocol isEqualToString:@"mqtts"]) {
            self.mqttTransport = [[MQTTCFSocketTransport alloc] init];
            ((MQTTCFSocketTransport *)self.mqttTransport).host = self.mqttApiHost;
            ((MQTTCFSocketTransport *)self.mqttTransport).port = [[formatter numberFromString:self.mqttApiPort] unsignedShortValue];
            ((MQTTCFSocketTransport *)self.mqttTransport).tls = self.mqttApiSecure;

        } else if ([self.mqttApiProtocol isEqualToString:@"ws"] || [self.mqttApiProtocol isEqualToString:@"wss"]) {
            self.mqttTransport = [[MQTTWebsocketTransport alloc] init];
            ((MQTTWebsocketTransport *)self.mqttTransport).host = self.mqttApiHost;
            ((MQTTWebsocketTransport *)self.mqttTransport).port = [[formatter numberFromString:self.mqttApiPort] unsignedShortValue];
            ((MQTTWebsocketTransport *)self.mqttTransport).tls = self.mqttApiSecure;
        }
    }
    
    if (!self.mqttSession) {
        self.mqttSession = [[MQTTSession alloc] init];
    }
    
    [self.mqttSession setTransport:self.mqttTransport];
    [self.mqttSession setDelegate:self];
    if (self.secretKey) {
        [self.mqttSession setUserName:self.secretKey];
    } else if (self.applicationKey) {
        [self.mqttSession setUserName:self.applicationKey];
    }
    [self.mqttSession setPassword:@" "];
    [self.mqttSession connectAndWaitTimeout:30];
}

-(void)disconnectFromStream {
    if (self.mqttSession) {
        [self.mqttSession close];
    }
}

// Devices
-(void)createDevice:(NSDictionary *)device success:(void (^)(WiaDevice *device))success
            failure:(void (^)(NSError *error))failure {
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@", self.secretKey] forHTTPHeaderField:@"Authorization"];
    if (self.applicationKey)
        [manager.requestSerializer setValue:self.applicationKey forHTTPHeaderField:@"x-app-key"];

    [manager POST:[NSString stringWithFormat:@"%@/devices", [self getRestApiEndpoint]] parameters:device progress:nil success:^(NSURLSessionTask *operation, id responseObject) {
        if (success) {
            success([[WiaDevice alloc] initWithDictionary:responseObject]);
        }
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        WiaLogger(@"Error: %@", error);
        if (failure) {
            failure(error);
        }
    }];
}

-(void)retrieveDevice:(NSString *)deviceId success:(void (^)(WiaDevice *))success failure:(void (^)(NSError *))failure {
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@", self.secretKey] forHTTPHeaderField:@"Authorization"];
    if (self.applicationKey)
        [manager.requestSerializer setValue:self.applicationKey forHTTPHeaderField:@"x-app-key"];

    [manager GET:[NSString stringWithFormat:@"%@/devices/%@", [self getRestApiEndpoint], deviceId] parameters:nil progress:nil success:^(NSURLSessionTask *operation, id responseObject) {
        if (success) {
            success([[WiaDevice alloc] initWithDictionary:responseObject]);
        }
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        WiaLogger(@"Error: %@", error);
        if (failure) {
            failure(error);
        }
    }];
}

-(void)updateDevice:(NSString *)deviceId fields:(NSDictionary *)fields success:(void (^)(WiaDevice *))success failure:(void (^)(NSError *))failure {
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@", self.secretKey] forHTTPHeaderField:@"Authorization"];
    if (self.applicationKey)
        [manager.requestSerializer setValue:self.applicationKey forHTTPHeaderField:@"x-app-key"];

    [manager PUT:[NSString stringWithFormat:@"%@/devices/%@", [self getRestApiEndpoint], deviceId] parameters:fields success:^(NSURLSessionTask *operation, id responseObject) {
        if (success) {
            success([[WiaDevice alloc] initWithDictionary:responseObject]);
        }
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        WiaLogger(@"Error: %@", error);
        if (failure) {
            failure(error);
        }
    }];
}

-(void)deleteDevice:(NSString *)deviceId success:(void (^)(BOOL))success failure:(void (^)(NSError *))failure {
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@", self.secretKey] forHTTPHeaderField:@"Authorization"];
    if (self.applicationKey)
        [manager.requestSerializer setValue:self.applicationKey forHTTPHeaderField:@"x-app-key"];

    [manager DELETE:[NSString stringWithFormat:@"%@/devices/%@", [self getRestApiEndpoint], deviceId] parameters:nil success:^(NSURLSessionTask *operation, id responseObject) {
        if (success) {
            success(YES);
        }
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        WiaLogger(@"Error: %@", error);
        if (failure) {
            failure(error);
        }
    }];
}

-(void)listDevices:(NSDictionary *)params success:(void (^)(NSArray *devices, NSNumber *count))success
           failure:(void (^)(NSError *error))failure {
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@", self.secretKey] forHTTPHeaderField:@"Authorization"];
    if (self.applicationKey)
        [manager.requestSerializer setValue:self.applicationKey forHTTPHeaderField:@"x-app-key"];

    [manager GET:[NSString stringWithFormat:@"%@/devices", [self getRestApiEndpoint]] parameters:params progress:nil success:^(NSURLSessionTask *operation, id responseObject) {
        if (success) {
            NSMutableArray *devices = [[NSMutableArray alloc] init];
            for (id device in [responseObject objectForKey:@"devices"]) {
                WiaDevice *d = [[WiaDevice alloc] initWithDictionary:device];
                [devices addObject:d];
            }
            success(devices, [responseObject objectForKey:@"count"]);
        }
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        WiaLogger(@"Error: %@", error);
        if (failure) {
            failure(error);
        }
    }];
}

-(void)retrieveDeviceApiKeys:(NSString *)device success:(void (^)(WiaDeviceApiKeys *))success failure:(void (^)(NSError *))failure {
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@", self.secretKey] forHTTPHeaderField:@"Authorization"];
    if (self.applicationKey)
        [manager.requestSerializer setValue:self.applicationKey forHTTPHeaderField:@"x-app-key"];

    [manager GET:[NSString stringWithFormat:@"%@/devices/%@/apiKeys", [self getRestApiEndpoint], device] parameters:nil progress:nil success:^(NSURLSessionTask *operation, id responseObject) {
        if (success) {
            success([[WiaDeviceApiKeys alloc] initWithDictionary:responseObject]);
        }
    } failure:^(NSURLSessionTask *operation, NSError *error) {
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
        WiaLogger(@"Publishing event via mqtt.");
        
        NSDictionary *device = [self.clientInfo objectForKey:@"device"];
        if (!device) {
            WiaLogger(@"Cannot send event. Not a device.");
            return;
        }
        NSString *deviceId = [device objectForKey:@"id"];
        if (!deviceId) {
            WiaLogger(@"Cannot send event. deviceId not in client info.");
            return;
        }
        WiaLogger(@"Sending event on stream with topic %@", [NSString stringWithFormat:@"devices/%@/events/%@", deviceId, [event objectForKey:@"name"]]);
        NSString *topic = [NSString stringWithFormat:@"devices/%@/events/%@", deviceId, [event objectForKey:@"name"]];

        NSError *err;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:event options:0 error:&err];
        NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        [self.mqttSession publishAndWaitData:[jsonString dataUsingEncoding:NSUTF8StringEncoding]
                            onTopic:topic
                             retain:NO
                                qos:MQTTQosLevelAtLeastOnce];
    } else {
        WiaLogger(@"Publishing event via rest.");

        AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
        manager.responseSerializer = [AFJSONResponseSerializer serializer];
        manager.requestSerializer = [AFJSONRequestSerializer serializer];
        [manager.requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@", self.secretKey] forHTTPHeaderField:@"Authorization"];
        if (self.applicationKey)
            [manager.requestSerializer setValue:self.applicationKey forHTTPHeaderField:@"x-app-key"];

        [manager POST:[NSString stringWithFormat:@"%@/events", [self getRestApiEndpoint]] parameters:event progress:nil success:^(NSURLSessionTask *operation, id responseObject) {
            if (success) {
                success([[WiaEvent alloc] initWithDictionary:responseObject]);
            }
        } failure:^(NSURLSessionTask *operation, NSError *error) {
            WiaLogger(@"Error: %@", error);
            if (failure) {
                failure(error);
            }
        }];
    }
}

-(void)subscribeToEvents:(nonnull NSDictionary *)params {
    if ([params objectForKey:@"device"]) {
        if ([params objectForKey:@"name"]) {
            [self.mqttSession subscribeToTopic:[NSString stringWithFormat:@"devices/%@/events/%@", [params objectForKey:@"device"], [params objectForKey:@"name"]] atLevel:MQTTQosLevelAtLeastOnce];
        } else {
            NSLog(@"%@", [NSString stringWithFormat:@"devices/%@/events/+", [params objectForKey:@"device"]]);
            [self.mqttSession subscribeToTopic:[NSString stringWithFormat:@"devices/%@/events/#", [params objectForKey:@"device"]] atLevel:MQTTQosLevelAtLeastOnce];
        }
    }
}

-(void)unsubscribeFromEvents:(nonnull NSDictionary *)params {
    if ([params objectForKey:@"device"]) {
        if ([params objectForKey:@"name"]) {
            [self.mqttSession unsubscribeTopic:[NSString stringWithFormat:@"devices/%@/events/%@", [params objectForKey:@"device"], [params objectForKey:@"name"]]];
        } else {
            [self.mqttSession unsubscribeTopic:[NSString stringWithFormat:@"devices/%@/events/+", [params objectForKey:@"device"]]];
        }
    }
}

-(void)listEvents:(NSDictionary *)params success:(void (^)(NSArray *events, NSNumber *count))success
          failure:(void (^)(NSError *error))failure {
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@", self.secretKey] forHTTPHeaderField:@"Authorization"];
    if (self.applicationKey)
        [manager.requestSerializer setValue:self.applicationKey forHTTPHeaderField:@"x-app-key"];

    [manager GET:[NSString stringWithFormat:@"%@/events", [self getRestApiEndpoint]] parameters:params progress:nil success:^(NSURLSessionTask *operation, id responseObject) {
        if (success) {
            WiaLogger(responseObject);
            NSMutableArray *events = [[NSMutableArray alloc] init];
            for (id eventObj in [responseObject objectForKey:@"events"]) {
                WiaEvent *e = [[WiaEvent alloc] initWithDictionary:eventObj];
                [events addObject:e];
            }
            success(events, [responseObject objectForKey:@"count"]);
        }
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        WiaLogger(@"Error: %@", error);
        if (failure) {
            failure(error);
        }
    }];
}

// Logs
-(void)publishLog:(nonnull NSDictionary *)log success:(nullable void (^)(WiaLog * _Nullable log))success
             failure:(nullable void (^)(NSError * _Nullable error))failure {
    WiaLogger(@"Publishing log - %@", log);
    
    if (self.mqttSession && self.mqttSession.status == MQTTSessionStatusConnected && self.clientInfo) {
        WiaLogger(@"Publishing log via mqtt.");
        
        NSDictionary *device = [self.clientInfo objectForKey:@"device"];
        if (!device) {
            WiaLogger(@"Cannot send event. Not a device.");
            return;
        }
        NSString *deviceId = [device objectForKey:@"id"];
        if (!deviceId) {
            WiaLogger(@"Cannot send event. deviceId not in client info.");
            return;
        }
        
        NSString *topic = [NSString stringWithFormat:@"devices/%@/logs/%@", deviceId, [log objectForKey:@"level"]];
        WiaLogger(@"Sending log on stream with topic %@", topic);
        
        NSError *err;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:log options:0 error:&err];
        NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        [self.mqttSession publishAndWaitData:[jsonString dataUsingEncoding:NSUTF8StringEncoding]
                                     onTopic:topic
                                      retain:NO
                                         qos:MQTTQosLevelAtLeastOnce];
    } else {
        WiaLogger(@"Publishing log via rest.");
        
        AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
        manager.responseSerializer = [AFJSONResponseSerializer serializer];
        manager.requestSerializer = [AFJSONRequestSerializer serializer];
        [manager.requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@", self.secretKey] forHTTPHeaderField:@"Authorization"];
        if (self.applicationKey)
            [manager.requestSerializer setValue:self.applicationKey forHTTPHeaderField:@"x-app-key"];

        [manager POST:[NSString stringWithFormat:@"%@/logs", [self getRestApiEndpoint]] parameters:log progress:nil success:^(NSURLSessionTask *operation, id responseObject) {
            if (success) {
                success([[WiaLog alloc] initWithDictionary:responseObject]);
            }
        } failure:^(NSURLSessionTask *operation, NSError *error) {
            WiaLogger(@"Error: %@", error);
            if (failure) {
                failure(error);
            }
        }];
    }
}

-(void)subscribeToLogs:(nonnull NSDictionary *)params {
    if ([params objectForKey:@"device"]) {
        if ([params objectForKey:@"level"]) {
            [self.mqttSession subscribeToTopic:[NSString stringWithFormat:@"devices/%@/logs/%@", [params objectForKey:@"device"], [params objectForKey:@"level"]] atLevel:MQTTQosLevelAtLeastOnce];
        } else {
            [self.mqttSession subscribeToTopic:[NSString stringWithFormat:@"devices/%@/logs/+", [params objectForKey:@"device"]] atLevel:MQTTQosLevelAtLeastOnce];
        }
    }
}

-(void)unsubscribeFromLogs:(nonnull NSDictionary *)params {
    if ([params objectForKey:@"device"]) {
        if ([params objectForKey:@"level"]) {
            [self.mqttSession unsubscribeTopic:[NSString stringWithFormat:@"devices/%@/logs/%@", [params objectForKey:@"device"], [params objectForKey:@"level"]]];
        } else {
            [self.mqttSession unsubscribeTopic:[NSString stringWithFormat:@"devices/%@/logs/+", [params objectForKey:@"device"]]];
        }
    }
}

-(void)listLogs:(NSDictionary *)params success:(void (^)(NSArray *logs, NSNumber *count))success
          failure:(void (^)(NSError *error))failure {
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@", self.secretKey] forHTTPHeaderField:@"Authorization"];
    if (self.applicationKey)
        [manager.requestSerializer setValue:self.applicationKey forHTTPHeaderField:@"x-app-key"];

    [manager GET:[NSString stringWithFormat:@"%@/logs", [self getRestApiEndpoint]] parameters:params progress:nil success:^(NSURLSessionTask *operation, id responseObject) {
        if (success) {
            WiaLogger(responseObject);
            NSMutableArray *logs = [[NSMutableArray alloc] init];
            for (id logObj in [responseObject objectForKey:@"logs"]) {
                WiaLog *l = [[WiaLog alloc] initWithDictionary:logObj];
                [logs addObject:l];
            }
            success(logs, [responseObject objectForKey:@"count"]);
        }
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        WiaLogger(@"Error: %@", error);
        if (failure) {
            failure(error);
        }
    }];
}

// Locations
-(void)publishLocation:(nonnull NSDictionary *)location success:(nullable void (^)(WiaLocation * _Nullable location))success
             failure:(nullable void (^)(NSError * _Nullable error))failure {
    WiaLogger(@"Publishing location - %@", location);
    
    if (self.mqttSession && self.mqttSession.status == MQTTSessionStatusConnected && self.clientInfo) {
        WiaLogger(@"Publishing location via mqtt.");
        
        NSDictionary *device = [self.clientInfo objectForKey:@"device"];
        if (!device) {
            WiaLogger(@"Cannot send event. Not a device.");
            return;
        }
        NSString *deviceId = [device objectForKey:@"id"];
        if (!deviceId) {
            WiaLogger(@"Cannot send event. deviceId not in client info.");
            return;
        }
        
        NSString *topic = [NSString stringWithFormat:@"devices/%@/locations", deviceId];
        WiaLogger(@"Sending location on stream with topic %@", topic);
        
        NSError *err;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:location options:0 error:&err];
        NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        [self.mqttSession publishAndWaitData:[jsonString dataUsingEncoding:NSUTF8StringEncoding]
                                     onTopic:topic
                                      retain:NO
                                         qos:MQTTQosLevelAtLeastOnce];
    } else {
        WiaLogger(@"Publishing location via rest.");
        
        AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
        manager.responseSerializer = [AFJSONResponseSerializer serializer];
        manager.requestSerializer = [AFJSONRequestSerializer serializer];
        [manager.requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@", self.secretKey] forHTTPHeaderField:@"Authorization"];
        if (self.applicationKey)
            [manager.requestSerializer setValue:self.applicationKey forHTTPHeaderField:@"x-app-key"];

        [manager POST:[NSString stringWithFormat:@"%@/locations", [self getRestApiEndpoint]] parameters:location progress:nil success:^(NSURLSessionTask *operation, id responseObject) {
            if (success) {
                success([[WiaLocation alloc] initWithDictionary:responseObject]);
            }
        } failure:^(NSURLSessionTask *operation, NSError *error) {
            WiaLogger(@"Error: %@", error);
            if (failure) {
                failure(error);
            }
        }];
    }
}

-(void)subscribeToLocations:(nonnull NSDictionary *)params {
    if ([params objectForKey:@"device"]) {
        [self.mqttSession subscribeToTopic:[NSString stringWithFormat:@"devices/%@/locations", [params objectForKey:@"device"]] atLevel:MQTTQosLevelAtLeastOnce];
    }
}

-(void)unsubscribeFromLocations:(nonnull NSDictionary *)params {
    if ([params objectForKey:@"device"]) {
        [self.mqttSession unsubscribeTopic:[NSString stringWithFormat:@"devices/%@/locations", [params objectForKey:@"device"]]];
    }
}

-(void)listLocations:(NSDictionary *)params success:(void (^)(NSArray *locations, NSNumber *count))success
        failure:(void (^)(NSError *error))failure {
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@", self.secretKey] forHTTPHeaderField:@"Authorization"];
    if (self.applicationKey)
        [manager.requestSerializer setValue:self.applicationKey forHTTPHeaderField:@"x-app-key"];

    [manager GET:[NSString stringWithFormat:@"%@/locations", [self getRestApiEndpoint]] parameters:params progress:nil success:^(NSURLSessionTask *operation, id responseObject) {
        if (success) {
            WiaLogger(responseObject);
            NSMutableArray *locations = [[NSMutableArray alloc] init];
            for (id locationObj in [responseObject objectForKey:@"locations"]) {
                WiaLocation *l = [[WiaLocation alloc] initWithDictionary:locationObj];
                [locations addObject:l];
            }
            success(locations, [responseObject objectForKey:@"count"]);
        }
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        WiaLogger(@"Error: %@", error);
        if (failure) {
            failure(error);
        }
    }];
}

// Sensors
-(void)publishSensor:(nonnull NSDictionary *)sensor success:(nullable void (^)(WiaSensor * _Nullable sensor))success
            failure:(nullable void (^)(NSError * _Nullable error))failure {
    WiaLogger(@"Publishing sensor - %@", sensor);
    
    if (self.mqttSession && self.mqttSession.status == MQTTSessionStatusConnected && self.clientInfo) {
        WiaLogger(@"Publishing sensor via mqtt.");
        
        NSDictionary *device = [self.clientInfo objectForKey:@"device"];
        if (!device) {
            WiaLogger(@"Cannot send event. Not a device.");
            return;
        }
        NSString *deviceId = [device objectForKey:@"id"];
        if (!deviceId) {
            WiaLogger(@"Cannot send event. deviceId not in client info.");
            return;
        }

        NSString *topic = [NSString stringWithFormat:@"devices/%@/sensors/%@", deviceId, [sensor objectForKey:@"name"]];
        WiaLogger(@"Sending sensor on stream with topic %@", topic);
        
        NSError *err;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:sensor options:0 error:&err];
        NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        [self.mqttSession publishAndWaitData:[jsonString dataUsingEncoding:NSUTF8StringEncoding]
                                     onTopic:topic
                                      retain:NO
                                         qos:MQTTQosLevelAtLeastOnce];
    } else {
        WiaLogger(@"Publishing sensor via rest.");
        
        AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
        manager.responseSerializer = [AFJSONResponseSerializer serializer];
        manager.requestSerializer = [AFJSONRequestSerializer serializer];
        [manager.requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@", self.secretKey] forHTTPHeaderField:@"Authorization"];
        if (self.applicationKey)
            [manager.requestSerializer setValue:self.applicationKey forHTTPHeaderField:@"x-app-key"];

        [manager POST:[NSString stringWithFormat:@"%@/sensors", [self getRestApiEndpoint]] parameters:sensor progress:nil success:^(NSURLSessionTask *operation, id responseObject) {
            if (success) {
                success([[WiaSensor alloc] initWithDictionary:responseObject]);
            }
        } failure:^(NSURLSessionTask *operation, NSError *error) {
            WiaLogger(@"Error: %@", error);
            if (failure) {
                failure(error);
            }
        }];
    }
}

-(void)subscribeToSensors:(nonnull NSDictionary *)params {
    if ([params objectForKey:@"device"]) {
        if ([params objectForKey:@"name"]) {
            [self.mqttSession subscribeToTopic:[NSString stringWithFormat:@"devices/%@/sensors/%@", [params objectForKey:@"device"], [params objectForKey:@"name"]] atLevel:MQTTQosLevelAtLeastOnce];
        } else {
            NSLog(@"%@", [NSString stringWithFormat:@"devices/%@/events/+", [params objectForKey:@"device"]]);
            [self.mqttSession subscribeToTopic:[NSString stringWithFormat:@"devices/%@/sensors/#", [params objectForKey:@"device"]] atLevel:MQTTQosLevelAtLeastOnce];
        }
    }
}

-(void)unsubscribeFromSensors:(nonnull NSDictionary *)params {
    if ([params objectForKey:@"device"]) {
        if ([params objectForKey:@"name"]) {
            [self.mqttSession unsubscribeTopic:[NSString stringWithFormat:@"devices/%@/sensors/%@", [params objectForKey:@"device"], [params objectForKey:@"name"]]];
        } else {
            [self.mqttSession unsubscribeTopic:[NSString stringWithFormat:@"devices/%@/sensors/+", [params objectForKey:@"device"]]];
        }
    }
}

-(void)listSensors:(NSDictionary *)params success:(void (^)(NSArray *events, NSNumber *count))success
          failure:(void (^)(NSError *error))failure {
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@", self.secretKey] forHTTPHeaderField:@"Authorization"];
    if (self.applicationKey)
        [manager.requestSerializer setValue:self.applicationKey forHTTPHeaderField:@"x-app-key"];

    [manager GET:[NSString stringWithFormat:@"%@/sensors", [self getRestApiEndpoint]] parameters:params progress:nil success:^(NSURLSessionTask *operation, id responseObject) {
        if (success) {
            WiaLogger(responseObject);
            NSMutableArray *sensors = [[NSMutableArray alloc] init];
            for (id sensorObj in [responseObject objectForKey:@"sensors"]) {
                WiaSensor *s = [[WiaSensor alloc] initWithDictionary:sensorObj];
                [sensors addObject:s];
            }
            success(sensors, [responseObject objectForKey:@"count"]);
        }
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        WiaLogger(@"Error: %@", error);
        if (failure) {
            failure(error);
        }
    }];
}

// Functions
-(void)listFunctions:(NSDictionary *)params success:(void (^)(NSArray *functions, NSNumber *count))success
           failure:(void (^)(NSError *error))failure {
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@", self.secretKey] forHTTPHeaderField:@"Authorization"];
    if (self.applicationKey)
        [manager.requestSerializer setValue:self.applicationKey forHTTPHeaderField:@"x-app-key"];

    [manager GET:[NSString stringWithFormat:@"%@/functions", [self getRestApiEndpoint]] parameters:params progress:nil success:^(NSURLSessionTask *operation, id responseObject) {
        if (success) {
            NSMutableArray *functions = [[NSMutableArray alloc] init];
            for (id func in [responseObject objectForKey:@"functions"]) {
                WiaFunction *f = [[WiaFunction alloc] initWithDictionary:func];
                [functions addObject:f];
            }
            success(functions, [responseObject objectForKey:@"count"]);
        }
    } failure:^(NSURLSessionTask *operation, NSError *error) {
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
        NSString *topic = [NSString stringWithFormat:@"devices/%@/functions/%@/call", [params objectForKey:@"device"], [params objectForKey:@"id"]];
        WiaLogger([NSString stringWithFormat:@"Publishing to topic %@", topic]);
        WiaLogger(@"%@", params);
        
        NSError *err;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:params options:0 error:&err];
        NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        [self.mqttSession publishAndWaitData:[jsonString dataUsingEncoding:NSUTF8StringEncoding]
                                     onTopic:topic
                                      retain:NO
                                         qos:MQTTQosLevelAtLeastOnce];
    } else {
        WiaLogger(@"Calling function over REST.");
        AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
        manager.responseSerializer = [AFJSONResponseSerializer serializer];
        manager.requestSerializer = [AFJSONRequestSerializer serializer];
        [manager.requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@", self.secretKey] forHTTPHeaderField:@"Authorization"];
        if (self.applicationKey)
            [manager.requestSerializer setValue:self.applicationKey forHTTPHeaderField:@"x-app-key"];

        [manager POST:[NSString stringWithFormat:@"%@/functions/%@/call", [self getRestApiEndpoint], [params objectForKey:@"id"]] parameters:params progress:nil success:^(NSURLSessionTask *operation, id responseObject) {
            WiaLogger(@"Success");
        } failure:^(NSURLSessionTask *operation, NSError *error) {
            WiaLogger(@"Error: %@", error);
        }];
    }
}

// Users
-(void)retrieveUser:(NSString *)userId success:(void (^)(WiaUser *user))success
         failure:(void (^)(NSError *error))failure {
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@", self.secretKey] forHTTPHeaderField:@"Authorization"];
    if (self.applicationKey)
        [manager.requestSerializer setValue:self.applicationKey forHTTPHeaderField:@"x-app-key"];

    [manager GET:[NSString stringWithFormat:@"%@/users/%@", [self getRestApiEndpoint], userId] parameters:nil progress:nil success:^(NSURLSessionTask *operation, id responseObject) {
        if (success) {
            success([[WiaUser alloc] initWithDictionary:responseObject]);
        }
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        WiaLogger(@"Error: %@", error);
        if (failure) {
            failure(error);
        }
    }];
}

// Customers
-(void)retrieveCustomer:(NSString *)customerId success:(void (^)(WiaCustomer *))success failure:(void (^)(NSError *))failure {
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@", self.secretKey] forHTTPHeaderField:@"Authorization"];
    if (self.applicationKey)
        [manager.requestSerializer setValue:self.applicationKey forHTTPHeaderField:@"x-app-key"];

    [manager GET:[NSString stringWithFormat:@"%@/customers/%@", [self getRestApiEndpoint], customerId] parameters:nil progress:nil success:^(NSURLSessionTask *operation, id responseObject) {
        if (success) {
            success([[WiaCustomer alloc] initWithDictionary:responseObject]);
        }
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        WiaLogger(@"Error: %@", error);
        if (failure) {
            failure(error);
        }
    }];
}

// Helpers
-(NSString *)getRestApiEndpoint {
    return [NSString stringWithFormat:@"%@://%@:%@/%@", self.restApiProtocol, self.restApiHost, self.restApiPort, self.restApiVersion];
}

// MQTTSessionDelegate
- (void)connected:(MQTTSession *)session {
    WiaLogger(@"Connected to stream.");
    if (self.delegate && [self.delegate respondsToSelector:@selector(connectedToStream)]) {
        [self.delegate connectedToStream];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:@"WiaStreamConnect" object:nil];
}

- (void)connectionRefused:(MQTTSession *)session error:(NSError *)error {
    WiaLogger(@"Connection refused.");
    if (self.delegate && [self.delegate respondsToSelector:@selector(disconnectedFromStream:)]) {
        [self.delegate disconnectedFromStream:error];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:@"WiaStreamError" object:nil];
}

- (void)connectionClosed:(MQTTSession *)session {
    WiaLogger(@"Connection closed.");
    if (self.delegate && [self.delegate respondsToSelector:@selector(disconnectedFromStream:)]) {
        [self.delegate disconnectedFromStream:nil];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:@"WiaStreamDisconnect" object:nil];
}

- (void)connectionError:(MQTTSession *)session error:(NSError *)error {
    WiaLogger(@"Connection error.");
    if (self.delegate && [self.delegate respondsToSelector:@selector(disconnectedFromStream:)]) {
        [self.delegate disconnectedFromStream:nil];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:@"WiaStreamError" object:nil];
}

- (void)protocolError:(MQTTSession *)session error:(NSError *)error {
    WiaLogger(@"Protocol error.");
    if (self.delegate && [self.delegate respondsToSelector:@selector(disconnectedFromStream:)]) {
        [self.delegate disconnectedFromStream:nil];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:@"WiaStreamError" object:nil];
}

- (void)newMessage:(MQTTSession *)session data:(NSData *)data onTopic:(NSString *)topic qos:(MQTTQosLevel)qos retained:(BOOL)retained mid:(unsigned int)mid {
    WiaLogger(@"New message received. topic - %@, data - %@", topic, data);
    NSRange searchedRange = NSMakeRange(0, [topic length]);
    NSError *error = nil;
    
    NSRegularExpression* regex = [NSRegularExpression regularExpressionWithPattern:@"devices/(.*?)/events/(.*)" options:0 error:&error];
    NSTextCheckingResult *match = [regex firstMatchInString:topic options:0 range: searchedRange];
    
    if (match) {
        WiaLogger(@"WiaNewEvent");
        NSString *device = [topic substringWithRange:[match rangeAtIndex:1]];
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(newEvent:)]) {
            WiaEvent *event = [[WiaEvent alloc] initWithDictionary:[NSJSONSerialization JSONObjectWithData:data options:0 error:nil]];
            event.device = device;
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
        NSString *device = [topic substringWithRange:[match rangeAtIndex:1]];
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(newLog:)]) {
            WiaLog *log = [[WiaLog alloc] initWithDictionary:[NSJSONSerialization JSONObjectWithData:data options:0 error:nil]];
            log.device = device;
            [self.delegate newLog:log];
        }
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"WiaNewLog" object:self
                                                          userInfo:[NSJSONSerialization JSONObjectWithData:data
                                                                                                   options:NSJSONReadingMutableContainers error:&error]];
        return;
    }

    regex = [NSRegularExpression regularExpressionWithPattern:@"devices/(.*?)/locations" options:0 error:&error];
    match = [regex firstMatchInString:topic options:0 range: searchedRange];
    
    if (match) {
        WiaLogger(@"WiaNewLocation");
        NSString *device = [topic substringWithRange:[match rangeAtIndex:1]];
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(newLocation:)]) {
            WiaLocation *location = [[WiaLocation alloc] initWithDictionary:[NSJSONSerialization JSONObjectWithData:data options:0 error:nil]];
            location.device = device;
            [self.delegate newLocation:location];
        }
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"WiaNewLocation" object:self
                                                          userInfo:[NSJSONSerialization JSONObjectWithData:data
                                                                                                   options:NSJSONReadingMutableContainers error:&error]];
        return;
    }
    
    regex = [NSRegularExpression regularExpressionWithPattern:@"devices/(.*?)/sensors/(.*)" options:0 error:&error];
    match = [regex firstMatchInString:topic options:0 range: searchedRange];
    
    if (match) {
        WiaLogger(@"WiaNewSensor");
        NSString *device = [topic substringWithRange:[match rangeAtIndex:1]];
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(newSensor:)]) {
            WiaSensor *sensor = [[WiaSensor alloc] initWithDictionary:[NSJSONSerialization JSONObjectWithData:data options:0 error:nil]];
            sensor.device = device;
            [self.delegate newSensor:sensor];
        }
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"WiaNewSensor" object:self
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

-(void)sending:(MQTTSession *)session type:(MQTTCommandType)type qos:(MQTTQosLevel)qos retained:(BOOL)retained duped:(BOOL)duped mid:(UInt16)mid data:(NSData *)data {
    WiaLogger(@"sending.");
    if (data)
        WiaLogger(@"sending data: %@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
}

-(void)received:(MQTTSession *)session type:(MQTTCommandType)type qos:(MQTTQosLevel)qos retained:(BOOL)retained duped:(BOOL)duped mid:(UInt16)mid data:(NSData *)data {
    WiaLogger(@"received.");
    if (data)
        WiaLogger(@"received data: %@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
}

@end
