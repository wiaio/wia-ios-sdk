//
//  WiaClient.h
//  Wia
//
//  Created by Conall Laverty on 22/09/2015.
//
//

#import <Foundation/Foundation.h>

@interface WiaClient : NSObject

@property (nonatomic, copy, nullable) NSString *clientToken;

@property (nonatomic, readwrite, nullable) NSURL *restApiURL;
@property (nonatomic, readwrite, nullable) NSURL *mqttApiURL;

- (nonnull instancetype)initWithToken:(nonnull NSString *)token NS_DESIGNATED_INITIALIZER;

@end