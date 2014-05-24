//
//  EpisodeFileData.h
//  podsnatcher
//
//  Created by mingming on 14-5-23.
//  Copyright (c) 2014年 mingming. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class IGEpisode;

@interface EpisodeFileData : NSManagedObject

@property (nonatomic, retain) NSString * url;
@property (nonatomic, retain) NSData * fileData;
@property (nonatomic, retain) IGEpisode *episodeInfo;

@end
