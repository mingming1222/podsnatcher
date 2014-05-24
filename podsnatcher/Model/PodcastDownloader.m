//
//  PodcastDownloader.m
//  podsnatcher
//
//  Created by mingming on 14-5-5.
//  Copyright (c) 2014年 mingming. All rights reserved.
//

#import "PodcastDownloader.h"

@implementation PodcastDownloader
+ (PodcastDownloader *)sharedDownloader
{
    static PodcastDownloader *sharedDownloader = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedDownloader = [[PodcastDownloader alloc] init];
    });
    return sharedDownloader;
}

- (NSURLSession *)session
{
    if (! _session) {
        NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
        [sessionConfiguration setHTTPAdditionalHeaders:@{@"Accept":@"application/json"}];
        _session = [NSURLSession sessionWithConfiguration:sessionConfiguration];
    }
    return _session;
}



- (void)dataTaskWithURL:(NSURL *)url completionHandler:(void (^)(NSData *data, NSURLResponse *response, NSError *error))completionHandler
{
    if (self.dataTask) {
        [self.dataTask cancel];
    }
    
    self.dataTask = [self.session dataTaskWithURL:url completionHandler:completionHandler];
    if (self.dataTask) {
        [self.dataTask resume];
    }
}

- (void)downloadTaskWithRUL:(NSURL *)url completionHandler:(void (^)(NSURL *location, NSURLResponse *response, NSError *error))completionHandler
{
    if (self.downloadTask) {
        [self.downloadTask cancel];
    }
    
    self.downloadTask = [self.session downloadTaskWithURL:url completionHandler:completionHandler];
    if (self.downloadTask) {
        [self.downloadTask resume];
    }   
}
@end
