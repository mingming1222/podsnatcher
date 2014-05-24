//
//  PodcastModelManager.h
//  podsnatcher
//
//  Created by mingming on 14-5-8.
//  Copyright (c) 2014年 mingming. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "Podcast.h"
#import "IGEpisode.h"

#define EPISODELIST_PAGE_COUNT 20

@interface PodcastModelManager : NSObject
@property (readonly, strong, nonatomic) NSManagedObjectContext *backgroundManagedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectContext *temporaryManagedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectContext *mainManagedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;


@property (nonatomic ,strong) NSFetchRequest *fetchPodcastRequest;
@property (nonatomic ,strong) NSFetchRequest *fetchEpisodeRequest;

- (NSURL *)applicationDocumentsDirectory;
+ (instancetype)defaultManager;

- (Podcast *)getPodcastByCollectionId:(NSNumber *)collectionId;
- (IGEpisode *)getEpisodeByURL:(NSURL *)url;
- (EpisodeFileData *)getEpisodeFileDataByURL:(NSURL *)url;

- (void)saveContextWithWait:(BOOL)needWait;
@end
