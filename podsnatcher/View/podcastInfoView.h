//
//  podcastInfoView.h
//  podsnatcher
//
//  Created by mingming on 14-4-24.
//  Copyright (c) 2014年 mingming. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <TTTAttributedLabel.h>

@interface podcastInfoView : UIView <TTTAttributedLabelDelegate>
@property (nonatomic, strong) UIImageView *podcastCoverView;
@property (nonatomic, strong) UILabel *podcastTitle;
@property (nonatomic, strong) UITextView *podcastSummary;
@property (nonatomic, strong) UIImageView *infoContentView;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) TTTAttributedLabel *podcastLink;

- (id)initWithFrame:(CGRect)frame;
- (id)initInfoViewsWithFrame:(CGRect)frame;
@end
