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
#import "WiaFunction.h"
#import "WiaUser.h"
#import "WiaLog.h"
#import "MQTTClient.h"
#import "WiaUtils.h"

@protocol WiaClientDelegate <NSObject>

@optional

- (void)connectedToStream;
- (void)disconnectedFromStream:(NSError * _Nullable)error;
- (void)newEvent:(WiaEvent * _Nullable)event;
- (void)newLog:(WiaLog * _Nullable)log;

@end

@interface WiaClient : NSObject <MQTTSessionDelegate>

@property (weak, nonatomic) id<WiaClientDelegate> delegate;

@property (nonatomic, copy, nullable) NSString *clientToken;

@property (nonatomic, readwrite, nullable) NSURL *restApiURL;
@property (nonatomic, readwrite, nullable) NSURL *mqttApiURL;
@property (nonatomic, strong, nullable) MQTTSession *mqttSession;

@property (nonatomic, strong, nullable) NSDictionary *clientInfo;

+(nonnull instancetype)sharedInstance;
+(void)debug:(BOOL)showDebugLogs;

-(nonnull instancetype)initWithToken:(nonnull NSString *)token NS_DESIGNATED_INITIALIZER;

// Stream
-(void)connectToStream;
-(void)disconnectFromStream;

// Devices
-(void)createDevice:(nonnull NSDictionary *)device success:(nullable void (^)(WiaDevice * _Nullable device))success
            failure:(nullable void (^)(NSError * _Nullable error))failure;
-(void)retrieveDevice:(nonnull NSString *)deviceKey success:(nullable void (^)(WiaDevice * _Nullable device))success
            failure:(nullable void (^)(NSError * _Nullable error))failure;
-(void)updateDevice:(nonnull NSString *)deviceKey fields:(nullable NSDictionary *)fields success:(nullable void (^)(WiaDevice * _Nullable device))success
            failure:(nullable void (^)(NSError * _Nullable error))failure;
-(void)deleteDevice:(nonnull NSString *)deviceKey success:(nullable void (^)(WiaDevice * _Nullable device))success
            failure:(nullable void (^)(NSError * _Nullable error))failure;
-(void)listDevices:(nullable NSDictionary *)params success:(nullable void (^)(NSArray * _Nullable devices))success
            failure:(nullable void (^)(NSError * _Nullable error))failure;

// Events
-(void)publishEvent:(nonnull NSDictionary *)event success:(nullable void (^)(WiaEvent * _Nullable event))success
            failure:(nullable void (^)(NSError * _Nullable error))failure;
-(void)subscribeToEvents:(nonnull NSDictionary *)params;
-(void)unsubscribeFromEvents:(nonnull NSDictionary *)params;

// Logs
-(void)subscribeToLogs:(nonnull NSDictionary *)params;
-(void)unsubscribeFromLogs:(nonnull NSDictionary *)params;

// Functions
-(void)listFunctions:(nullable NSDictionary *)params success:(nullable void (^)(NSArray * _Nullable functions))success
             failure:(nullable void (^)(NSError * _Nullable error))failure;
-(void)callFunction:(nullable NSDictionary *)params;

// Users
-(void)getUserMe:(nullable void (^)(WiaUser * _Nullable user))success
            failure:(nullable void (^)(NSError * _Nullable error))failure;

@end