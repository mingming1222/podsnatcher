//
//  SwipeViewController.h
//  podsnatcher
//
//  Created by mingming on 14-5-16.
//  Copyright (c) 2014年 mingming. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SwipeView.h>
#import <CoreData/CoreData.h>

#import "SettingsViewController.h"
#import "PlayViewController.h"
#import "PodcastListViewController.h"

@interface PodcastSwipeViewController : UIViewController <SwipeViewDataSource, SwipeViewDelegate, NSFetchedResultsControllerDelegate>
{
    NSInteger _beginDraggingIndex;
    CGFloat _beginDraggingOffset;
}

@property (nonatomic, strong) SettingsViewController *settingsViewController;
@property (nonatomic, strong) PodcastListViewController *podcastListController;

@end
