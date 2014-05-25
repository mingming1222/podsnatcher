//
//  PlayViewController.h
//  podsnatcher
//
//  Created by mingming on 14-4-23.
//  Copyright (c) 2014年 mingming. All rights reserved.
//

#import "podcastInfoViewController.h"
#import "Podcast.h"
#import "IGEpisode.h"
#import <FSAudioController.h>
#import <FSAudioStream.h>

@protocol PlayViewControllerDelegate <NSObject>

- (void)audioStreamPlaying:(double)playedTime withEpisode:(IGEpisode *)episode;
- (void)audioStreamWillStop:(double)playedTime withEpisode:(IGEpisode *)episode;
- (void)audioStreamWillPause:(double)playedTime;

@end
@interface PlayViewController : podcastInfoViewController

@property (nonatomic, strong) UILabel *remainderPlayTime;
@property (nonatomic, strong) UILabel *alreadyPlayTime;
@property (nonatomic, strong) NSURL *url;

@property (nonatomic, strong) FSAudioController *audioController;
@property (nonatomic, assign) BOOL isPaused;

@property (nonatomic, weak) id <PlayViewControllerDelegate> delegate;
@end
