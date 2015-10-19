//
//  WiaUserClient.h
//  Wia
//
//  Created by Conall Laverty on 22/09/2015.
//
//

#import "WiaClient.h"
#import "WiaDevice.h"
#import "WiaEvent.h"
#import "WiaCommand.h"

@interface WiaUserClient : WiaClient

-(void)createDevice:(NSString *)name success:(void (^)(WiaDevice *device))success
            failure:(void (^)(NSError *error))failure;

-(void)listDevices:(void (^)(NSArray *devices))success
           failure:(void (^)(NSError *error))failure;
-(void)listDevices:(NSUInteger)limit success:(void (^)(NSArray *devices))success
           failure:(void (^)(NSError *error))failure;
-(void)listDevices:(NSUInteger)limit page:(NSUInteger)page success:(void (^)(NSArray *devices))success
           failure:(void (^)(NSError *error))failure;

-(void)getDevice:(NSString *)deviceKey success:(void (^)(WiaDevice *device))success
            failure:(void (^)(NSError *error))failure;

-(void)listDeviceEvents:(NSString *)deviceKey success:(void (^)(NSArray *events))success
                failure:(void (^)(NSError *error))failure;
-(void)listDeviceEvents:(NSString *)deviceKey limit:(NSUInteger)limit success:(void (^)(NSArray *events))success
                failure:(void (^)(NSError *error))failure;
-(void)listDeviceEvents:(NSString *)deviceKey limit:(NSUInteger)limit page:(NSUInteger)page success:(void (^)(NSArray *events))success
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

-(void)runCommand:(NSString *)deviceKey commandName:(NSString *)commandName success:(void (^)(NSObject *obj))success
          failure:(void (^)(NSError *error))failure;
-(void)runCommand:(NSString *)deviceKey commandName:(NSString *)commandName commandData:(NSDictionary *)commandData success:(void (^)(NSObject *obj))success
          failure:(void (^)(NSError *error))failure;

@end