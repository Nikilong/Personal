//
//  XMWebURLProtocol.m
//  虾兽维度
//
//  Created by Niki on 2018/7/31.
//  Copyright © 2018年 admin. All rights reserved.
//

#import "XMWebURLProtocol.h"

//static NSString* const KXMWebURLProtocolKey = @"KXMWebURLProtocol";
static NSMutableArray *requestURLArr;


@interface XMWebURLProtocol()<NSURLSessionDelegate>

@property (nonnull,strong) NSURLSessionDataTask *task;


@end

@implementation XMWebURLProtocol

+ (BOOL)canInitWithRequest:(NSURLRequest *)request{
    
    // 空加载判断
    if (request == nil || request.URL == nil){
        return NO;
    }
    
    // 防止重复加载,用于个数组记录已经加载的url,为了防止数组过长和控制性能,控制数组长度为10
    if(!requestURLArr){
        requestURLArr = [NSMutableArray array];
    }
    for (NSUInteger i = 0; i < requestURLArr.count; i++) {
        if ([request.URL.absoluteString isEqualToString:requestURLArr[i]]){
            return NO;
        }
    }
    if(requestURLArr.count > 10){
        [requestURLArr removeAllObjects];
    }
    [requestURLArr addObject:request.URL.absoluteString];
    
    
    NSLog(@"$$$$--protocal: %@",request.URL.absoluteString);
    return YES;
}


+ (NSURLRequest *)canonicalRequestForRequest:(NSURLRequest *)request
{
//    NSMutableURLRequest *mutableReqeust = [request mutableCopy];
//
//    //request截取重定向
//    if ([request.URL.absoluteString isEqualToString:sourUrl])
//    {
//        NSURL* url1 = [NSURL URLWithString:localUrl];
//        mutableReqeust = [NSMutableURLRequest requestWithURL:url1];
//    }
    
    return request;
}

- (id)initWithRequest:(NSURLRequest *)request cachedResponse:(NSCachedURLResponse *)cachedResponse client:(id <NSURLProtocolClient>)client {
    return [super initWithRequest:request cachedResponse:cachedResponse client:client];
}

+ (BOOL)requestIsCacheEquivalent:(NSURLRequest *)a toRequest:(NSURLRequest *)b
{
    return [super requestIsCacheEquivalent:a toRequest:b];
}

- (void)startLoading
{
//    NSMutableURLRequest *mutableReqeust = [[self request] mutableCopy];
//    //给我们处理过的请求设置一个标识符, 防止无限循环,
//    [NSURLProtocol setProperty:@YES forKey:KXMWebURLProtocolKey inRequest:mutableReqeust];

    //这里最好加上缓存判断，加载本地离线文件， 这个直接简单的例子。
//    if ([mutableReqeust.URL.absoluteString isEqualToString:sourIconUrl])
//    {
//        NSData* data = UIImagePNGRepresentation([UIImage imageNamed:@"medlinker"]);
//        NSURLResponse* response = [[NSURLResponse alloc] initWithURL:self.request.URL MIMEType:@"image/png" expectedContentLength:data.length textEncodingName:nil];
//        [self.client URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageAllowed];
//        [self.client URLProtocol:self didLoadData:data];
//        [self.client URLProtocolDidFinishLoading:self];
//    }
//    else
//    {
//        NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:nil];
//        self.task = [session dataTaskWithRequest:self.request];
//        [self.task resume];
//    }
    NSLog(@"requestURLArr.count--%ld",requestURLArr.count);
    
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:nil];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:self.request];
    [task resume];

}
- (void)stopLoading{

//    if (self.task != nil){
//        [self.task  cancel];
//    }
}




#pragma mark - NSURLSessionDelegate
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition))completionHandler {
    [[self client] URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageAllowed];

    completionHandler(NSURLSessionResponseAllow);
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data {
    [[self client] URLProtocol:self didLoadData:data];
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(nullable NSError *)error {
    if(error){
        [self.client URLProtocol:self didFailWithError:error];
    }else{
        [self.client URLProtocolDidFinishLoading:self];
    }
}


@end
