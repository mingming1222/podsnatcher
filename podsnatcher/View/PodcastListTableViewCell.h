//
//  PodcastListTableViewCell.h
//  podsnatcher
//
//  Created by mingming on 14-5-12.
//  Copyright (c) 2014年 mingming. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JEProgressView.h"

@protocol PodcastListTableViewCellDelegate <NSObject>

- (void)podcastListTableViewCellDownloadDidPressed:(NSIndexPath *)indexPath;
- (void)podcastListTableViewCellCancelDidPressed:(NSIndexPath *)indexPath;

@end

@interface PodcastListTableViewCell : UITableViewCell

@property (weak, nonatomic) id<PodcastListTableViewCellDelegate> delegate;
@property (nonatomic, strong) JEProgressView *downloadProgressView;
@property (nonatomic, weak) NSURLSessionDownloadTask *downloadTask;
@property (nonatomic, strong) NSString *url;
@property (nonatomic, strong) UILabel *playedTime;

@end
