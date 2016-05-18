//
//  WiaDeviceApiKeys.h
//  Pods
//
//  Created by Conall Laverty on 18/05/2016.
//
//

#import <Foundation/Foundation.h>

@interface WiaDeviceApiKeys : NSObject

@property (nonatomic, copy, nullable) NSString *publicKey;
@property (nonatomic, copy, nullable) NSString *secretKey;

- (nonnull instancetype)initWithDictionary:(nonnull NSDictionary *)dict;

@end
