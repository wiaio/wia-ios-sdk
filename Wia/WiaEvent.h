//
//  WiaEvent.h
//  Wia
//
//  Created by Conall Laverty on 22/09/2015.
//
//

#import <Foundation/Foundation.h>
#import "WiaDevice.h"

@interface WiaEvent : NSObject

@property (nonatomic, copy, nullable) NSString *id;
@property (nonatomic, copy, nullable) NSString *device;
@property (nonatomic, copy, nullable) NSString *name;
@property (nonatomic, copy, nullable) NSObject *eventData;
@property (nonatomic, copy, nullable) NSDate *timestamp;

- (nonnull instancetype)initWithDictionary:(nonnull NSDictionary *)dict;

@end