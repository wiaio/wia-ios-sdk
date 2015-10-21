//
//  WiaUserToken.h
//  Pods
//
//  Created by Conall Laverty on 21/10/2015.
//
//

#import <Foundation/Foundation.h>

@interface WiaUserToken : NSObject

@property (nonatomic, copy, nullable) NSString *accessToken;
@property (nonatomic, copy, nullable) NSString *tokenType;

- (nonnull instancetype)initWithDictionary:(nonnull NSDictionary *)dict;

@end
