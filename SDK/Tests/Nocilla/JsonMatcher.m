//
//  JsonMatcher.m
//  SDK
//
//  Created by Sergio Gutiérrez on 25/05/2017.
//  Copyright © 2017 flowup. All rights reserved.
//

#import "JsonMatcher.h"

@interface JsonMatcher ()

@property (readonly, nonatomic) NSDictionary *jsonObject;

@end

@implementation JsonMatcher

- (instancetype)initWithJsonObject:(NSDictionary *)jsonObject
{
    self = [super init];
    if (self) {
        _jsonObject = jsonObject;
    }
    return self;
}

- (BOOL)matchesData:(NSData *)data
{
    NSDictionary *inData = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    return [inData isEqual:self.jsonObject];
}


- (LSMatcher *)matcher
{
    return self;
}

@end
