//
//  SGResponse.h
//  opera
//
//  Created by Single on 16/6/8.
//  Copyright © 2016年 HL. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SGResponse : NSObject

+ (instancetype)responseWithOriginalResponseObject:(id)originalResponseObject;

@property (nonatomic, strong) id originalResponseObject;

@end
