//
//  podcastInfoView.m
//  podsnatcher
//
//  Created by mingming on 14-4-24.
//  Copyright (c) 2014年 mingming. All rights reserved.
//

#import "podcastInfoView.h"
@interface podcastInfoView ()
@property (strong, nonatomic) UIImageView *backgroundTopView;
@property (strong, nonatomic) UIImageView *infoBorderImageView;
@end

@implementation podcastInfoView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.backgroundColor = [UIColor colorWithRed:228/255.0 green:241/255.0 blue:245/255.0 alpha:1];
        [self initBackgroundImage];
        [self initScrollContent];
        
    }
    return self;
}

- (id)initInfoViewsWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.backgroundColor = [UIColor colorWithRed:228/255.0 green:241/255.0 blue:245/255.0 alpha:1];
        [self initBackgroundImage];
        [self initScrollContent];
        [self addPodcastInfoViews];
    }
    return self;
}
- (void)initBackgroundImage
{
    UIImage *backgroundTop = [UIImage imageNamed:@"background-top"];
    self.backgroundTopView = [[UIImageView alloc] initWithImage:backgroundTop];
    [self.backgroundTopView setFrame:CGRectMake(0, 0, self.bounds.size.width, backgroundTop.size.height)];
    [self addSubview:self.backgroundTopView];
    
   
}
- (void)initScrollContent
{
    UIImage *infoContentBottom = [UIImage imageNamed:@"info-footer"];
    
    self.infoContentView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"info-content"]];
    self.infoContentView.frame = CGRectMake(5, 0, self.bounds.size.width - 10, self.bounds.size.height);
    self.infoContentView.userInteractionEnabled = YES;
    
    UIImageView *infoContentBottomView = [[UIImageView alloc] initWithImage:infoContentBottom];
    infoContentBottomView.frame = CGRectMake(5, self.infoContentView.bounds.size.height, self.bounds.size.width - 10, infoContentBottom.size.height);
    
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height)];
    self.scrollView.contentSize = CGSizeMake(self.infoContentView.bounds.size.width, self.infoContentView.bounds.size.height + infoContentBottomView.bounds.size.height);
    self.scrollView.scrollsToTop = YES;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.showsVerticalScrollIndicator = NO;
    [self.scrollView addSubview:self.infoContentView];
    [self.scrollView addSubview:infoContentBottomView];
    
    [self addSubview:self.scrollView];
}


- (void)addPodcastInfoViews
{
    UIImage *infoBorderImage = [UIImage imageNamed:@"info-border"];
    self.infoBorderImageView = [[UIImageView alloc] initWithImage:infoBorderImage];
    self.infoBorderImageView.frame = CGRectMake(30, 30 + 44, infoBorderImage.size.width + 20, infoBorderImage.size.height + 20);
    
    self.podcastCoverView = [[UIImageView alloc] initWithFrame:CGRectMake(17.5, 13.5, 100, 100)];
    [self.infoBorderImageView addSubview:self.podcastCoverView];
    [self.infoContentView addSubview:self.infoBorderImageView];
    
    self.podcastTitle = [[UILabel alloc]initWithFrame:CGRectMake(self.infoBorderImageView.bounds.size.width + 20, 40 + 44, self.infoContentView.bounds.size.width - 40 - self.infoBorderImageView.bounds.size.width, 20)];
    self.podcastTitle.textAlignment = NSTextAlignmentRight;
    self.podcastTitle.font = [UIFont fontWithName:@"HelveticaNeue" size:12];
    
    self.podcastLink = [[TTTAttributedLabel alloc] initWithFrame:CGRectMake(self.infoBorderImageView.bounds.size.width + 20, self.podcastTitle.frame.origin.y + 40, self.podcastTitle.bounds.size.width, 20)];
    self.podcastLink.textAlignment = NSTextAlignmentRight;
    
    self.podcastLink.font = [UIFont systemFontOfSize:12];
    self.podcastLink.numberOfLines = 0;
    self.podcastLink.enabledTextCheckingTypes = NSTextCheckingTypeLink;
    
    self.podcastSummary = [[UITextView alloc] initWithFrame:CGRectMake(10,
                       self.infoBorderImageView.bounds.size.height + self.infoBorderImageView.frame.origin.y + 20,
                       self.infoContentView.bounds.size.width - 20,
                       self.scrollView.bounds.size.height - self.self.infoBorderImageView.bounds.size.height - self.infoBorderImageView.frame.origin.y - 20)];
    self.podcastSummary.backgroundColor = [UIColor clearColor];
    self.podcastSummary.dataDetectorTypes = UIDataDetectorTypeAll;
    self.podcastSummary.editable = NO;
    self.podcastSummary.showsVerticalScrollIndicator = NO;
    self.podcastSummary.showsHorizontalScrollIndicator = NO;
    
    [self.infoContentView addSubview:self.podcastTitle];
    [self.infoContentView addSubview:self.podcastLink];
    [self.infoContentView addSubview:self.podcastSummary];
}


@end
