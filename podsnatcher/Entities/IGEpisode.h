//
//  IGEpisode.h
//  podsnatcher
//
//  Created by mingming on 14-5-24.
//  Copyright (c) 2014年 mingming. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class EpisodeFileData, Podcast;

@interface IGEpisode : NSManagedObject

@property (nonatomic, retain) NSString * author;
@property (nonatomic, retain) NSNumber * collectionId;
@property (nonatomic, retain) NSString * content;
@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) id enclosures;
@property (nonatomic, retain) NSString * identifier;
@property (nonatomic, retain) NSNumber * isDownloaded;
@property (nonatomic, retain) NSString * link;
@property (nonatomic, retain) NSNumber * playedTime;
@property (nonatomic, retain) NSString * summary;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSDate * updated;
@property (nonatomic, retain) NSString * url;
@property (nonatomic, retain) NSNumber * isPlayed;
@property (nonatomic, retain) EpisodeFileData *episodeFileData;
@property (nonatomic, retain) Podcast *podcastInfo;

@end
