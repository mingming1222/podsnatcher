//
//  podcastInfoViewController.h
//  podsnatcher
//
//  Created by mingming on 14-5-12.
//  Copyright (c) 2014年 mingming. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <TTTAttributedLabel.h>
#import "Podcast.h"
#import "IGEpisode.h"

@interface podcastInfoViewController : UIViewController <TTTAttributedLabelDelegate, UIActionSheetDelegate>
@property (nonatomic, strong) UIImageView *podcastCoverView;
@property (nonatomic, strong) UILabel *podcastTitle;
@property (nonatomic, strong) UITextView *podcastSummary;
@property (nonatomic, strong) UIImageView *infoContentView;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) TTTAttributedLabel *podcastLink;
@property (nonatomic, strong) UILabel *podcastArtistName;
@property (nonatomic, strong) UILabel *episodeTitle;

@property (nonatomic, strong) Podcast *podcast;
@property (nonatomic, strong) IGEpisode *episode;

- (void)addCloseButton;
@end
