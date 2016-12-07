//
//  SGRedirect.h
//  SGFoundation
//
//  Created by Single on 2016/10/12.
//  Copyright © 2016年 single. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SGRedirect : NSObject

+ (void)fetchLocationWithURL:(NSURL *)url completionHandler:(void(^)(BOOL success, NSString * location))completionHandler;

@end
