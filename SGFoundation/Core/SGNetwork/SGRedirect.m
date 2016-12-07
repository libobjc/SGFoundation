//
//  SGRedirect.m
//  SGFoundation
//
//  Created by Single on 2016/10/12.
//  Copyright © 2016年 single. All rights reserved.
//

#import "SGRedirect.h"

@interface SGRedirect () <NSURLSessionDataDelegate>

@property (nonatomic, copy) NSURL * url;
@property (nonatomic, copy) void (^completionHandler)(BOOL, NSString *);

@end

@implementation SGRedirect

+ (void)fetchLocationWithURL:(NSURL *)url completionHandler:(void (^)(BOOL, NSString *))completionHandler
{
    SGRedirect * redirect = [[SGRedirect alloc] init];
    [redirect fetchLocationWithURL:url completionHandler:completionHandler];
}

- (void)fetchLocationWithURL:(NSURL *)url completionHandler:(void (^)(BOOL, NSString *))completionHandler
{
    self.url = url;
    self.completionHandler = completionHandler;
    [self start];
}

- (void)start
{
    NSMutableURLRequest * request = [[NSMutableURLRequest alloc] initWithURL:self.url];
    request.HTTPMethod = @"HEAD";
    
    NSURLSession * session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:[NSOperationQueue mainQueue]];
    NSURLSessionTask * task = [session dataTaskWithRequest:request];
    [task resume];
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error
{
    [self fetchLocationFailure];
    [task cancel];
    [session invalidateAndCancel];
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition))completionHandler
{
    [self fetchLocationFailure];
    completionHandler(NSURLSessionResponseCancel);
    [dataTask cancel];
    [session invalidateAndCancel];
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task willPerformHTTPRedirection:(NSHTTPURLResponse *)response newRequest:(NSURLRequest *)request completionHandler:(void (^)(NSURLRequest * _Nullable))completionHandler
{
    if (response.statusCode == 302) {
        NSString * location = [response.allHeaderFields objectForKey:@"Location"];
        if (location.length > 0) {
            [self fetchLocationSuccess:location];
        } else {
            [self fetchLocationFailure];
        }
    } else {
        [self fetchLocationFailure];
    }
    
    [task cancel];
    [session invalidateAndCancel];
}

- (void)fetchLocationSuccess:(NSString *)location
{
    if (self.completionHandler) {
        self.completionHandler(YES, location);
    }
    self.completionHandler = nil;
}

- (void)fetchLocationFailure
{
    if (self.completionHandler) {
        self.completionHandler(NO, nil);
    }
    self.completionHandler = nil;
}

- (void)dealloc
{
    NSLog(@"SGRedirect release");
}

@end
