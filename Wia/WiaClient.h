//
//  WiaClient.h
//  Wia
//
//  Created by Conall Laverty on 22/09/2015.
//
//

#import "WiaClient.h"
#import "WiaDevice.h"
#import "WiaEvent.h"
#import "WiaUser.h"
#import "WiaUtils.h"
#import "WiaAccessToken.h"
#import "WiaLog.h"
#import "WiaLocation.h"
#import "WiaDeviceApiKeys.h"
#import "WiaFunction.h"
#import "WiaSensor.h"
#import "WiaCustomer.h"
@import MQTTClient;

@protocol WiaClientDelegate <NSObject>

@optional

- (void)connectedToStream;
- (void)disconnectedFromStream:(NSError * _Nullable)error;
- (void)newEvent:(WiaEvent * _Nullable)event;
- (void)newLog:(WiaLog * _Nullable)log;
- (void)newLocation:(WiaLocation * _Nullable)location;
- (void)newSensor:(WiaSensor * _Nullable)sensor;

@end

@interface WiaClient : NSObject <MQTTSessionDelegate>

@property (weak, nonatomic, nullable) id<WiaClientDelegate> delegate;

@property (nonatomic, copy, nullable) NSString *publicKey;
@property (nonatomic, copy, nullable) NSString *secretKey;
@property (nonatomic, copy, nullable) NSString *applicationKey;

@property (nonatomic, readwrite, nullable) NSString *restApiProtocol;
@property (nonatomic, readwrite, nullable) NSString *restApiHost;
@property (nonatomic, readwrite, nullable) NSString *restApiPort;
@property (nonatomic, readwrite, nullable) NSString *restApiVersion;

@property (nonatomic, readwrite, nullable) NSString *mqttApiProtocol;
@property (nonatomic, readwrite, nullable) NSString *mqttApiHost;
@property (nonatomic, readwrite, nullable) NSString *mqttApiPort;
@property (nonatomic, readwrite) BOOL mqttApiSecure;

@property (nonatomic, strong, nullable) MQTTTransport *mqttTransport;
@property (nonatomic, strong, nullable) MQTTSession *mqttSession;

@property (nonatomic, strong, nullable) NSDictionary *clientInfo;

+(nonnull instancetype)sharedInstance;
+(void)debug:(BOOL)showDebugLogs;

-(nonnull instancetype)initWithToken:(nonnull NSString *)token NS_DESIGNATED_INITIALIZER;
-(nonnull instancetype)initWithApplicationKey:(nonnull NSString *)applicationKey NS_DESIGNATED_INITIALIZER;

-(void)reset;

// Access token
-(void)generateAccessToken:(nonnull NSDictionary *)params success:(nullable void (^)(WiaAccessToken * _Nullable accessToken))success
                          failure:(nullable void (^)(NSError * _Nullable error))failure;

// Stream
-(void)connectToStream;
-(void)disconnectFromStream;

// Devices
-(void)createDevice:(nonnull NSDictionary *)device success:(nullable void (^)(WiaDevice * _Nullable device))success
            failure:(nullable void (^)(NSError * _Nullable error))failure;
-(void)retrieveDevice:(nonnull NSString *)deviceId success:(nullable void (^)(WiaDevice * _Nullable device))success
            failure:(nullable void (^)(NSError * _Nullable error))failure;
-(void)updateDevice:(nonnull NSString *)deviceId fields:(nullable NSDictionary *)fields success:(nullable void (^)(WiaDevice * _Nullable device))success
            failure:(nullable void (^)(NSError * _Nullable error))failure;
-(void)deleteDevice:(nonnull NSString *)deviceId success:(nullable void (^)(BOOL deleted))success
            failure:(nullable void (^)(NSError * _Nullable error))failure;
-(void)listDevices:(nullable NSDictionary *)params success:(nullable void (^)(NSArray * _Nullable devices, NSNumber * _Nullable count))success
            failure:(nullable void (^)(NSError * _Nullable error))failure;
-(void)retrieveDeviceApiKeys:(nonnull NSString *)device success:(nullable void (^)(WiaDeviceApiKeys * _Nullable apiKeys))success
              failure:(nullable void (^)(NSError * _Nullable error))failure;

// Events
-(void)publishEvent:(nonnull NSDictionary *)event success:(nullable void (^)(WiaEvent * _Nullable event))success
            failure:(nullable void (^)(NSError * _Nullable error))failure;
-(void)subscribeToEvents:(nonnull NSDictionary *)params;
-(void)unsubscribeFromEvents:(nonnull NSDictionary *)params;
-(void)listEvents:(nullable NSDictionary *)params success:(nullable void (^)(NSArray * _Nullable events, NSNumber * _Nullable count))success
           failure:(nullable void (^)(NSError * _Nullable error))failure;

// Logs
-(void)publishLog:(nonnull NSDictionary *)log success:(nullable void (^)(WiaLog * _Nullable log))success
          failure:(nullable void (^)(NSError * _Nullable error))failure;
-(void)subscribeToLogs:(nonnull NSDictionary *)params;
-(void)unsubscribeFromLogs:(nonnull NSDictionary *)params;
-(void)listLogs:(nullable NSDictionary *)params success:(nullable void (^)(NSArray * _Nullable logs, NSNumber * _Nullable count))success
        failure:(nullable void (^)(NSError * _Nullable error))failure;

// Locations
-(void)publishLocation:(nonnull NSDictionary *)location success:(nullable void (^)(WiaLocation * _Nullable location))success
          failure:(nullable void (^)(NSError * _Nullable error))failure;
-(void)subscribeToLocations:(nonnull NSDictionary *)params;
-(void)unsubscribeFromLocations:(nonnull NSDictionary *)params;
-(void)listLocations:(nullable NSDictionary *)params success:(nullable void (^)(NSArray * _Nullable locations, NSNumber * _Nullable count))success
        failure:(nullable void (^)(NSError * _Nullable error))failure;

// Sensors
-(void)publishSensor:(nonnull NSDictionary *)sensor success:(nullable void (^)(WiaSensor * _Nullable sensor))success
            failure:(nullable void (^)(NSError * _Nullable error))failure;
-(void)subscribeToSensors:(nonnull NSDictionary *)params;
-(void)unsubscribeFromSensors:(nonnull NSDictionary *)params;
-(void)listSensors:(nullable NSDictionary *)params success:(nullable void (^)(NSArray * _Nullable sensors, NSNumber * _Nullable count))success
          failure:(nullable void (^)(NSError * _Nullable error))failure;

// Functions
-(void)listFunctions:(nullable NSDictionary *)params success:(nullable void (^)(NSArray * _Nullable functions, NSNumber * _Nullable count))success
             failure:(nullable void (^)(NSError * _Nullable error))failure;
-(void)callFunction:(nullable NSDictionary *)params;

// Users
-(void)retrieveUser:(nonnull NSString *)userId success:(nullable void (^)(WiaUser * _Nullable user))success
         failure:(nullable void (^)(NSError * _Nullable error))failure;

// Customers
-(void)retrieveCustomer:(nonnull NSString *)customerId success:(nullable void (^)(WiaCustomer * _Nullable customer))success
              failure:(nullable void (^)(NSError * _Nullable error))failure;

@end
