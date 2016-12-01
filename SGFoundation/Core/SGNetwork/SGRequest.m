//
//  SGRequest.m
//  opera
//
//  Created by Single on 16/6/8.
//  Copyright © 2016年 HL. All rights reserved.
//

#import "SGRequest.h"
#import "SGNetwork.h"

@implementation SGRequest

+ (instancetype)api
{
    return [[self alloc] init];
}

- (instancetype)init
{
    if (self = [super init]) {
        NSLog(@"SGRequest %@ create", NSStringFromClass([self class]));
    }
    return self;
}

- (NSTimeInterval)timeoutInterval
{
    if (!_timeoutInterval) return 10;
    return _timeoutInterval;
}

- (void)setPretreatmentResponseObject:(id)pretreatmentResponseObject
{
    if (_pretreatmentResponseObject != pretreatmentResponseObject) {
        _pretreatmentResponseObject = pretreatmentResponseObject;
        if ([self responseObjectClass] == nil) return;
        if ([pretreatmentResponseObject isKindOfClass:[NSArray class]]) {
            if ([pretreatmentResponseObject count] <= 0) return;
            self.responseObject = [self objectArrayWithKeyValuesArray:pretreatmentResponseObject objectClass:self.responseObjectClass];
        } else {
            self.responseObject = [self objectWithKeyValues:pretreatmentResponseObject objectClass:self.responseObjectClass];
        }
    }
}

- (void)start
{
    [[SGNetwork shareInstance] addRequest:self];
}

- (void)stop
{
    [[SGNetwork shareInstance] cancelRequest:self];
}

- (void)startWithCompletionHandler:(SGRequestHandler)completionHandler
{
    [self startWithSuccessHandler:nil failureHandler:nil completionHandler:completionHandler];
}

- (void)startWithSuccessHandler:(SGRequestHandler)successHandler failureHandler:(SGRequestHandler)failureHandler
{
    [self startWithSuccessHandler:successHandler failureHandler:failureHandler completionHandler:nil];
}

- (void)startWithSuccessHandler:(SGRequestHandler)successHandler failureHandler:(SGRequestHandler)failureHandler completionHandler:(SGRequestHandler)completionHandler
{
    self.successHandler = successHandler;
    self.failureHandler = failureHandler;
    self.completionHandler = completionHandler;
    [self start];
}

- (void)clearHandler
{
    self.completionHandler = nil;
    self.successHandler = nil;
    self.failureHandler = nil;
}

- (NSError *)checkErrorFromOriginalResponseObject:(id)originalResponseObject
{
    return nil;
}

- (id)pretreatmentResponseObjectFromOriginalResponseObject:(id)originalResponseObject
{
    return originalResponseObject;
}

- (id)objectWithKeyValues:(NSDictionary *)keyValues objectClass:(Class)objectClass
{
    return keyValues;
}

- (NSArray *)objectArrayWithKeyValuesArray:(NSArray<NSDictionary *> *)keyValuesArray objectClass:(Class)objectClass
{
    return keyValuesArray;
}

- (void)dealloc
{
    NSLog(@"SGRequest %@ release", NSStringFromClass([self class]));
}

@end
