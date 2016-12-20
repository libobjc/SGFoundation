//
//  SGNetwork.h
//  opera
//
//  Created by Single on 16/6/8.
//  Copyright © 2016年 HL. All rights reserved.
//

#import <Foundation/Foundation.h>
@class SGRequest;

FOUNDATION_EXTERN NSString * const SGNetworkReachabilityStatusDidChangeName;

typedef NS_ENUM(NSInteger, SGNetworkReachabilityStatus) {
    SGNetworkReachabilityStatusUnknown          = -1,
    SGNetworkReachabilityStatusNotReachable     = 0,
    SGNetworkReachabilityStatusReachableViaWWAN = 1,
    SGNetworkReachabilityStatusReachableViaWiFi = 2,
};

@interface SGNetwork : NSObject

+ (SGNetwork *)shareInstance;
+ (void)setSessionConfiguration:(NSURLSessionConfiguration *)sessionConfiguration;

- (void)startNetworkListener;

@property (nonatomic, copy) NSString * baseURLString;
@property (nonatomic, assign, readonly) SGNetworkReachabilityStatus reachabilityStatus;
@property (nonatomic, copy, readonly) NSDictionary <NSString *, NSString *> * HTTPRequestHeaders;

// HTTP request header
- (void)setValuesForHTTPRequestHeaders:(NSDictionary <NSString *, NSString *> *)HTTPRequestHeaders;
- (void)setValue:(NSString *)value forHTTPHeaderField:(NSString *)field;
- (void)removeVauleForHTTPHeaderField:(NSString *)field;

// request control
- (void)addRequest:(SGRequest *)request;
- (void)cancelRequest:(SGRequest *)request;

// request config
- (void)setOffsetKey:(NSString *)offsetKey sizeKey:(NSString *)sizeKey;     // default is 'offset' and 'size'

+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;

@end
