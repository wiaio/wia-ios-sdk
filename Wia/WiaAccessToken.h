//
//  WiaAccessToken.h
//  Pods
//
//  Created by Conall Laverty on 07/12/2015.
//
//

#import <Foundation/Foundation.h>

@interface WiaAccessToken : NSObject

@property (nonatomic, copy, nullable) NSString *accessToken;
@property (nonatomic, copy, nullable) NSString *refreshToken;
@property (nonatomic, copy, nullable) NSString *tokenType;
@property (nonatomic, copy, nullable) NSNumber *expiresIn;
@property (nonatomic, copy, nullable) NSString *scope;

- (nonnull instancetype)initWithDictionary:(nonnull NSDictionary *)dict;

@end
