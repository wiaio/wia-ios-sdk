//
//  WiaEventFile.h
//  Pods
//
//  Created by Conall Laverty on 18/05/2016.
//
//

#import <Foundation/Foundation.h>

@interface WiaEventFile : NSObject

@property (nonatomic, copy, nullable) NSString *id;
@property (nonatomic, copy, nullable) NSString *url;
@property (nonatomic, copy, nullable) NSDictionary *metadata;
@property (nonatomic, copy, nullable) NSString *encoding;
@property (nonatomic, copy, nullable) NSString *mimetype;

- (nonnull instancetype)initWithDictionary:(nonnull NSDictionary *)dict;

@end
