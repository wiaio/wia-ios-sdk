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
    
    [[WiaClient sharedInstance] init];
    
    [[WiaClient sharedInstance] setDelegate:self];

    [[WiaClient sharedInstance] setSecretKey:@"u_QgwlFi7J5wzb27t5KsLZcMocqlgi1Dlb"];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:@"WiaStreamConnected" object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
        NSLog(@"WiaStreamConnected");
        [[WiaClient sharedInstance] subscribeToEvents:@{
                                                    @"device": @"deviceKey"
                                                    }];
    }];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:@"WiaStreamConnectionClose" object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
        NSLog(@"WiaStreamConnectionClose");
    }];
    
    [[WiaClient sharedInstance] connectToStream];
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
