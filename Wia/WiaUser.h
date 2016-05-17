//
//  WiaUser.h
//  Wia
//
//  Created by Conall Laverty on 22/09/2015.
//
//

#import <Foundation/Foundation.h>

@interface WiaUser : NSObject

@property (nonatomic, copy, nullable) NSString *id;
@property (nonatomic, copy, nullable) NSString *username;
@property (nonatomic, copy, nullable) NSString *fullName;
@property (nonatomic, copy, nullable) NSString *firstName;
@property (nonatomic, copy, nullable) NSString *lastName;
@property (nonatomic, copy, nullable) NSDate *createdAt;
@property (nonatomic, copy, nullable) NSDate *updatedAt;

- (nonnull instancetype)initWithDictionary:(nonnull NSDictionary *)dict;

@end