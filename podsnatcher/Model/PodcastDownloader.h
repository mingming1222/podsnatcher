//
//  PodcastDownloader.h
//  podsnatcher
//
//  Created by mingming on 14-5-5.
//  Copyright (c) 2014年 mingming. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PodcastDownloader : NSObject
@property (nonatomic, strong) NSURLSession *session;
@property (nonatomic, strong) NSURLSessionDataTask *dataTask;
@property (nonatomic, strong) NSURLSessionDownloadTask *downloadTask;


+ (PodcastDownloader *)sharedDownloader;
- (void)dataTaskWithURL:(NSURL *)url completionHandler:(void (^)(NSData *data, NSURLResponse *response, NSError *error))completionHandler;
- (void)downloadTaskWithRUL:(NSURL *)url completionHandler:(void (^)(NSURL *location, NSURLResponse *response, NSError *error))completionHandle;

@end

