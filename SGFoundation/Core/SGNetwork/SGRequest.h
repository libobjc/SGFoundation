//
//  SGRequest.h
//  opera
//
//  Created by Single on 16/6/8.
//  Copyright © 2016年 HL. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AFNetworking/AFNetworking.h>
#import "SGOffset.h"

@class SGRequest;

typedef NS_ENUM(NSUInteger, SGRequestMethod) {
    SGRequestMethodGet = 0,
    SGRequestMethodPost,
};

typedef void (^SGRequestHandler)(SGRequest * request);
typedef void (^SGPostFormDataBlock)(id <AFMultipartFormData> formData); //  post data

@interface SGRequest : NSObject

+ (instancetype)api;

@property (nonatomic) NSInteger tag;
@property (nonatomic, strong) NSURLSessionDataTask * task;  // sessionTask
@property (nonatomic, strong) SGOffset * offset;            // page offset
@property (nonatomic, strong) id originalResponseObject;    // HTTPServer responseObject
@property (nonatomic, strong) id pretreatmentResponseObject;    // extract from originalResponseObject
@property (nonatomic, strong) id responseObject;    // obj -> model, value is model or model array
@property (nonatomic, assign) Class responseObjectClass;
@property (nonatomic, strong) NSError * error;

@property (nonatomic, copy) SGRequestHandler completionHandler;
@property (nonatomic, copy) SGRequestHandler successHandler;
@property (nonatomic, copy) SGRequestHandler failureHandler;

@property (nonatomic, copy) NSString * baseURLString;
@property (nonatomic, copy) NSString * requestURLString;
@property (nonatomic, copy) NSDictionary * parameters;
@property (nonatomic, assign) NSTimeInterval timeoutInterval;   // default is 10s
@property (nonatomic, assign) SGRequestMethod method;   // defalut is GET
@property (nonatomic, copy) SGPostFormDataBlock postFormDataBlock;  // post upload need

- (void)start;
- (void)stop;
- (void)clearHandler;

- (void)startWithCompletionHandler:(SGRequestHandler)completionHandler;
- (void)startWithSuccessHandler:(SGRequestHandler)successHandler
                 failureHandler:(SGRequestHandler)failureHandler;
- (void)startWithSuccessHandler:(SGRequestHandler)successHandler
                 failureHandler:(SGRequestHandler)failureHandler
              completionHandler:(SGRequestHandler)completionHandler;


#pragma mark - subclass override

- (NSError *)checkErrorFromOriginalResponseObject:(id)originalResponseObject;
- (id)pretreatmentResponseObjectFromOriginalResponseObject:(id)originalResponseObject;
- (id)objectWithKeyValues:(NSDictionary *)keyValues objectClass:(Class)objectClass;
- (NSArray *)objectArrayWithKeyValuesArray:(NSArray <NSDictionary *> *)keyValuesArray objectClass:(Class)objectClass;

@end
