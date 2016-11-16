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

@end

@implementation SGNetwork

+ (SGNetwork *)shareInstance
{
    static SGNetwork * network = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        network = [[self alloc] init];
    });
    return network;
}

- (instancetype)init
{
    if (self = [super init])
    {
        self.sessionManager = [AFHTTPSessionManager manager];
        self.sessionManager.operationQueue.maxConcurrentOperationCount = 4;
        self.sessionManager.responseSerializer = [AFHTTPResponseSerializer serializer];
        self.sessionManager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/html", @"application/json", nil];
        self.sessionManager.requestSerializer = [AFHTTPRequestSerializer serializer];
        
        [self setupNetworkListener];
    }
    return self;
}

- (void)setupNetworkListener
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
            [temp setObject:[NSString stringWithFormat:@"%ld", par.offset] forKey:@"offset"];
            [temp setObject:[NSString stringWithFormat:@"%ld", par.size] forKey:@"size"];
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
    request.response = [SGResponse responseWithOriginalResponseObject:responseObject];
    NSError * error;
    [request checkResponseError:&error];
    if (error) {
        [self handelFailureRequest:request error:error];
        return;
    }
    
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

#pragma mark
#pragma mark - 工具方法

- (NSString *)combinRequestUrl:(SGRequest *)request
{
    NSString * detailUrl = request.requestURLString;
    if ([detailUrl hasPrefix:@"http"]) return detailUrl;
    
    NSString * baseUrl = request.baseURLString;
    if (baseUrl.length <= 0) baseUrl = self.baseURLString;
    return [NSURL URLWithString:detailUrl relativeToURL:[NSURL URLWithString:baseUrl]].absoluteString;
}

- (NSString*)encodeString:(NSString*)unencodedString
{
    NSString *encodedString = (NSString *)
    CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                              (CFStringRef)unencodedString,
                                                              NULL,
                                                              (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                              kCFStringEncodingUTF8));
    return encodedString;
}

@end
