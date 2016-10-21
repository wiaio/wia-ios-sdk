//
//  WiaDevice.h
//  Wia
//
//  Created by Conall Laverty on 22/09/2015.
//
//

#import <Foundation/Foundation.h>
#import "WiaLocation.h"

@interface WiaDevice : NSObject

@property (nonatomic, copy, nullable) NSString *id;
@property (nonatomic, copy, nullable) NSString *name;
@property (nonatomic) BOOL isOnline;
@property (nonatomic, copy, nullable) NSDate *createdAt;
@property (nonatomic, copy, nullable) NSDate *updatedAt;
@property (nonatomic, copy, nullable) NSDictionary *events;
@property (nonatomic, copy, nullable) NSDictionary *sensors;
@property (nonatomic, copy, nullable) WiaLocation *location;
@property (nonatomic) BOOL public;

- (nonnull instancetype)initWithDictionary:(nonnull NSDictionary *)dict;

@end
