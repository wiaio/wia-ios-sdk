//
//  WiaViewController.m
//  Wia
//
//  Created by Conall Laverty on 09/22/2015.
//  Copyright (c) 2015 Conall Laverty. All rights reserved.
//

#import "WiaViewController.h"
#import "Wia.h"

@interface WiaViewController ()

@end

@implementation WiaViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

//    WiaUserClient *userClient = [[WiaUserClient alloc] initWithToken:@"userToken"];
//    [userClient getUserMe:^(WiaUser *user) {
//        NSLog(@"%@", user);
//    } failure:^(NSError *error) {
//        NSLog(@"%@", [error localizedDescription]);
//    }];
    
    WiaUserClient *userClient = [[WiaUserClient sharedInstance] initWithToken:@"u_serToken"];
    [userClient getUserMe:^(WiaUser *user) {
        NSLog(@"%@", user);
    } failure:^(NSError *error) {
        NSLog(@"%@", [error localizedDescription]);
    }];
    
    [[WiaUserClient sharedInstance] listDevices:^(NSArray *devices) {
        NSLog(@"%@", devices);
    } failure:^(NSError *error) {
        NSLog(@"%@", [error localizedDescription]);
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
