//
//  WiaViewController.m
//  Wia
//
//  Created by Conall Laverty on 09/22/2015.
//  Copyright (c) 2015 Conall Laverty. All rights reserved.
//

#import "WiaViewController.h"
#import "Wia.h"

@interface WiaViewController () <WiaClientDelegate>

@end

@implementation WiaViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    [WiaClient debug:true];
}

-(void)connectedToStream {
    NSLog(@"Connected to stream.");
}

-(void)disconnectedFromStream:(NSError *)error {
    NSLog(@"Disconnected from stream.");
}

-(void)newEvent:(WiaEvent *)event {
    NSLog(@"%@", event.name);
    NSLog(@"%@", event.deviceKey);
    NSLog(@"%@", event.eventData);
    NSLog(@"%@", event.timestamp);
}

-(void)newLog:(WiaLog *)log {
    NSLog(@"%@", log.level);
    NSLog(@"%@", log.message);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
