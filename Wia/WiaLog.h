//
//  WiaLog.h
//  Pods
//
//  Created by Conall Laverty on 17/12/2015.
//
//

#import <Foundation/Foundation.h>

@interface WiaLog : NSObject

@property (nonatomic, copy, nullable) NSString *logId;
@property (nonatomic, copy, nullable) NSString *deviceKey;
@property (nonatomic, copy, nullable) NSString *level;
@property (nonatomic, copy, nullable) NSString *message;
@property (nonatomic, copy, nullable) NSObject *logData;
@property (nonatomic, copy, nullable) NSDate *timestamp;

- (nonnull instancetype)initWithDictionary:(nonnull NSDictionary *)dict;

@end
