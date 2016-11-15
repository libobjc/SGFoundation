//
//  NSString+SGExtension.m
//  SGFoundation
//
//  Created by Single on 2016/11/15.
//  Copyright © 2016年 single. All rights reserved.
//

#import "NSString+SGExtension.h"

@implementation NSString (SGExtension)

- (NSArray <NSValue *> *)rangesOfString:(NSString *)string
{
    return [self rangesOfString:string baseLocation:0];
}

- (NSArray <NSValue *> *)rangesOfString:(NSString *)string baseLocation:(NSInteger)baseLocation
{
    if (!string) return nil;
    
    if ([self containsString:string])
    {
        NSRange range = [self rangeOfString:string];
        if (range.location != NSNotFound)
        {
            NSMutableArray <NSValue *> * values = [NSMutableArray array];
            
            NSString * subString = [self substringFromIndex:range.location + range.length];
            NSArray <NSValue *> * subValues = [subString rangesOfString:string baseLocation:baseLocation + range.location + range.length];
            
            [values addObject:[NSValue valueWithRange:NSMakeRange(baseLocation + range.location, range.length)]];
            [values addObjectsFromArray:subValues];
            
            return values;
        }
    }
    return nil;
}

@end
