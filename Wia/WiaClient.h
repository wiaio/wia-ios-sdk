//
//  WiaClient.h
//  Wia
//
//  Created by Conall Laverty on 22/09/2015.
//
//

#import <Foundation/Foundation.h>
#import "WiaClient.h"
#import "WiaDevice.h"
#import "WiaEvent.h"
#import "WiaUser.h"
#import "MQTTClient.h"
#import "WiaUtils.h"
#import "WiaAccessToken.h"

@protocol WiaClientDelegate <NSObject>

@optional

- (void)connectedToStream;
- (void)disconnectedFromStream:(NSError * _Nullable)error;
- (void)newEvent:(WiaEvent * _Nullable)event;

@end

@interface WiaClient : NSObject <MQTTSessionDelegate>

@property (weak, nonatomic) id<WiaClientDelegate> delegate;

@property (nonatomic, copy, nullable) NSString *publicKey;
@property (nonatomic, copy, nullable) NSString *secretKey;

@property (nonatomic, readwrite, nullable) NSString *restApiProtocol;
@property (nonatomic, readwrite, nullable) NSString *restApiHost;
@property (nonatomic, readwrite, nullable) NSString *restApiPort;
@property (nonatomic, readwrite, nullable) NSString *restApiVersion;

@property (nonatomic, readwrite, nullable) NSString *mqttApiProtocol;
@property (nonatomic, readwrite, nullable) NSString *mqttApiHost;
@property (nonatomic, readwrite, nullable) NSString *mqttApiPort;
@property (nonatomic, readwrite) BOOL mqttApiSecure;

@property (nonatomic, strong, nullable) MQTTSession *mqttSession;

@property (nonatomic, strong, nullable) NSDictionary *clientInfo;

+(nonnull instancetype)sharedInstance;
+(void)debug:(BOOL)showDebugLogs;

-(nonnull instancetype)initWithToken:(nonnull NSString *)token NS_DESIGNATED_INITIALIZER;

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
-(void)deleteDevice:(nonnull NSString *)deviceId success:(nullable void (^)(BOOL * _Nullable deleted))success
            failure:(nullable void (^)(NSError * _Nullable error))failure;
-(void)listDevices:(nullable NSDictionary *)params success:(nullable void (^)(NSArray * _Nullable devices, NSNumber * _Nullable count))success
            failure:(nullable void (^)(NSError * _Nullable error))failure;

// Events
-(void)publishEvent:(nonnull NSDictionary *)event success:(nullable void (^)(WiaEvent * _Nullable event))success
            failure:(nullable void (^)(NSError * _Nullable error))failure;
-(void)subscribeToEvents:(nonnull NSDictionary *)params;
-(void)unsubscribeFromEvents:(nonnull NSDictionary *)params;

// Users
-(void)getUserMe:(nullable void (^)(WiaUser * _Nullable user))success
            failure:(nullable void (^)(NSError * _Nullable error))failure;

@end