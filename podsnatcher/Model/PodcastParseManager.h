//
//  PodcastParseManager.h
//  podsnatcher
//
//  Created by mingming on 14-5-21.
//  Copyright (c) 2014年 mingming. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MWFeedParser.h>
#import "Podcast.h"

@protocol PodcastParseManagerDelegate <NSObject>
- (void) feedParserDidFinish:(NSNumber *)collectionId;
- (void) feedParserDidFailWithError:(NSError *)error;
@end

@interface PodcastParseManager : NSObject <MWFeedParserDelegate>

@property (nonatomic, strong) NSManagedObjectID *podcastID;
@property (nonatomic, strong) NSNumber *collectionId;
@property (nonatomic, strong) NSData *artworkImageData;
@property (nonatomic, strong) NSString *artistName;
@property (nonatomic, weak) id <PodcastParseManagerDelegate> delegate;
@property (nonatomic, strong) MWFeedParser *feedParser;
@property (nonatomic, strong) NSDate *lastUpdate;

- (instancetype)initWithURL:(NSURL *)url forUpdate:(NSDate *)update;
@end
