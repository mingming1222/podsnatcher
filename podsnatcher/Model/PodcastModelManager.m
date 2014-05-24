//
//  PodcastModelManager.m
//  podsnatcher
//
//  Created by mingming on 14-5-8.
//  Copyright (c) 2014年 mingming. All rights reserved.
//

#import "PodcastModelManager.h"
#import <CoreData/CoreData.h>

@implementation PodcastModelManager
@synthesize backgroundManagedObjectContext = _backgroundManagedObjectContext;
@synthesize temporaryManagedObjectContext = _temporaryManagedObjectContext;
@synthesize mainManagedObjectContext = _mainManagedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

+ (instancetype)defaultManager
{
    static PodcastModelManager *podcastModelManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        podcastModelManager = [[PodcastModelManager alloc] init];
    });
    return podcastModelManager;
}

- (void)saveContextWithWait:(BOOL)needWait
{
    if (nil == self.mainManagedObjectContext) {
        return;
    }
    
    if ([self.mainManagedObjectContext hasChanges]) {
        NSLog(@"Main context need to save");
        [self.mainManagedObjectContext performBlockAndWait:^{
            NSError *error = nil;
            if (![self.mainManagedObjectContext save:&error]) {
                NSLog(@"Save main context failed and error is %@", error);
            }
        }];
    }
    
    if (nil == self.backgroundManagedObjectContext) {
        return;
    }
    
    void (^rootContextSave)() = ^{
        NSError *error = nil;
        if ([self.backgroundManagedObjectContext save:&error]) {
            NSLog(@"Save root context Successfull");
        } else {
            NSLog(@"Save root context failed and error is %@", error);
        }
    };
    
    if ([self.backgroundManagedObjectContext hasChanges]) {
        NSLog(@"Root context need to save");
        if (needWait) {
            [self.backgroundManagedObjectContext performBlockAndWait:rootContextSave];
        }
        else {
            [self.backgroundManagedObjectContext performBlock:rootContextSave];
        }
    }
}

- (NSFetchRequest *)fetchEpisodeRequest
{
    if (! _fetchEpisodeRequest) {
        _fetchEpisodeRequest = [[NSFetchRequest alloc] init];
        _fetchEpisodeRequest.entity = [NSEntityDescription entityForName:@"Episode" inManagedObjectContext:self.mainManagedObjectContext];
        NSSortDescriptor *dateSort = [[NSSortDescriptor alloc] initWithKey:@"date" ascending:NO];
        _fetchEpisodeRequest.fetchLimit = EPISODELIST_PAGE_COUNT;
        _fetchEpisodeRequest.sortDescriptors = @[dateSort];
    }
    
    return _fetchEpisodeRequest;
}
- (NSFetchRequest *)fetchPodcastRequest
{
    if (! _fetchPodcastRequest) {
        _fetchPodcastRequest = [[NSFetchRequest alloc] init];
        _fetchPodcastRequest.entity = [NSEntityDescription entityForName:@"Podcast" inManagedObjectContext:self.mainManagedObjectContext];
        NSSortDescriptor *dateSort = [[NSSortDescriptor alloc] initWithKey:@"addTime" ascending:NO];
        _fetchPodcastRequest.sortDescriptors = @[dateSort];
    }
    
    return _fetchPodcastRequest;
}

- (Podcast *)getPodcastByCollectionId:(NSNumber *)collectionId
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Podcast" inManagedObjectContext:self.mainManagedObjectContext];
    fetchRequest.entity = entity;
    
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"collectionId = %@", collectionId];
    fetchRequest.fetchLimit = 1;
    
    NSError *fetchingError = nil;
    NSArray *podcasts = [self.mainManagedObjectContext executeFetchRequest:fetchRequest error:&fetchingError];
    
    if (podcasts && podcasts.count > 0) {
        return [podcasts objectAtIndex:0];
    }
    
    return nil;
}

- (IGEpisode *)getEpisodeByURL:(NSURL *)url
{
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Episode" inManagedObjectContext:self.mainManagedObjectContext];
    fetchRequest.entity = entity;
    
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"url = %@", url];
    fetchRequest.fetchLimit = 1;
    
    NSError *fetchingError = nil;
    NSArray *episodes = [self.mainManagedObjectContext executeFetchRequest:fetchRequest error:&fetchingError];
    
    if (episodes && episodes.count > 0) {
        return [episodes objectAtIndex:0];
    }
    
    return nil;
}

- (EpisodeFileData *)getEpisodeFileDataByURL:(NSURL *)url
{
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"EpisodeFileData"
                                                        inManagedObjectContext:self.mainManagedObjectContext];
    fetchRequest.entity = entity;
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"url = %@", url];
    fetchRequest.fetchLimit = 1;
    
    NSError *fetchingError = nil;
    NSArray *episodeFileData = [self.mainManagedObjectContext executeFetchRequest:fetchRequest error:&fetchingError];
    
    if (episodeFileData && episodeFileData.count > 0) {
        return [episodeFileData objectAtIndex:0];
    }
    
    return nil;
}

#pragma mark - Core Data stack

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)backgroundManagedObjectContext
{
    if (_backgroundManagedObjectContext != nil) {
        return _backgroundManagedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _backgroundManagedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
        [_backgroundManagedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _backgroundManagedObjectContext;
}

- (NSManagedObjectContext *)mainManagedObjectContext
{
    if (!_mainManagedObjectContext) {
        _mainManagedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
        _mainManagedObjectContext.parentContext = [self backgroundManagedObjectContext];
    }
    return _mainManagedObjectContext;
}

- (NSManagedObjectContext *)temporaryManagedObjectContext
{
    _temporaryManagedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    _temporaryManagedObjectContext.parentContext = [self mainManagedObjectContext];
    return _temporaryManagedObjectContext;
}



// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Model" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"coreData.sqlite"];
    
    NSError *error = nil;
    
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter:
         @{NSMigratePersistentStoresAutomaticallyOption:@YES, NSInferMappingModelAutomaticallyOption:@YES}
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}

#pragma mark - Application's Documents directory

- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

@end
