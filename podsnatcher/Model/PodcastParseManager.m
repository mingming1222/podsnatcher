//
//  PodcastParseManager.m
//  podsnatcher
//
//  Created by mingming on 14-5-21.
//  Copyright (c) 2014年 mingming. All rights reserved.
//

#import "PodcastParseManager.h"
#import "PodcastModelManager.h"
#import "IGEpisode.h"
#import <NSString+HTML.h>

@interface PodcastParseManager ()
@property (nonatomic, strong) PodcastModelManager *modelManager;
@property (nonatomic, strong) NSArray *episodes;
@end


@implementation PodcastParseManager


- (instancetype)init
{
    self = [super init];
    if (self) {
        self.modelManager = [PodcastModelManager defaultManager];
    }
    return self;
}

- (instancetype)initWithURL:(NSURL *)url forUpdate:(NSDate *)update;
{
    if (self = [self init]) {
        self.feedParser = [[MWFeedParser alloc] initWithFeedURL:url];
        self.feedParser.delegate = self;
        self.lastUpdate = update;
        
        if (self.lastUpdate) {
            self.feedParser.connectionType = ConnectionTypeAsynchronously;
            [self.feedParser setFeedParseType:ParseTypeItemsOnly];

        } else {
            self.feedParser.connectionType = ConnectionTypeSynchronously;
            [self.feedParser setFeedParseType:ParseTypeFull];
        }
    }
    
    return self;
};

- (NSArray *)episodes
{
    if (! _episodes) {
        self.modelManager.fetchEpisodeRequest.predicate = [NSPredicate predicateWithFormat:@"collectionId==%@", self.collectionId];
        
        NSError *error = nil;
        _episodes = [self.modelManager.mainManagedObjectContext
                                              executeFetchRequest:self.modelManager.fetchEpisodeRequest error:&error];
    }
    
    return _episodes;
}

- (void)feedParser:(MWFeedParser *)parser didParseFeedInfo:(MWFeedInfo *)info
{
    NSManagedObjectContext *tempContext = self.modelManager.temporaryManagedObjectContext;
    [tempContext performBlock:^{
        
        Podcast *podcast = [NSEntityDescription insertNewObjectForEntityForName:@"Podcast"
                                                         inManagedObjectContext:tempContext];
        self.podcastID = podcast.objectID;
        if (podcast != nil) {
            podcast.feedURL = [self.feedParser.url absoluteString];
            podcast.artworkImage = self.artworkImageData;
            podcast.collectionId = self.collectionId;
            podcast.artistName = self.artistName;
            podcast.title = info.title;
            podcast.summary = info.summary;
            podcast.link = info.link;
            podcast.addTime = [NSDate date];
            podcast.lastUpdate = [NSDate date];
            
            NSError *Error = nil;
            if ([tempContext save:&Error]) {
                [self.modelManager saveContextWithWait:YES];
                NSLog(@"success to create podcost");
            } else {
                NSLog(@"Failed to save the managerd object context");
            }
            
        } else {
            NSLog(@"Failed to create the new person object.");
        }
        
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    }];
}


- (void)feedParser:(MWFeedParser *)parser didParseFeedItem:(MWFeedItem *)item
{
    if (self.lastUpdate) {
        NSDate *earlierDateIs = [item.date earlierDate:self.lastUpdate];
        if (earlierDateIs) return;
    }
   
    NSManagedObjectContext *tempContext = self.modelManager.temporaryManagedObjectContext;
    [tempContext performBlock:^{
        IGEpisode *episode = [NSEntityDescription insertNewObjectForEntityForName:@"Episode"
                                                                inManagedObjectContext:tempContext];
        if (episode != nil) {
            episode.collectionId = self.collectionId;
            episode.author = item.author;
            episode.content = item.content;
            episode.date = item.date;
            episode.identifier = episode.identifier;
            episode.link = item.link;
            episode.summary = [item.summary stringByConvertingHTMLToPlainText];
            episode.title = item.title;
            episode.updated = item.updated;
            episode.enclosures = item.enclosures;
            episode.isDownloaded = @NO;
            episode.isPlayed = @NO;
            
            NSDictionary *enclosures = [episode.enclosures objectAtIndex:0];
            NSURL *url = [NSURL URLWithString:[enclosures objectForKey:@"url"]];
            episode.url = [url absoluteString];
            
            Podcast *podcast = (Podcast *)[tempContext objectWithID:self.podcastID];
            episode.podcastInfo = podcast;
            
            NSError *Error = nil;
            if ([tempContext save:&Error]) {
                [self.modelManager saveContextWithWait:YES];
                NSLog(@"success to create episode");
            } else {
                NSLog(@"Failed to save the managerd object context");
            }
            
        } else {
            NSLog(@"Failed to create the new episode object.");
        }
    }];
    
}

- (void)feedParser:(MWFeedParser *)parser didFailWithError:(NSError *)error
{
    [self.delegate feedParserDidFailWithError:error];
}

- (void)feedParserDidFinish:(MWFeedParser *)parser
{
    [self.delegate feedParserDidFinish:self.collectionId];
}
@end
