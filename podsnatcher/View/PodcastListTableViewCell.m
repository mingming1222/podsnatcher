//
//  PodcastListTableViewCell.m
//  podsnatcher
//
//  Created by mingming on 14-5-12.
//  Copyright (c) 2014年 mingming. All rights reserved.
//

#import "PodcastListTableViewCell.h"

#define PODCASTLIST_BORDER 3
@implementation PodcastListTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        UIColor *cellbackgroundColor = [UIColor colorWithRed:136/255.0 green:171/255.0 blue:194/255.0 alpha:1];
        UIColor *cellTextColor = [UIColor colorWithRed:73/255.0 green:112/255.0 blue:138/255.0 alpha:1];
        UIColor *cellBorderColor = [UIColor colorWithRed:172/255.0 green:201/255.0 blue:221/255.0 alpha:1];
        
        UIView *selectedView = [[UIView alloc] initWithFrame:self.bounds];
        selectedView.backgroundColor = cellTextColor;
        self.selectedBackgroundView = selectedView;
        
        self.layer.borderWidth = PODCASTLIST_BORDER;
        self.layer.borderColor = [cellBorderColor CGColor];
        
        self.backgroundColor = cellbackgroundColor;
        self.textLabel.backgroundColor = [UIColor clearColor];
        self.textLabel.textColor = cellTextColor;
        self.textLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:12];
        
        [self initImage];
        [self initDownloadProgressView];
    }
    
    return self;
}

- (void)initImage
{
    self.imageView.image = [UIImage imageNamed:@"download"];
    self.imageView.tag = 1;
    self.imageView.userInteractionEnabled = YES;
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                        action:@selector(podcastListTableViewCellImagePressed)];
    [self.imageView addGestureRecognizer:singleTap];
}

- (void)initDownloadProgressView
{
    self.downloadProgressView = [[JEProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleBar];
    self.downloadProgressView.frame = self.bounds;
    [self.downloadProgressView setProgressImage:[UIImage imageNamed:@"background-now-downloading"]];
    [self.downloadProgressView setTrackTintColor:[UIColor clearColor]];
    self.downloadProgressView.center = self.center;
    [self.contentView insertSubview:self.downloadProgressView atIndex:0];
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)podcastListTableViewCellImagePressed
{
    UITableView *table = (UITableView *)[[self superview] superview];
    NSIndexPath *pathOfTheSelfCell = [table indexPathForCell:self];
    
    if (self.imageView.tag == 1) {
        [self.delegate podcastListTableViewCellDownloadDidPressed:pathOfTheSelfCell];
    } else {
        [self.delegate podcastListTableViewCellCancelDidPressed:pathOfTheSelfCell];
    }
}


@end
