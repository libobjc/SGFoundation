//
//  SGResponse.m
//  opera
//
//  Created by Single on 16/6/8.
//  Copyright © 2016年 HL. All rights reserved.
//

#import "SGResponse.h"

@implementation SGResponse

+ (instancetype)responseWithOriginalResponseObject:(id)originalResponseObject
{
    return [[self alloc] initWithOriginalResponseObject:originalResponseObject];
}

- (instancetype)initWithOriginalResponseObject:(id)originalResponseObject
{
    if (self = [super init]) {
        self.originalResponseObject = originalResponseObject;
    }
    return self;
}

@end
