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
#import "WiaCommand.h"
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
-(void)subscribeToEvents:(nonnull NSDictionary *)params;
-(void)unsubscribeFromEvents:(nonnull NSDictionary *)params;

// Logs
-(void)subscribeToLogs:(nonnull NSDictionary *)params;
-(void)unsubscribeFromLogs:(nonnull NSDictionary *)params;

// Users
-(void)getUserMe:(nullable void (^)(WiaUser * _Nullable user))success
            failure:(nullable void (^)(NSError * _Nullable error))failure;

/*
-(void)listDeviceEvents:(NSString *)deviceKey success:(void (^)(NSArray *events))success
                failure:(void (^)(NSError *error))failure;
-(void)listDeviceEvents:(NSString *)deviceKey limit:(NSUInteger)limit success:(void (^)(NSArray *events))success
                failure:(void (^)(NSError *error))failure;
-(void)listDeviceEvents:(NSString *)deviceKey limit:(NSUInteger)limit page:(NSUInteger)page success:(void (^)(NSArray *events))success
                failure:(void (^)(NSError *error))failure;
-(void)listDeviceEvents:(NSString *)deviceKey limit:(NSUInteger)limit page:(NSUInteger)page eventName:(NSString *)eventName
                success:(void (^)(NSArray *events))success
                failure:(void (^)(NSError *error))failure;

-(void)listDeviceCommands:(NSString *)deviceKey success:(void (^)(NSArray *commands))success
                  failure:(void (^)(NSError *error))failure;
-(void)listDeviceCommands:(NSString *)deviceKey limit:(NSUInteger)limit success:(void (^)(NSArray *commands))success
                  failure:(void (^)(NSError *error))failure;
-(void)listDeviceCommands:(NSString *)deviceKey limit:(NSUInteger)limit page:(NSUInteger)page success:(void (^)(NSArray *commands))success
                  failure:(void (^)(NSError *error))failure;

-(void)listEvents:(void (^)(NSArray *events))success
          failure:(void (^)(NSError *error))failure;
-(void)listEvents:(NSUInteger)limit success:(void (^)(NSArray *events))success
          failure:(void (^)(NSError *error))failure;
-(void)listEvents:(NSUInteger)limit page:(NSUInteger)page success:(void (^)(NSArray *events))success
          failure:(void (^)(NSError *error))failure;
-(void)listEvents:(NSUInteger)limit page:(NSUInteger)page eventName:(NSString *)eventName success:(void (^)(NSArray *events))success
          failure:(void (^)(NSError *error))failure;

-(void)runCommand:(NSString *)deviceKey commandName:(NSString *)commandName success:(void (^)(NSObject *obj))success
          failure:(void (^)(NSError *error))failure;
-(void)runCommand:(NSString *)deviceKey commandName:(NSString *)commandName commandData:(NSDictionary *)commandData success:(void (^)(NSObject *obj))success
          failure:(void (^)(NSError *error))failure;
*/
/*
-(void)getUserMe:(void (^)(WiaUser *user))success
         failure:(void (^)(NSError *error))failure;

-(void)generateUserToken:(NSString *)username password:(NSString *)password
                 success:(void (^)(WiaUserToken *userToken))success
                 failure:(void (^)(NSError *error))failure;
*/

@end