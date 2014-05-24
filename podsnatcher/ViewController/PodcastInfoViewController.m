//
//  podcastInfoViewController.m
//  podsnatcher
//
//  Created by mingming on 14-5-12.
//  Copyright (c) 2014年 mingming. All rights reserved.
//

#import "podcastInfoViewController.h"
@interface podcastInfoViewController ()
@property (strong, nonatomic) UIImageView *backgroundTopView;
@property (strong, nonatomic) UIImageView *infoBorderImageView;

@end

@implementation podcastInfoViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor colorWithRed:228/255.0 green:241/255.0 blue:245/255.0 alpha:1];
    [self initBackgroundImage];
    [self initScrollContent];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (self.episode && self.podcast) {
         [self addPodcastInfoImage:self.podcast.artworkImage title:self.podcast.title artistName:self.podcast.artistName];
        [self addPodcastInfoLink:self.episode.link summary:self.episode.summary episodeTitle:self.episode.title];
    } else if (!self.episode && self.podcast) {
        [self addPodcastInfoImage:self.podcast.artworkImage title:self.podcast.title artistName:self.podcast.artistName];
        [self addPodcastInfoLink:self.podcast.link summary:self.podcast.summary episodeTitle:nil];
    }

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initBackgroundImage
{
    UIImage *backgroundTop = [UIImage imageNamed:@"background-top"];
    self.backgroundTopView = [[UIImageView alloc] initWithImage:backgroundTop];
    [self.backgroundTopView setFrame:CGRectMake(0, 0, self.view.bounds.size.width, backgroundTop.size.height)];
    [self.view addSubview:self.backgroundTopView];
    
    
}

- (void)initScrollContent
{
    UIImage *infoContentBottom = [UIImage imageNamed:@"info-footer"];
    
    self.infoContentView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"info-content"]];
    self.infoContentView.frame = CGRectMake(5, 0, self.view.bounds.size.width - 10, self.view.bounds.size.height);
    self.infoContentView.userInteractionEnabled = YES;
    
    UIImageView *infoContentBottomView = [[UIImageView alloc] initWithImage:infoContentBottom];
    infoContentBottomView.frame = CGRectMake(5, self.infoContentView.bounds.size.height, self.view.bounds.size.width - 10, infoContentBottom.size.height);
    
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
    self.scrollView.contentSize = CGSizeMake(self.infoContentView.bounds.size.width, self.infoContentView.bounds.size.height + infoContentBottomView.bounds.size.height);
    self.scrollView.scrollsToTop = YES;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.showsVerticalScrollIndicator = NO;
    [self.scrollView addSubview:self.infoContentView];
    [self.scrollView addSubview:infoContentBottomView];
    
    [self.view addSubview:self.scrollView];
}

- (void)addPodcastInfoImage:(NSData *)coverImage title:(NSString *)title artistName:(NSString *)artistName
{
    if (!self.podcastCoverView) {
        UIImage *infoBorderImage = [UIImage imageNamed:@"info-border"];
        self.infoBorderImageView = [[UIImageView alloc] initWithImage:infoBorderImage];
        self.infoBorderImageView.frame = CGRectMake(30, 30 + 44, infoBorderImage.size.width + 20, infoBorderImage.size.height + 20);
    
        self.podcastCoverView = [[UIImageView alloc] initWithFrame:CGRectMake(17.5, 13.5, 100, 100)];
        [self.infoBorderImageView addSubview:self.podcastCoverView];
        [self.infoContentView addSubview:self.infoBorderImageView];
    }
    
    [self.podcastCoverView setImage:[UIImage imageWithData:coverImage]];
    
    CGSize lableSize;
    if (!self.podcastTitle) {
        self.podcastTitle = [[UILabel alloc] initWithFrame:CGRectMake(self.infoBorderImageView.bounds.size.width + 20,
                                                                      40 + 44, self.infoContentView.bounds.size.width - 40 - self.infoBorderImageView.bounds.size.width, 0)];
        self.podcastTitle.textAlignment = NSTextAlignmentRight;
        self.podcastTitle.numberOfLines = 0;
        self.podcastTitle.lineBreakMode = NSLineBreakByWordWrapping;
        self.podcastTitle.font = [UIFont systemFontOfSize:12];
       
        [self.infoContentView addSubview:self.podcastTitle];
    }
    
    self.podcastTitle.text = title;
    lableSize = [self.podcastTitle.text boundingRectWithSize:self.podcastTitle.bounds.size options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:nil context:nil].size;
    self.podcastTitle.frame = CGRectMake(self.podcastTitle.frame.origin.x,
                                             self.podcastTitle.frame.origin.y, self.podcastTitle.bounds.size.width, lableSize.height);
 
    self.podcastTitle.text = title;
    
    if (!self.podcastArtistName) {
        self.podcastArtistName = [[UILabel alloc] initWithFrame:CGRectMake(self.infoBorderImageView.bounds.size.width + 20, self.podcastTitle.frame.origin.y + self.podcastTitle.frame.size.height + 10, self.podcastTitle.bounds.size.width, 0)];
        self.podcastArtistName.textAlignment = NSTextAlignmentRight;
        self.podcastArtistName.numberOfLines = 0;
        self.podcastArtistName.lineBreakMode = NSLineBreakByWordWrapping;
        self.podcastArtistName.font = [UIFont systemFontOfSize:12];
        [self.infoContentView addSubview:self.podcastArtistName];
    }
    
    self.podcastArtistName.text = artistName;
    lableSize = [self.podcastTitle.text boundingRectWithSize:self.podcastTitle.bounds.size options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:nil context:nil].size;
        
    self.podcastArtistName.frame = CGRectMake(self.podcastArtistName.frame.origin.x,
                                             self.podcastArtistName.frame.origin.y, self.podcastTitle.bounds.size.width, lableSize.height);
    
}
- (void)addPodcastInfoLink:(NSString *)link summary:(NSString *)summary episodeTitle:(NSString *)episodeTitle
{
   
    if (!self.podcastLink) {
        self.podcastLink = [[TTTAttributedLabel alloc] initWithFrame:CGRectMake(self.infoBorderImageView.bounds.size.width + 20,
                                                                                self.podcastArtistName.frame.origin.y
                                                                                + self.podcastArtistName.frame.size.height + 10,
                                                                                self.podcastTitle.bounds.size.width, 20)];
        self.podcastLink.textAlignment = NSTextAlignmentRight;
        
        self.podcastLink.font = [UIFont systemFontOfSize:12];
        self.podcastLink.numberOfLines = 0;
        self.podcastLink.enabledTextCheckingTypes = NSTextCheckingTypeLink;
        self.podcastLink.delegate = self;
        [self.infoContentView addSubview:self.podcastLink];
    }
    
    NSRange protocolRange = [link rangeOfString:@"http://"];
    NSRange range = NSMakeRange(protocolRange.length, link.length - protocolRange.length);
    self.podcastLink.text = [link substringWithRange:range];
    
    CGSize lableSize;
    if (episodeTitle) {
        if (!self.episodeTitle) {
            self.episodeTitle = [[UILabel alloc] initWithFrame:CGRectMake(30,
                                                                          self.infoBorderImageView.frame.origin.y
                                                                          + self.infoBorderImageView.bounds.size.height + 10,
                                                                          self.scrollView.bounds.size.width - 60
                                                                          , 20)];
            
            self.episodeTitle.textAlignment = NSTextAlignmentCenter;
            self.episodeTitle.numberOfLines = 0;
            self.episodeTitle.lineBreakMode = NSLineBreakByWordWrapping;
            self.episodeTitle.font = [UIFont systemFontOfSize:12];
            [self.infoContentView addSubview:self.episodeTitle];
        }
        
        self.episodeTitle.text = episodeTitle;
        lableSize = [self.episodeTitle.text boundingRectWithSize:self.episodeTitle.bounds.size options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:nil context:nil].size;
        self.episodeTitle.frame = CGRectMake(self.episodeTitle.frame.origin.x,
                                                 self.episodeTitle.frame.origin.y, self.episodeTitle.bounds.size.width, lableSize.height);
    }
    
    if (!self.podcastSummary) {
        self.podcastSummary = [[UITextView alloc] initWithFrame:CGRectMake(30,
                                                  self.infoBorderImageView.bounds.size.height
                                                  + self.infoBorderImageView.frame.origin.y + 20,
                                                  self.infoContentView.bounds.size.width - 40,
                                                  self.scrollView.bounds.size.height - self.self.infoBorderImageView.bounds.size.height
                                                                           - self.infoBorderImageView.frame.origin.y - 40)];
        
        self.podcastSummary.backgroundColor = [UIColor clearColor];
        self.podcastSummary.dataDetectorTypes = UIDataDetectorTypeAll;
        self.podcastSummary.editable = NO;
        self.podcastSummary.selectable = NO;
        self.podcastSummary.showsVerticalScrollIndicator = NO;
        self.podcastSummary.showsHorizontalScrollIndicator = NO;
        [self.infoContentView addSubview:self.podcastSummary];
    }
    
    self.podcastSummary.text = summary;
}

- (void)addCloseButton
{
    UIButton *closeButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
    closeButton.center = CGPointMake(self.view.bounds.size.width/2 -10, self.infoContentView.bounds.size.height - 20);
    [closeButton setBackgroundImage:[UIImage imageNamed:@"close"] forState:UIControlStateNormal];
    
    [closeButton addTarget:self action:@selector(closeButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [self.infoContentView addSubview:closeButton];
}

- (void)closeButtonPressed
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)attributedLabel:(__unused TTTAttributedLabel *)label
   didSelectLinkWithURL:(NSURL *)url
{
    [[[UIActionSheet alloc] initWithTitle:[url absoluteString] delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", nil) destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"Open Link in Safari", nil), nil] showInView:self.view];
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet
clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == actionSheet.cancelButtonIndex) {
        return;
    }
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:actionSheet.title]];
}
@end
