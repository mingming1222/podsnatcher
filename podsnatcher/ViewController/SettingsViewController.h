//
//  SettingsViewController.h
//  podsnatcher
//
//  Created by mingming on 14-4-25.
//  Copyright (c) 2014年 mingming. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SearchViewController.h"
#import "PodcastParseManager.h"
#import <CoreData/CoreData.h>
#import "podcastInfoViewController.h"
#import <MWFeedParser.h>


@protocol SettingsViewControllerDelegate <NSObject>

- (BOOL)willDeletePodcast:(Podcast *)podcast;

@end

@interface SettingsViewController : podcastInfoViewController <UITableViewDataSource,
                                    UITableViewDelegate,
                                    MWFeedParserDelegate,
                                    NSFetchedResultsControllerDelegate,
                                    PodcastSearchViewControllerDelegate>

@property (nonatomic, strong) NSFetchedResultsController *podcastFRC;
@property (nonatomic, weak) id <SettingsViewControllerDelegate, PodcastParseManagerDelegate> delegate;
@end
