//
//  WiaLog.h
//  Pods
//
//  Created by Conall Laverty on 17/05/2016.
//
//

#import <Foundation/Foundation.h>

@interface WiaLog : NSObject

@property (nonatomic, copy, nullable) NSString *id;
@property (nonatomic, copy, nullable) NSString *device;
@property (nonatomic, copy, nullable) NSString *level;
@property (nonatomic, copy, nullable) NSString *message;
@property (nonatomic, copy, nullable) NSObject *data;
@property (nonatomic, copy, nullable) NSDate *timestamp;

- (nonnull instancetype)initWithDictionary:(nonnull NSDictionary *)dict;

@end