//
//  WiaUserClient.m
//  Wia
//
//  Created by Conall Laverty on 22/09/2015.
//
//

#import "WiaUserClient.h"
#import "AFNetworking.h"

static NSUInteger const DEFAULT_LIST_LIMIT = 20;
static NSUInteger const DEFAULT_LIST_PAGE = 0;

@implementation WiaUserClient

-(void)createDevice:(NSString *)name success:(void (^)(WiaDevice *device))success
            failure:(void (^)(NSError *error))failure {
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@", self.clientToken] forHTTPHeaderField:@"Authorization"];
    
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    [dict setObject:name forKey:@"name"];
    
    [manager POST:[NSString stringWithFormat:@"https://api.wia.io/v1/devices"] parameters:dict success:^(AFHTTPRequestOperation *operation, id responseObject) {
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

-(void)listDevices:(void (^)(NSArray *devices))success
           failure:(void (^)(NSError *error))failure {
    [self listDevices:DEFAULT_LIST_LIMIT page:DEFAULT_LIST_PAGE success:success failure:failure];
}

-(void)listDevices:(NSUInteger)limit success:(void (^)(NSArray *devices))success
           failure:(void (^)(NSError *error))failure {
    [self listDevices:limit page:DEFAULT_LIST_PAGE success:success failure:failure];
}

-(void)listDevices:(NSUInteger)limit page:(NSUInteger)page success:(void (^)(NSArray *devices))success
           failure:(void (^)(NSError *error))failure {
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@", self.clientToken] forHTTPHeaderField:@"Authorization"];

    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    [dict setObject:[NSNumber numberWithInteger:limit] forKey:@"limit"];
    [dict setObject:[NSNumber numberWithInteger:page] forKey:@"page"];
    
    [manager GET:[NSString stringWithFormat:@"https://api.wia.io/v1/devices"] parameters:dict success:^(AFHTTPRequestOperation *operation, id responseObject) {
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


-(void)getDevice:(NSString *)deviceKey success:(void (^)(WiaDevice *device))success
            failure:(void (^)(NSError *error))failure {
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@", self.clientToken] forHTTPHeaderField:@"Authorization"];
    
    [manager GET:[NSString stringWithFormat:@"https://api.wia.io/v1/devices/%@", deviceKey] parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
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

-(void)listDeviceEvents:(NSString *)deviceKey success:(void (^)(NSArray *events))success
                failure:(void (^)(NSError *error))failure {
    [self listDeviceEvents:deviceKey limit:DEFAULT_LIST_LIMIT page:DEFAULT_LIST_PAGE success:success failure:failure];
}

-(void)listDeviceEvents:(NSString *)deviceKey limit:(NSUInteger)limit success:(void (^)(NSArray *events))success
                failure:(void (^)(NSError *error))failure {
    [self listDeviceEvents:deviceKey limit:limit page:DEFAULT_LIST_PAGE success:success failure:failure];
}

-(void)listDeviceEvents:(NSString *)deviceKey limit:(NSUInteger)limit page:(NSUInteger)page success:(void (^)(NSArray *events))success
                failure:(void (^)(NSError *error))failure {
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@", self.clientToken] forHTTPHeaderField:@"Authorization"];
    
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    [dict setObject:[NSNumber numberWithInteger:limit] forKey:@"limit"];
    [dict setObject:[NSNumber numberWithInteger:page] forKey:@"page"];
    
    [manager GET:[NSString stringWithFormat:@"https://api.wia.io/v1/devices/%@/events", deviceKey] parameters:dict success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (success) {
            NSMutableArray *events = [[NSMutableArray alloc] init];
            for (id event in [responseObject objectForKey:@"events"]) {
                WiaEvent *e = [[WiaEvent alloc] initWithDictionary:event];
                [events addObject:e];
            }
            success(events);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        if (failure) {
            failure(error);
        }
    }];
}

-(void)listDeviceCommands:(NSString *)deviceKey success:(void (^)(NSArray *events))success
                failure:(void (^)(NSError *error))failure {
    [self listDeviceCommands:deviceKey limit:DEFAULT_LIST_LIMIT page:DEFAULT_LIST_PAGE success:success failure:failure];
}

-(void)listDeviceCommands:(NSString *)deviceKey limit:(NSUInteger)limit success:(void (^)(NSArray *events))success
                failure:(void (^)(NSError *error))failure {
    [self listDeviceCommands:deviceKey limit:limit page:DEFAULT_LIST_PAGE success:success failure:failure];
}

-(void)listDeviceCommands:(NSString *)deviceKey limit:(NSUInteger)limit page:(NSUInteger)page success:(void (^)(NSArray *events))success
                failure:(void (^)(NSError *error))failure {
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@", self.clientToken] forHTTPHeaderField:@"Authorization"];
    
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    [dict setObject:[NSNumber numberWithInteger:limit] forKey:@"limit"];
    [dict setObject:[NSNumber numberWithInteger:page] forKey:@"page"];
    
    [manager GET:[NSString stringWithFormat:@"https://api.wia.io/v1/devices/%@/commands", deviceKey] parameters:dict success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (success) {
            NSMutableArray *events = [[NSMutableArray alloc] init];
            for (id command in [responseObject objectForKey:@"commands"]) {
                WiaCommand *c = [[WiaCommand alloc] initWithDictionary:command];
                [events addObject:c];
            }
            success(events);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        if (failure) {
            failure(error);
        }
    }];
}

-(void)listEvents:(void (^)(NSArray *events))success
                failure:(void (^)(NSError *error))failure {
    [self listEvents:DEFAULT_LIST_LIMIT page:DEFAULT_LIST_PAGE success:success failure:failure];
}

-(void)listEvents:(NSUInteger)limit success:(void (^)(NSArray *events))success
                failure:(void (^)(NSError *error))failure {
    [self listEvents:limit page:DEFAULT_LIST_PAGE success:success failure:failure];
}

-(void)listEvents:(NSUInteger)limit page:(NSUInteger)page success:(void (^)(NSArray *events))success
                failure:(void (^)(NSError *error))failure {
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@", self.clientToken] forHTTPHeaderField:@"Authorization"];
    
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    [dict setObject:[NSNumber numberWithInteger:limit] forKey:@"limit"];
    [dict setObject:[NSNumber numberWithInteger:page] forKey:@"page"];
    
    [manager GET:[NSString stringWithFormat:@"https://api.wia.io/v1/events"] parameters:dict success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (success) {
            NSMutableArray *events = [[NSMutableArray alloc] init];
            for (id event in [responseObject objectForKey:@"events"]) {
                WiaEvent *e = [[WiaEvent alloc] initWithDictionary:event];
                [events addObject:e];
            }
            success(events);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        if (failure) {
            failure(error);
        }
    }];
}

-(void)runCommand:(NSString *)deviceKey commandName:(NSString *)commandName success:(void (^)(NSObject *obj))success
          failure:(void (^)(NSError *error))failure {
    [self runCommand:deviceKey commandName:commandName commandData:nil success:success failure:failure];
}

-(void)runCommand:(NSString *)deviceKey commandName:(NSString *)commandName commandData:(NSDictionary *)commandData success:(void (^)(NSObject *obj))success
          failure:(void (^)(NSError *error))failure {
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@", self.clientToken] forHTTPHeaderField:@"Authorization"];
    
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    if (commandData) {
        [dict setObject:commandData forKey:@"commandData"];
    }
    
    [manager POST:[NSString stringWithFormat:@"https://api.wia.io/v1/devices/%@/commands/%@/run", deviceKey, commandName]
       parameters:dict success:^(AFHTTPRequestOperation *operation, id responseObject) {
           if (success) {
               success(nil);
           }
       } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
           NSLog(@"Error: %@", error);
           if (failure) {
               failure(error);
           }
       }];
}

@end