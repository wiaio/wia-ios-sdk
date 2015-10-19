//
//  WiaUser.h
//  Wia
//
//  Created by Conall Laverty on 22/09/2015.
//
//

#import <Foundation/Foundation.h>

@interface WiaUser : NSObject

@property (nonatomic, copy, nullable) NSString *userkey;
@property (nonatomic, copy, nullable) NSString *username;
@property (nonatomic, copy, nullable) NSString *fullName;
@property (nonatomic, copy, nullable) NSString *email;
@property (nonatomic, copy, nullable) NSDate *createdAt;
@property (nonatomic, copy, nullable) NSDate *updatedat;

@end