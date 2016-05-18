//
//  WiaLocation.h
//  Pods
//
//  Created by Conall Laverty on 18/05/2016.
//
//

#import <Foundation/Foundation.h>

@interface WiaLocation : NSObject

@property (nonatomic, copy, nullable) NSString *id;
@property (nonatomic, copy, nullable) NSString *device;
@property (nonatomic, copy, nullable) NSNumber *latitude;
@property (nonatomic, copy, nullable) NSNumber *longitude;
@property (nonatomic, copy, nullable) NSNumber *altitude;
@property (nonatomic, copy, nullable) NSDate *timestamp;

- (nonnull instancetype)initWithDictionary:(nonnull NSDictionary *)dict;

@end
