//
//  ViewController.m
//  podsnatcher
//
//  Created by mingming on 14-4-22.
//  Copyright (c) 2014年 mingming. All rights reserved.
//

    //[self.navController pushViewController:vc animated:NO];
#import "PodcastListViewController.h"
#import "PodcastParseManager.h"
#import "IGEpisode.h"
#import "Podcast.h"
#import "EpisodeFileData.h"
#import "PodcastModelManager.h"
#import "PodcastDownloader.h"
#import "UIControl_GGK.h"
#import "PlayViewControllerHelper.h"

@interface PodcastListViewController ()

@property (nonatomic, strong) PodcastModelManager *modelManager;
@property (nonatomic, strong) PodcastDownloader *downloader;
@property (nonatomic, strong) NSURLSession *downloadSession;
@property (nonatomic, strong) PodcastParseManager *parseManager;
@property (nonatomic, assign) NSInteger currentEpisodePage;
@property (nonatomic, strong) NSMutableDictionary *downloadingList;
@property (nonatomic, strong) UIActivityIndicatorView *indicatorView;
@end

#define PODCASTLIST_PADDING 20
#define PODCASTLIST_BORDER 3

@implementation PodcastListViewController

#pragma mark backgroundSession getter
- (NSURLSession *)downloadSession
{
    static NSURLSession *session = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
        session = [NSURLSession sessionWithConfiguration:sessionConfiguration delegate:self delegateQueue:nil];
    });
    
    return session;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.modelManager = [[PodcastModelManager alloc] init];
        self.episodeFRCArray = [[NSMutableArray alloc] init];
        self.downloader = [PodcastDownloader sharedDownloader];
        self.parseManager = [[PodcastParseManager alloc] init];
        self.downloadingList = [[NSMutableDictionary alloc] init];
        self.currentEpisodePage = 0;
    }
    
    return self;
}

# pragma mark init episodes data
- (void)initEpisodeData:(NSArray *)podcasts
{
    for (Podcast *podcast in podcasts.reverseObjectEnumerator) {
        [self addEpisodeFRCByPodcast:podcast];
    }
}

#pragma mark add NSFetcheResultsController
- (void)addEpisodeFRCByPodcast:(Podcast *)podcast
{
    if ([self.podcast isEqual:podcast]) {
        return;
    }
    
    self.modelManager.fetchEpisodeRequest.predicate = [NSPredicate predicateWithFormat:@"collectionId==%@", podcast.collectionId];
    [self.modelManager.fetchEpisodeRequest setReturnsObjectsAsFaults:NO];
    
    NSFetchedResultsController *episodeFRC = [[NSFetchedResultsController alloc]
                                              initWithFetchRequest:self.modelManager.fetchEpisodeRequest
                                              managedObjectContext:self.modelManager.mainManagedObjectContext
                                              sectionNameKeyPath:nil cacheName:nil];
    
    [self.episodeFRCArray insertObject:episodeFRC atIndex:0];
    self.episodeFRC = episodeFRC;
    self.episodeFRC.delegate = self;
    self.podcast = podcast;
    self.currentEpisodePage += 1;
}

#pragma mark remove NSFetcheResultsController
- (void)removeEpisodeByPodcast:(Podcast *)podcast
{
    __block NSFetchedResultsController *toRemoveFRC;
    [self.episodeFRCArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSFetchedResultsController *episodeFRC = obj;
        IGEpisode *episode = [episodeFRC.fetchedObjects firstObject];
        if ([episode.collectionId isEqualToNumber:podcast.collectionId]) {
            toRemoveFRC = episodeFRC;
        }
    }];
    
    [self.episodeFRCArray removeObject:toRemoveFRC];
    if ([self.episodeFRC isEqual:toRemoveFRC]) {
        if (self.episodeFRCArray.count == 0) {
            self.episodeFRC = nil;
            self.episodeFRC.delegate = nil;
            self.currentEpisodePage = 0;
        } else {
            self.episodeFRC = [self.episodeFRCArray firstObject];
        }
        
        [self.podcastListView reloadData];
    }
    
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initPodcastListView];
    if (self.episodeFRC) {
        [self.podcastListView triggerPullToRefresh];
    }
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    NSIndexPath *selected = [self.podcastListView indexPathForSelectedRow];
    if (selected) {
        [self.podcastListView deselectRowAtIndexPath:selected animated:NO];
    }
    
  
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark init tableView
- (void)initPodcastListView
{
    
    self.podcastListView = [[UITableView alloc] initWithFrame:CGRectMake(PODCASTLIST_PADDING, 0,
                                         self.view.bounds.size.width - 2 * PODCASTLIST_PADDING,
                                         self.view.bounds.size.height) style:UITableViewStyleGrouped];
    
    
    self.podcastListView.backgroundColor = self.view.backgroundColor;
    self.podcastListView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.podcastListView setShowsVerticalScrollIndicator:NO];
    self.podcastListView.delegate = self;
    self.podcastListView.dataSource = self;
    
    self.podcastListView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.podcastListView.bounds.size.width, 100)];
   
    __weak PodcastListViewController *weakSelf = self;
    
    [self.podcastListView addPullToRefreshWithActionHandler:^{
        [weakSelf updateEpisodeData];
    }];
    
    self.podcastListView.pullToRefreshView.arrowColor = [UIColor colorWithRed:136/255.0 green:171/255.0 blue:194/255.0 alpha:1];
    self.podcastListView.pullToRefreshView.center = CGPointMake(self.view.bounds.size.width/2 + 20, 10);
    [self.podcastListView addInfiniteScrollingWithActionHandler:^{
        [weakSelf loadMoreEpisodeData];
    }];
    
    self.podcastListView.infiniteScrollingView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
    self.categroyItem = [[GGKSameValueSegmentedControl alloc] initWithItems:@[@"未收听", @"已收听", @"已下载"]];
    [self.categroyItem addTarget:self action:@selector(segmentedControlSelected) forControlEvents:UIControlEventValueChanged];
    [self.categroyItem addTarget:self action:@selector(segmentedControlUnSelected) forControlEvents:GGKControlEventValueUnchanged];
    
    self.categroyItem.center = CGPointMake(self.podcastListView.bounds.size.width/2, 80);
    [self.podcastListView.tableHeaderView addSubview:self.categroyItem];
 
    [self.view addSubview:self.podcastListView];
}

- (void)updateEpisodeData
{
    if (!self.episodeFRC) {
        [self.podcastListView.pullToRefreshView stopAnimating];
        return;
    }
    self.parseManager = [[PodcastParseManager alloc] initWithURL:[NSURL URLWithString:self.podcast.feedURL]
                                                                            forUpdate:self.podcast.lastUpdate];
    self.parseManager.delegate = self;
    self.parseManager.podcastID  = self.podcast.objectID;
    self.parseManager.collectionId = self.podcast.collectionId;
    
    if (self.parseManager.feedParser.isParsing) {
        [self.parseManager.feedParser stopParsing];
    }
    
    [self.parseManager.feedParser parse];
}

- (void)loadMoreEpisodeData
{
    if (!self.episodeFRC) {
        [self.podcastListView.infiniteScrollingView stopAnimating];
        return;
    }
 
    self.modelManager.fetchEpisodeRequest.fetchLimit = self.currentEpisodePage * EPISODELIST_PAGE_COUNT;
    [self episodeFRCperformFetch:^{
        self.currentEpisodePage += 1;
        [self.podcastListView reloadData];
        [self.podcastListView.infiniteScrollingView stopAnimating];
    }];
}

#pragma mark  UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.episodeFRC.fetchedObjects.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    PodcastListTableViewCell *cell = [[PodcastListTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
    if (self.episodeFRC) {
        IGEpisode *episode  = [self.episodeFRC.fetchedObjects objectAtIndex:indexPath.section];
        cell.textLabel.text = episode.title;
        cell.delegate = self;
        cell.url = episode.url;
        
        if ([episode.isDownloaded boolValue]) {
            cell.imageView.hidden = YES;
        }
        
        NSArray *downloadInfo = [self.downloadingList objectForKey:cell.url];
        if (downloadInfo) {
            cell.imageView.tag = 0;
            cell.imageView.image = [UIImage imageNamed:@"cancel"];
        }
        
        if ([episode.playedTime intValue] > 0 && episode.isPlayed) {
            timePosition time = [PlayViewControllerHelper getPlayedTime:[episode.playedTime doubleValue]];
            cell.playedTime.text = [NSString stringWithFormat:@"%02i:%02i:%02i", time.hour, time.minute, time.second];
            cell.textLabel.textColor = [UIColor whiteColor];
        }
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (!self.playViewController) {
        self.playViewController = [[PlayViewController alloc] init];
        self.playViewController.delegate = self;
    }

    IGEpisode *episode = [self.episodeFRC.fetchedObjects objectAtIndex:indexPath.section];
    
    if ([episode.isDownloaded boolValue]) {
        EpisodeFileData *fileData = [self.modelManager getEpisodeFileDataByURL:[NSURL URLWithString:episode.url]];
        NSString *urlString = [[NSString alloc] initWithData:fileData.fileData encoding:NSUTF8StringEncoding];
        NSURL *dataURL = [[NSURL alloc] initWithString:urlString];
        self.playViewController.url = dataURL;
    };
    
    self.playViewController.url = [NSURL URLWithString:episode.url];
    //self.parentViewController.contentType =
    self.playViewController.podcast = self.podcast;
    self.playViewController.episode = episode;
    [self.navigationController pushViewController:self.playViewController animated:YES];
    
}


- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    [self.podcastListView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath
{
    
    if (!newIndexPath) {
        return;
    }

    UITableView *tableView = self.podcastListView;
    switch(type) {
        case NSFetchedResultsChangeUpdate:
            [tableView reloadSections:[NSIndexSet indexSetWithIndex:newIndexPath.row]
                                            withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
            
        case NSFetchedResultsChangeInsert:
            [tableView insertSections:[NSIndexSet indexSetWithIndex:newIndexPath.row] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteSections:[NSIndexSet indexSetWithIndex:newIndexPath.row] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.podcastListView endUpdates];
}

#pragma mark  UITableViewDelegate
- (float)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return PODCASTLIST_BORDER/2;
}

- (float)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return PODCASTLIST_BORDER/2;
}

#pragma mark categoryItemSelected
- (void)segmentedControlSelected
{
    NSInteger index = self.categroyItem.selectedSegmentIndex;
    
    switch (index) {
        case 0:
            self.modelManager.fetchEpisodeRequest.predicate =
                        [NSPredicate predicateWithFormat:@"(isPlayed == 0) AND (collectionId==%@)", self.podcast.collectionId];
            break;
        case 1:
            self.modelManager.fetchEpisodeRequest.predicate =
                        [NSPredicate predicateWithFormat:@"(isPlayed == 1) AND (collectionId==%@)", self.podcast.collectionId];
 
            break;
        case 2:
            self.modelManager.fetchEpisodeRequest.predicate =
                        [NSPredicate predicateWithFormat:@"(isDownloaded == 1) AND (collectionId==%@)", self.podcast.collectionId];
 
            break;
        default:
            break;
    }

    [self episodeFRCperformFetch:^{
        [self.podcastListView reloadData];
    }];
}

- (void)segmentedControlUnSelected
{
    self.categroyItem.selectedSegmentIndex = UISegmentedControlNoSegment;
    self.modelManager.fetchEpisodeRequest.predicate =
                        [NSPredicate predicateWithFormat:@"collectionId==%@", self.podcast.collectionId];
    
    [self episodeFRCperformFetch:^{
        [self.podcastListView reloadData];
    }];
}

- (void)podcastListTableViewCellDownloadDidPressed:(NSIndexPath *)indexPath
{
    PodcastListTableViewCell *cell = (PodcastListTableViewCell *)[self.podcastListView cellForRowAtIndexPath:indexPath];
    NSURLSessionDownloadTask *downloadTask = [self.downloadSession downloadTaskWithURL:[NSURL URLWithString:cell.url]];
    
    [downloadTask resume];
    [self.downloadingList setValue:@[indexPath, downloadTask] forKey:cell.url];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        cell.imageView.tag = 0;
        cell.imageView.image = [UIImage imageNamed:@"cancel"];
    });
}

- (void)podcastListTableViewCellCancelDidPressed:(NSIndexPath *)indexPath
{
    PodcastListTableViewCell *cell = (PodcastListTableViewCell *)[self.podcastListView cellForRowAtIndexPath:indexPath];
    
    NSURLSessionDownloadTask *downloadTask = [self.downloadingList objectForKey:cell.url][1];
    [self.downloadingList removeObjectForKey:cell.url];
    
    [downloadTask cancel];
    downloadTask = nil;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        cell.imageView.tag = 1;
        cell.imageView.image = [UIImage imageNamed:@"download"];
        [cell.downloadProgressView setProgress:0 animated:YES];
    });
}

#pragma mark NSURLSessionDelegate
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didResumeAtOffset:(int64_t)fileOffset expectedTotalBytes:(int64_t)expectedTotalBytes
{
    NSLog(@"NSURLSessionDownloadDelegate: Resume download at %lld", fileOffset);
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite
{
    
    double progress = (double)totalBytesWritten / (double)totalBytesExpectedToWrite;
    NSString *urlString = [[[downloadTask originalRequest] URL] absoluteString];
    NSArray *downloadInfo = [self.downloadingList valueForKey:urlString];
    PodcastListTableViewCell *cell = (PodcastListTableViewCell *)[self.podcastListView cellForRowAtIndexPath:downloadInfo[0]];
    
    if ([cell.url isEqualToString:urlString ]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [cell.downloadProgressView setProgress:progress animated:YES];
        });
    }
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location
{
    
    NSURL *url = [[downloadTask originalRequest] URL];
    
    NSManagedObjectContext *tempContext = self.modelManager.temporaryManagedObjectContext;
    IGEpisode *episode = [self.modelManager getEpisodeByURL:url];
    
    [tempContext performBlock:^{
        
        EpisodeFileData *fileData = [NSEntityDescription insertNewObjectForEntityForName:@"EpisodeFileData"
                                                                        inManagedObjectContext:tempContext];
        episode.isDownloaded = @YES;
        fileData.fileData = [NSData dataWithContentsOfURL:location];
        fileData.url = [url absoluteString];
        
        NSError *Error = nil;
        if ([tempContext save:&Error]) {
            [self.modelManager saveContextWithWait:NO];
            NSLog(@"success to create episode");
        } else {
            NSLog(@"Failed to save the managerd object context");
        }
        
    }];
    
    downloadTask = nil;
    [self.downloadingList removeObjectForKey:[url absoluteString]];
}

- (void)feedParserDidFinish:(NSNumber *)collectionId
{
    if ([collectionId isEqualToNumber:self.podcast.collectionId]) {
        [self episodeFRCperformFetch:^{
            [self.podcastListView.pullToRefreshView stopAnimating];
            [self.podcastListView reloadData];
        }];
    };
}

- (void)feedParserDidFailWithError:(NSError *)error
{
    [self.podcastListView.pullToRefreshView stopAnimating];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Update failed" message:@"更新失败" delegate:self
                                                                                cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alert show];
    
}

- (void)episodeFRCperformFetch:(void(^)())performFetchBlock;
{
    NSError *error = nil;
    if ([self.episodeFRC performFetch:&error]) {
        NSLog(@"performFetch");
        if (performFetchBlock) {
            performFetchBlock();
        }
    } else {
        NSLog(@"Failed to fatch collectionId = %lu episodes", (unsigned long)self.podcast.collectionId);
    }
}

- (void)changePodcastIndex:(NSInteger)index withPodcast:(Podcast *)podcast
{
    self.podcast = podcast;
    
    if (index == 0) {
        self.episodeFRC = [self.episodeFRCArray lastObject];
    } else if (index == self.episodeFRCArray.count + 1) {
        self.episodeFRC = [self.episodeFRCArray firstObject];
    } else {
        self.episodeFRC = [self.episodeFRCArray objectAtIndex:index - 1];
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if (self.categroyItem.selectedSegmentIndex == UISegmentedControlNoSegment) {
            [self segmentedControlUnSelected];
        } else {
            [self segmentedControlSelected];
        }
    });
}

- (BOOL)willDeletePodcast:(Podcast *)podcast
{
    if ([self.playViewController.podcast.collectionId isEqualToNumber:podcast.collectionId]) {
        return NO;
    }
    
    return YES;
}
- (void)audioStreamDidPlay
{
    NSManagedObjectContext *tempContext = self.modelManager.temporaryManagedObjectContext;
    [tempContext performBlock:^{
        NSError *Error = nil;
        if ([tempContext save:&Error]) {
            [self.modelManager saveContextWithWait:NO];
            NSLog(@"success to update episode");
        } else {
            NSLog(@"Failed to save the managerd object context");
        }
        
    }];
}


- (void)audioStreamPlaying:(double)playedTime withEpisode:(IGEpisode *)episode
{
    NSIndexPath *indexPath = [self.episodeFRC indexPathForObject:episode];
    if (indexPath) {
        NSIndexPath *index = [NSIndexPath indexPathForRow:0 inSection:indexPath.row];
        PodcastListTableViewCell *cell = (PodcastListTableViewCell *)[self.podcastListView cellForRowAtIndexPath:index];
        
        timePosition time = [PlayViewControllerHelper getPlayedTime:playedTime];
        cell.playedTime.text = [NSString stringWithFormat:@"%02i:%02i:%02i", time.hour, time.minute, time.second];
        
        cell.textLabel.textColor = [UIColor whiteColor];
    }
}

- (void)audioStreamWillStop:(double)playedTime withEpisode:(IGEpisode *)episode
{
    NSManagedObjectContext *tempContext = self.modelManager.temporaryManagedObjectContext;
    [tempContext performBlock:^{
        episode.playedTime = [NSNumber numberWithDouble:playedTime];
        
        NSError *Error = nil;
        if ([tempContext save:&Error]) {
            [self.modelManager saveContextWithWait:NO];
            NSLog(@"success to update episode");
        } else {
            NSLog(@"Failed to save the managerd object context");
        }
        
    }];   
}

//- (void)audioStreamWillPause:(double)playedTime
//{
//    [self updatePlayTime:playedTime];
//}


@end