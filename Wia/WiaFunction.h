//
//  WiaFunction.h
//  Pods
//
//  Created by Conall Laverty on 18/05/2016.
//
//

#import <Foundation/Foundation.h>

@interface WiaFunction : NSObject

@property (nonatomic, copy, nullable) NSString *id;
@property (nonatomic, copy, nullable) NSString *name;
@property (nonatomic, copy, nullable) NSString *device;
@property (nonatomic, copy, nullable) NSDate *createdAt;
@property (nonatomic, copy, nullable) NSDate *updatedAt;

- (nonnull instancetype)initWithDictionary:(nonnull NSDictionary *)dict;

@end
