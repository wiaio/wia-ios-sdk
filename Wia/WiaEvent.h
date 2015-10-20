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

@property (nonatomic, nullable) WiaDevice *device;
@property (nonatomic, copy, nullable) NSString *name;
@property (nonatomic, copy, nullable) NSDate *timestamp;
@property (nonatomic, copy, nullable) NSDictionary *eventData;

- (nonnull instancetype)initWithDictionary:(nonnull NSDictionary *)dict;

@end