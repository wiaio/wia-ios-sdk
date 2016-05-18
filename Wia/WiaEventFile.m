//
//  WiaEventFile.m
//  Pods
//
//  Created by Conall Laverty on 18/05/2016.
//
//

#import "WiaEventFile.h"

@implementation WiaEventFile

@synthesize id, url, metadata, encoding, mimetype;

- (instancetype)initWithDictionary:(NSDictionary *)dict {
    self = [super init];
    if (self) {
        self.id = [dict objectForKey:@"id"];
        self.url = [dict objectForKey:@"url"];
//        self.metadata = [dict objectForKey:@"metadata"];
        self.encoding = [dict objectForKey:@"encoding"];
        self.mimetype = [dict objectForKey:@"mimetype"];

    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone
{
    id copy = [[[self class] alloc] init];
    
    if (copy) {
        [copy setId:self.id];
        [copy setUrl:self.url];
        [copy setMetadata:self.metadata];
        [copy setEncoding:self.encoding];
        [copy setMimetype:self.mimetype];
    }
    
    return copy;
}

@end