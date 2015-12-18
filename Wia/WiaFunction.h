//
//  WiaFunction.h
//  Pods
//
//  Created by Conall Laverty on 19/10/2015.
//
//

#import <Foundation/Foundation.h>

@interface WiaFunction : NSObject

@property (nonatomic, copy, nullable) NSString *deviceKey;
@property (nonatomic, copy, nullable) NSString *name;
@property (nonatomic) BOOL isEnabled;
@property (nonatomic, copy, nullable) NSDate *enabledAt;
@property (nonatomic, copy, nullable) NSDate *createdAt;
@property (nonatomic, copy, nullable) NSDate *updatedAt;
@property (nonatomic, copy, nullable) NSMutableDictionary *data;

- (nonnull instancetype)initWithDictionary:(nonnull NSDictionary *)dict;

@end
