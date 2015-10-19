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
    
    WiaUserClient *userClient = [[WiaUserClient alloc] initWithToken:@"u_OyzxQKgO4mfXBRdWQbVqMSsp3ZJm1M8p"];
    
    NSMutableDictionary *commandData = [[NSMutableDictionary alloc] init];
    [commandData setObject:@"Testthing" forKey:@"firstKey"];
    
    [userClient runCommand:@"zXwhxJjNK9Z6eu7749tXxq1u" commandName:@"helloCommand" commandData:commandData success:^(NSObject *obj) {
        NSLog(@"Command sent!");
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
