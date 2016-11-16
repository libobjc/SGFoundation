//
//  NSString+SGEncode.h
//  SGFoundation
//
//  Created by Single on 2016/11/16.
//  Copyright © 2016年 single. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (SGEncode)

- (NSString *)sg_md5;
- (NSString *)sg_base64;
- (NSString*)sg_URLEncode;

@end
