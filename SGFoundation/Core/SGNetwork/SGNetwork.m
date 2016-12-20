//
//  SGNetwork.m
//  opera
//
//  Created by Single on 16/6/8.
//  Copyright © 2016年 HL. All rights reserved.
//

#import "SGNetwork.h"
#import <AFNetworking/AFNetworking.h>
#import "SGRequest.h"

NSString * const SGNetworkReachabilityStatusDidChangeName = @"SGNetworkReachabilityStatusDidChangeName";

@interface SGNetwork ()

@property (nonatomic, strong) AFHTTPSessionManager * sessionManager;
@property (nonatomic, assign) SGNetworkReachabilityStatus reachabilityStatus;

@property (nonatomic, copy) NSString * offsetKey;
@property (nonatomic, copy) NSString * sizeKey;

@end

@implementation SGNetwork

static SGNetwork * network = nil;
static NSURLSessionConfiguration * sessionConfiguration = nil;

+ (SGNetwork *)shareInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        network = [[self alloc] init];
    });
    return network;
}

+ (void)setSessionConfiguration:(NSURLSessionConfiguration *)config
{
    sessionConfiguration = config;
}

- (instancetype)init
{
    if (self = [super init])
    {
        self.sessionManager = [[AFHTTPSessionManager alloc] initWithSessionConfiguration:sessionConfiguration];
        self.sessionManager.operationQueue.maxConcurrentOperationCount = 4;
        self.sessionManager.responseSerializer = [AFJSONResponseSerializer serializer];
        self.sessionManager.requestSerializer = [AFHTTPRequestSerializer serializer];
        
        self.offsetKey = @"offset";
        self.sizeKey = @"size";
    }
    return self;
}

- (void)startNetworkListener
{
    // 网络状态改变
    [[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        self.reachabilityStatus = (SGNetworkReachabilityStatus)status;
        if ([NSThread isMainThread]) {
            [[NSNotificationCenter defaultCenter] postNotificationName:SGNetworkReachabilityStatusDidChangeName object:self];
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter] postNotificationName:SGNetworkReachabilityStatusDidChangeName object:self];
            });
        }
    }];
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
}

- (void)addRequest:(SGRequest *)request
{
    // 设置超时
    NSTimeInterval timeout = request.timeoutInterval;
    self.sessionManager.requestSerializer.timeoutInterval = timeout;
    
    // 发送请求
    NSString * requestUrl = [self combinRequestUrl:request];
    NSDictionary * parameters = [request parameters];
    
    // 分页信息
    SGOffset * offset = request.offset;
    if (offset != nil)
    {
        if (![parameters isKindOfClass:[NSDictionary class]] || parameters == nil) {
            NSMutableDictionary * temp = [NSMutableDictionary dictionaryWithDictionary:parameters];
            SGOffsetParams par = offset.offsetParams;
            [temp setObject:[NSString stringWithFormat:@"%ld", (long)par.offset] forKey:self.offsetKey];
            [temp setObject:[NSString stringWithFormat:@"%ld", (long)par.size] forKey:self.sizeKey];
            parameters = temp;
        }
    }
    
    SGRequestMethod method = request.method;
    switch (method)
    {
        case SGRequestMethodGet:
        {
            request.task = [self.sessionManager GET:requestUrl parameters:parameters progress:nil success:^(NSURLSessionDataTask * task, id responseObject) {
                [self handleSuccessRequest:request responseData:responseObject];
            } failure:^(NSURLSessionDataTask * task, NSError * error) {
                [self handelFailureRequest:request error:error];
            }];
        }
            break;
        case SGRequestMethodPost:
        {
            SGPostFormDataBlock formDataBlock = request.postFormDataBlock;
            if (formDataBlock != nil) {
                request.task = [self.sessionManager POST:requestUrl parameters:parameters constructingBodyWithBlock:formDataBlock progress:nil success:^(NSURLSessionDataTask * task, id responseObject) {
                    [self handleSuccessRequest:request responseData:responseObject];
                } failure:^(NSURLSessionDataTask * task, NSError * error) {
                    [self handelFailureRequest:request error:error];
                }];
            } else {
                request.task = [self.sessionManager POST:requestUrl parameters:parameters progress:nil success:^(NSURLSessionDataTask * task, id responseObject) {
                    [self handleSuccessRequest:request responseData:responseObject];
                } failure:^(NSURLSessionDataTask * task, NSError * error) {
                    [self handelFailureRequest:request error:error];
                }];
            }
        }
            break;
    }
}

- (void)cancelRequest:(SGRequest *)request
{
    [request.task cancel];
    [request clearHandler];
}

- (void)handleSuccessRequest:(SGRequest *)request responseData:(id)responseObject
{
    request.originalResponseObject = responseObject;
    NSError * error = [request checkErrorFromOriginalResponseObject:responseObject];
    if (error) {
        [self handelFailureRequest:request error:error];
        return;
    }
    
    request.pretreatmentResponseObject = [request pretreatmentResponseObjectFromOriginalResponseObject:responseObject];
    
    if (request.successHandler) {
        request.successHandler(request);
    }
    
    if (request.completionHandler) {
        request.completionHandler(request);
    }
    
    [request clearHandler];
}

- (void)handelFailureRequest:(SGRequest *)request error:(NSError *)error
{
    request.error = error;
    
    if (request.failureHandler) {
        request.failureHandler(request);
    }
    
    if (request.completionHandler) {
        request.completionHandler(request);
    }
    
    [request clearHandler];
}

- (void)setValuesForHTTPRequestHeaders:(NSDictionary<NSString *,NSString *> *)HTTPRequestHeaders
{
    [HTTPRequestHeaders enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, NSString * _Nonnull obj, BOOL * _Nonnull stop) {
        [self setValue:obj forHTTPHeaderField:key];
    }];
}

- (void)setValue:(NSString *)value forHTTPHeaderField:(NSString *)field
{
    [self.sessionManager.requestSerializer setValue:value forHTTPHeaderField:field];
}

- (void)removeVauleForHTTPHeaderField:(NSString *)field
{
    [self.sessionManager.requestSerializer setValue:nil forHTTPHeaderField:field];
}

- (void)setOffsetKey:(NSString *)offsetKey sizeKey:(NSString *)sizeKey
{
    self.offsetKey = offsetKey;
    self.sizeKey = sizeKey;
}

#pragma mark - tools

- (NSString *)combinRequestUrl:(SGRequest *)request
{
    NSString * detailUrl = request.requestURLString;
    if ([detailUrl hasPrefix:@"http"]) return detailUrl;
    
    NSString * baseUrl = request.baseURLString;
    if (baseUrl.length <= 0) baseUrl = self.baseURLString;
    return [NSURL URLWithString:detailUrl relativeToURL:[NSURL URLWithString:baseUrl]].absoluteString;
}

@end
