//
//  WiaViewController.m
//  Wia
//
//  Created by Conall Laverty on 09/22/2015.
//  Copyright (c) 2015 Conall Laverty. All rights reserved.
//

#import "WiaViewController.h"

@interface WiaViewController () <WiaClientDelegate>

@end

@implementation WiaViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [WiaClient debug:YES];
//    
//    [[WiaClient sharedInstance] initWithApplicationKey:@""];
    
//
    [[WiaClient sharedInstance] setDelegate:self];
//
//    [[WiaClient sharedInstance] setSecretKey:@"secret_key"];
//
    [[NSNotificationCenter defaultCenter] addObserverForName:@"WiaStreamConnect" object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
        NSLog(@"WiaStreamConnect");
//        [NSTimer scheduledTimerWithTimeInterval:1.0
//                                         target:self
//                                       selector:@selector(onTick:)
//                                       userInfo:nil
//                                        repeats:YES];
        [[WiaClient sharedInstance] listDevices:@{} success:^(NSArray * _Nullable devices, NSNumber * _Nullable count) {
            NSLog(@"%@", devices);
            NSLog(@"%@", count);
            if (devices && [devices count] > 0) {
                WiaDevice *device = devices[0];
                NSLog(@"Subscribing to device: %@", device.id);
                [[WiaClient sharedInstance] subscribeToEvents:@{
                                                               @"device": device.id
                                                               }];
            }
        } failure:^(NSError * _Nullable error) {
            NSLog(@"%@", error);
        }];
    }];

    [[NSNotificationCenter defaultCenter] addObserverForName:@"WiaStreamConnectionClose" object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
        NSLog(@"WiaStreamConnectionClose");
    }];

    [[WiaClient sharedInstance] connectToStream];
}

-(void)onTick:(NSTimer*)timer
{
    [[WiaClient sharedInstance] publishEvent:@{
                                               @"name": @"temperature",
                                               @"data": @(21.5)
                                               } success:nil failure:nil];
    
    [[WiaClient sharedInstance] publishEvent:@{
                                               @"name": @"gyro",
                                               @"data": @{
                                                       @"x": @(123),
                                                       @"y": @"stringtest"
                                                       }
                                               } success:nil failure:nil];
}

-(void)newEvent:(WiaEvent *)event {
    NSLog(@"Got a new event");
    NSLog(@"%@", event.data);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
