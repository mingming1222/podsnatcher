//
//  ViewController.h
//  podsnatcher
//
//  Created by mingming on 14-4-22.
//  Copyright (c) 2014年 mingming. All rights reserved.
//

#import "PodcastParseManager.h"
#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "PlayViewController.h"
#import "PodcastListTableViewCell.h"
#import "GGKSameValueSegmentedControl.h"
#import "Podcast.h"
#import <SVPullToRefresh.h>
#import "SettingsViewController.h"



@interface PodcastListViewController : UIViewController <UITableViewDataSource,
                            SettingsViewControllerDelegate, PlayViewControllerDelegate,
                            UITableViewDelegate, PodcastParseManagerDelegate,
                            PodcastListTableViewCellDelegate, UIScrollViewDelegate,
                            NSFetchedResultsControllerDelegate, NSURLSessionDownloadDelegate>

@property (nonatomic, strong) UITableView *podcastListView;
@property (nonatomic, strong) PlayViewController *playViewController;
@property (nonatomic, strong) NSFetchedResultsController *episodeFRC;
@property (nonatomic, strong) NSMutableArray *episodeFRCArray;
@property (nonatomic, strong) GGKSameValueSegmentedControl *categroyItem;
@property (nonatomic, strong) Podcast *podcast;

- (void)initEpisodeData:(NSArray *)podcasts;
- (void)removeEpisodeByPodcast:(Podcast *)podcast;
- (void)addEpisodeFRCByPodcast:(Podcast *)podcast;

- (void)changePodcastIndex:(NSInteger)index withPodcast:(Podcast *)podcast;
@end
