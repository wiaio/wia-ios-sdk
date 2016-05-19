//
//  WiaSensor.h
//  Pods
//
//  Created by Conall Laverty on 19/05/2016.
//
//

#import <Foundation/Foundation.h>

@interface WiaSensor : NSObject

@property (nonatomic, copy, nullable) NSString *id;
@property (nonatomic, copy, nullable) NSString *device;
@property (nonatomic, copy, nullable) NSString *name;
@property (nonatomic, copy, nullable) NSObject *data;
@property (nonatomic, copy, nullable) NSDate *timestamp;

- (nonnull instancetype)initWithDictionary:(nonnull NSDictionary *)dict;

@end
