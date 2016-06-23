//
//  Tests.m
//  Wia
//
//  Created by Conall Laverty on 17/05/2016.
//  Copyright © 2016 Wia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Wia.h"
#import <Specta/Specta.h>

NSString *userAccessToken;
NSString *deviceSecretKey;

SpecBegin(InitialSpecs)

beforeAll(^{
    [[WiaClient sharedInstance] reset];
    [WiaClient debug:YES];
    NSLog(@"%@", [[NSProcessInfo processInfo] environment]);
    [[WiaClient sharedInstance] setRestApiProtocol:[[[NSProcessInfo processInfo] environment] objectForKey:@"WIA_TEST_REST_PROTOCOL"]];
    [[WiaClient sharedInstance] setRestApiHost:[[[NSProcessInfo processInfo] environment] objectForKey:@"WIA_TEST_REST_HOST"]];
    [[WiaClient sharedInstance] setRestApiPort:[[[NSProcessInfo processInfo] environment] objectForKey:@"WIA_TEST_REST_PORT"]];
    
    [[WiaClient sharedInstance] setMqttApiProtocol:[[[NSProcessInfo processInfo] environment] objectForKey:@"WIA_TEST_STREAM_PROTOCOL"]];
    [[WiaClient sharedInstance] setMqttApiHost:[[[NSProcessInfo processInfo] environment] objectForKey:@"WIA_TEST_STREAM_HOST"]];
    [[WiaClient sharedInstance] setMqttApiPort:[[[NSProcessInfo processInfo] environment] objectForKey:@"WIA_TEST_STREAM_PORT"]];
    [[WiaClient sharedInstance] setMqttApiSecure:NO];
    
    waitUntil(^(DoneCallback done) {
        [[WiaClient sharedInstance] generateAccessToken:
         @{
           @"username": [[[NSProcessInfo processInfo] environment] objectForKey:@"WIA_TEST_USERNAME"],
           @"password": [[[NSProcessInfo processInfo] environment] objectForKey:@"WIA_TEST_PASSWORD"],
           @"scope": @"user",
           @"grantType": @"password"
           } success:^(WiaAccessToken * _Nullable accessToken) {
               XCTAssertNotNil(accessToken);
               userAccessToken = accessToken.accessToken;
               done();
           } failure:^(NSError * _Nullable error) {
               XCTAssertNil(error);
           }];
    });
});

beforeEach(^{
    [[WiaClient sharedInstance] setSecretKey:userAccessToken];
});

describe(@"devices", ^{
    it(@"create device", ^{
        waitUntil(^(DoneCallback done) {
            [[WiaClient sharedInstance] createDevice:
                @{
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
            [[WiaClient sharedInstance] createDevice:
                @{
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
                      } success:^(WiaDevice * _Nullable retrievedDevice) {
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
                    success:^(BOOL deleted) {
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
           [[WiaClient sharedInstance] listDevices:@{}
            success:^(NSArray * _Nullable devices, NSNumber * _Nullable count) {
               XCTAssertNotNil(devices);
               NSLog(@"%@", devices);
               done();
            } failure:^(NSError * _Nullable error) {
                XCTAssertNil(error);
            }];
        });
    });
    
    it(@"retrieve device api keys", ^{
        waitUntil(^(DoneCallback done) {
            [[WiaClient sharedInstance] createDevice:
             @{
               @"name": @"testDevice"
               } success:^(WiaDevice * _Nullable createdDevice) {
                   XCTAssertNotNil(createdDevice);
                   [[WiaClient sharedInstance] retrieveDeviceApiKeys:createdDevice.id
                                                      success:^(WiaDeviceApiKeys * _Nullable apiKeys) {
                                                          XCTAssertNotNil(apiKeys);
                                                          XCTAssertNotNil(apiKeys.publicKey);
                                                          XCTAssertNotNil(apiKeys.secretKey);
                                                          done();
                                                      } failure:^(NSError * _Nullable error) {
                                                          XCTAssertNil(error);
                                                      }];
               } failure:^(NSError * _Nullable error) {
                   XCTAssertNil(error);
               }];
        });
    });
});

describe(@"mqtt", ^{
    beforeEach(^{
        waitUntil(^(DoneCallback done) {
            [[WiaClient sharedInstance] disconnectFromStream];
            done();
        });
    });
    
    it(@"connect to stream", ^{
        waitUntil(^(DoneCallback done) {
            [[NSNotificationCenter defaultCenter] addObserverForName:@"WiaStreamConnect" object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
                done();
            }];
            [[WiaClient sharedInstance] connectToStream];
        });
    });
    
    it(@"connect and disconnect to stream", ^{
        waitUntil(^(DoneCallback done) {
            [[NSNotificationCenter defaultCenter] addObserverForName:@"WiaStreamConnect" object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
                [[WiaClient sharedInstance] disconnectFromStream];
            }];
            [[NSNotificationCenter defaultCenter] addObserverForName:@"WiaStreamDisconnect" object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
                done();
            }];
            [[WiaClient sharedInstance] connectToStream];
        });
    });
});

describe(@"events", ^{
    it(@"creates event (via rest)", ^{
        waitUntil(^(DoneCallback done) {
            [[WiaClient sharedInstance] createDevice:
             @{
               @"name": @"testDevice"
               } success:^(WiaDevice * _Nullable createdDevice) {
                   XCTAssertNotNil(createdDevice);
                   [[WiaClient sharedInstance] retrieveDeviceApiKeys:createdDevice.id
                                                             success:^(WiaDeviceApiKeys * _Nullable apiKeys) {
                                                                 XCTAssertNotNil(apiKeys);
                                                                 XCTAssertNotNil(apiKeys.publicKey);
                                                                 XCTAssertNotNil(apiKeys.secretKey);
                                                                 
                                                                 [[WiaClient sharedInstance] setSecretKey:apiKeys.secretKey];
                                                                 [[WiaClient sharedInstance] publishEvent:@{
                                                                                                           @"name": @"testEvent"
                                                                                                           } success:^(WiaEvent * _Nullable event) {
                                                                                                               done();
                                                                                                           } failure:^(NSError * _Nullable error) {
                                                                                                               XCTAssertNil(error);
                                                                                                           }];
                                                             } failure:^(NSError * _Nullable error) {
                                                                 XCTAssertNil(error);
                                                             }];
               } failure:^(NSError * _Nullable error) {
                   XCTAssertNil(error);
               }];
        });
    });
    
    it(@"creates event (via mqtt)", ^{
        waitUntil(^(DoneCallback done) {
            [[WiaClient sharedInstance] createDevice:
             @{
               @"name": @"testDevice"
               } success:^(WiaDevice * _Nullable createdDevice) {
                   XCTAssertNotNil(createdDevice);
                   [[WiaClient sharedInstance]
                        retrieveDeviceApiKeys:createdDevice.id
                         success:^(WiaDeviceApiKeys * _Nullable apiKeys) {
                             XCTAssertNotNil(apiKeys);
                             XCTAssertNotNil(apiKeys.publicKey);
                             XCTAssertNotNil(apiKeys.secretKey);
                             NSLog(@"Using device key %@", apiKeys.secretKey);
                             [[WiaClient sharedInstance] setSecretKey:apiKeys.secretKey];
                             [[NSNotificationCenter defaultCenter] addObserverForName:@"WiaStreamConnect" object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
                                 
                                 double delayInSeconds = 6.0;
                                 dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
                                 dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                                     [[WiaClient sharedInstance] publishEvent:@{
                                                                                @"name": @"testEvent"
                                                                                } success:^(WiaEvent * _Nullable event) {
                                                                                    done();
                                                                                } failure:^(NSError * _Nullable error) {
                                                                                    XCTAssertNil(error);
                                                                                }];
                                 });

                             }];
                             [[WiaClient sharedInstance] connectToStream];
                         } failure:^(NSError * _Nullable error) {
                             XCTAssertNil(error);
                         }];
               } failure:^(NSError * _Nullable error) {
                   XCTAssertNil(error);
               }];
        });
    });

    it(@"lists events", ^{
        waitUntil(^(DoneCallback done) {
            [[WiaClient sharedInstance] createDevice:@{@"name": @"testDevice"}
                 success:^(WiaDevice * _Nullable device) {
                     XCTAssertNotNil(device);

                     [[WiaClient sharedInstance] listEvents:@{
                            @"device": device.id
                        } success:^(NSArray * _Nullable events, NSNumber * _Nullable count) {
                            XCTAssertNotNil(events);
                            XCTAssertNotNil(count);
                            done();
                        } failure:^(NSError * _Nullable error) {
                            XCTAssertNil(error);
                        }];
                 } failure:^(NSError * _Nullable error) {
                     XCTAssertNil(error);
                 }];
        });
    });
});

describe(@"logs", ^{
    it(@"lists logs", ^{
        waitUntil(^(DoneCallback done) {
            [[WiaClient sharedInstance] createDevice:
              @{
                  @"name": @"testDevice"
              } success:^(WiaDevice * _Nullable device) {
                 XCTAssertNotNil(device);
                 
                 [[WiaClient sharedInstance] listLogs:
                    @{
                        @"device": device.id
                      } success:^(NSArray * _Nullable logs, NSNumber * _Nullable count) {
                          XCTAssertNotNil(logs);
                          XCTAssertNotNil(count);
                          done();
                      } failure:^(NSError * _Nullable error) {
                          XCTAssertNil(error);
                      }];
             } failure:^(NSError * _Nullable error) {
                 XCTAssertNil(error);
             }];
        });
    });
});

describe(@"locations", ^{
    it(@"lists locations", ^{
        waitUntil(^(DoneCallback done) {
            [[WiaClient sharedInstance] createDevice:
             @{
               @"name": @"testDevice"
               } success:^(WiaDevice * _Nullable device) {
                   XCTAssertNotNil(device);
                   
                   [[WiaClient sharedInstance] listLocations:
                    @{
                      @"device": device.id
                      } success:^(NSArray * _Nullable locations, NSNumber * _Nullable count) {
                          XCTAssertNotNil(locations);
                          XCTAssertNotNil(count);
                          done();
                      } failure:^(NSError * _Nullable error) {
                          XCTAssertNil(error);
                      }];
               } failure:^(NSError * _Nullable error) {
                   XCTAssertNil(error);
               }];
        });
    });
});

describe(@"sensors", ^{
    it(@"lists sensors", ^{
        waitUntil(^(DoneCallback done) {
            [[WiaClient sharedInstance] createDevice:
             @{
               @"name": @"testDevice"
               } success:^(WiaDevice * _Nullable device) {
                   XCTAssertNotNil(device);
                   
                   [[WiaClient sharedInstance] listSensors:
                    @{
                      @"device": device.id
                      } success:^(NSArray * _Nullable sensors, NSNumber * _Nullable count) {
                          XCTAssertNotNil(sensors);
                          XCTAssertNotNil(count);
                          done();
                      } failure:^(NSError * _Nullable error) {
                          XCTAssertNil(error);
                      }];
               } failure:^(NSError * _Nullable error) {
                   XCTAssertNil(error);
               }];
        });
    });
});

describe(@"functions", ^{
    it(@"lists functions", ^{
        waitUntil(^(DoneCallback done) {
            [[WiaClient sharedInstance] createDevice:
             @{
               @"name": @"testDevice"
               } success:^(WiaDevice * _Nullable device) {
                   XCTAssertNotNil(device);
                   
                   [[WiaClient sharedInstance] listFunctions:
                    @{
                      @"device": device.id
                      } success:^(NSArray * _Nullable locations, NSNumber * _Nullable count) {
                          XCTAssertNotNil(locations);
                          XCTAssertNotNil(count);
                          done();
                      } failure:^(NSError * _Nullable error) {
                          XCTAssertNil(error);
                      }];
               } failure:^(NSError * _Nullable error) {
                   XCTAssertNil(error);
               }];
        });
    });
});


SpecEnd
