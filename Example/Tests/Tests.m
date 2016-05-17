//
//  Tests.m
//  Wia
//
//  Created by Conall Laverty on 17/05/2016.
//  Copyright © 2016 Wia. All rights reserved.
//

#import "Wia.h"
#import <Specta/Specta.h>

SpecBegin(InitialSpecs)

describe(@"access token", ^{
    beforeAll(^{
        [[WiaClient sharedInstance] reset];
        [[WiaClient sharedInstance] setRestApiProtocol:@"http"];
        [[WiaClient sharedInstance] setRestApiHost:@"localhost"];
        [[WiaClient sharedInstance] setRestApiPort:@"8081"];
    });

    it(@"generate access token for a user", ^{
        NSLog(@"Generating access token for user");
        waitUntil(^(DoneCallback done) {
            [[WiaClient sharedInstance] generateAccessToken:@{
                                                                        @"username": @"yh9frZAlX0ApiosL@y6FyH1KNnq7Epkfd.com",
                                                                        @"password": @"password",
                                                                        @"scope": @"user",
                                                                        @"grantType": @"password"
                                                                     } success:^(WiaAccessToken * _Nullable accessToken) {
                                                                         XCTAssertNotNil(accessToken);
                                                                         done();
                                                                     } failure:^(NSError * _Nullable error) {
                                                                         XCTAssertNil(error);
                                                                         done();
                                                                     }];
        });
    });
});

describe(@"devices", ^{
    beforeAll(^{
        [[WiaClient sharedInstance] reset];
        [[WiaClient sharedInstance] setRestApiProtocol:@"http"];
        [[WiaClient sharedInstance] setRestApiHost:@"localhost"];
        [[WiaClient sharedInstance] setRestApiPort:@"8081"];
        
        waitUntil(^(DoneCallback done) {
            [[WiaClient sharedInstance] generateAccessToken:@{
                                                              @"username": @"yh9frZAlX0ApiosL@y6FyH1KNnq7Epkfd.com",
                                                              @"password": @"password",
                                                              @"scope": @"user",
                                                              @"grantType": @"password"
                                                              } success:^(WiaAccessToken * _Nullable accessToken) {
                                                                  XCTAssertNotNil(accessToken);
                                                                  [[WiaClient sharedInstance] setSecretKey:accessToken.accessToken];
                                                                  done();
                                                              } failure:^(NSError * _Nullable error) {
                                                                  XCTAssertNil(error);
                                                                  done();
                                                              }];
        });
    });
    
    it(@"create device", ^{
        waitUntil(^(DoneCallback done) {
            [[WiaClient sharedInstance] createDevice:@{
                                                       @"name": @"testDevice"
                                                       } success:^(WiaDevice * _Nullable device) {
                XCTAssertNotNil(device);
                done();
            } failure:^(NSError * _Nullable error) {
                XCTAssertNil(error);
            }];
        });
    });
    
    it(@"retrieve device", ^{
        waitUntil(^(DoneCallback done) {
            [[WiaClient sharedInstance] createDevice:@{
                                                       @"name": @"testDevice"
                                                       } success:^(WiaDevice * _Nullable createdDevice) {
                                                           XCTAssertNotNil(createdDevice);
                                                           [[WiaClient sharedInstance] retrieveDevice:createdDevice.id
                                                                                              success:^(WiaDevice * _Nullable retrievedDevice) {
                                                                                                  XCTAssertNotNil(retrievedDevice);
                                                                                                  XCTAssertEqualObjects(createdDevice.id, retrievedDevice.id, "Could not retrieve device.");
                                                                                                  done();
                                                                                              } failure:^(NSError * _Nullable error) {
                                                                                                  XCTAssertNil(error);
                                                                                              }];
                                                       } failure:^(NSError * _Nullable error) {
                                                           XCTAssertNil(error);
                                                       }];
        });
    });

    it(@"update device", ^{
        waitUntil(^(DoneCallback done) {
            [[WiaClient sharedInstance] createDevice:@{
                                                       @"name": @"testDeviceOne"
                                                       } success:^(WiaDevice * _Nullable createdDevice) {
                                                           XCTAssertNotNil(createdDevice);
                                                           [[WiaClient sharedInstance] updateDevice:createdDevice.id
                                                                                             fields:@{
                                                                                                      @"name": @"testDeviceTwo"
                                                                                                      }
                                                                                              success:^(WiaDevice * _Nullable retrievedDevice) {
                                                                                                  XCTAssertNotNil(retrievedDevice);
                                                                                                  XCTAssertNotEqualObjects(createdDevice.name, retrievedDevice.name, "Could not retrieve device.");
                                                                                                  done();
                                                                                              } failure:^(NSError * _Nullable error) {
                                                                                                  XCTAssertNil(error);
                                                                                              }];
                                                       } failure:^(NSError * _Nullable error) {
                                                           XCTAssertNil(error);
                                                       }];
        });
    });
    
    it(@"delete device", ^{
        waitUntil(^(DoneCallback done) {
            [[WiaClient sharedInstance] createDevice:@{@"name": @"testDeviceOne"} success:^(WiaDevice * _Nullable createdDevice) {
               XCTAssertNotNil(createdDevice);
               [[WiaClient sharedInstance] deleteDevice:createdDevice.id
                                                success:^(BOOL * _Nullable deleted) {
                                                    [[WiaClient sharedInstance] retrieveDevice:createdDevice.id
                                                                                     success:^(WiaDevice * _Nullable retrievedDevice) {
                                                                                         XCTAssertNil(retrievedDevice);
                                                                                     } failure:^(NSError * _Nullable error) {
                                                                                         XCTAssertNotNil(error);
                                                                                         done();
                                                                                     }];
                                                } failure:^(NSError * _Nullable error) {
                                                    XCTAssertNil(error);
                                                }];
            } failure:^(NSError * _Nullable error) {
                XCTAssertNil(error);
            }];
        });
    });

    it(@"list devices", ^{
        waitUntil(^(DoneCallback done) {
           [[WiaClient sharedInstance] listDevices:@{} success:^(NSArray * _Nullable devices, NSNumber * _Nullable count) {
               XCTAssertNotNil(devices);
               NSLog(@"%@", devices);
               done();
            } failure:^(NSError * _Nullable error) {
                XCTAssertNil(error);
            }];
        });
    });
});

SpecEnd
