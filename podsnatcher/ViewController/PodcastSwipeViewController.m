//
//  SwipeViewController.m
//  podsnatcher
//
//  Created by mingming on 14-5-16.
//  Copyright (c) 2014年 mingming. All rights reserved.
//

#import "PodcastSwipeViewController.h"
#import "PodcastModelManager.h"

@interface PodcastSwipeViewController ()
@property (nonatomic, strong) PodcastModelManager *modelManager;

@property (nonatomic, strong) UIImageView *podcastBackgroundBanner;
@property (nonatomic, strong) UIImageView *podcastStripeView;
@property (nonatomic, strong) UIImageView *podcastTabs;
@property (nonatomic, strong) UIView *podcastBackgroundView;
@property (nonatomic, strong) UIImageView *podcastCoverBorderView;
@property (nonatomic, strong) UIImageView *defaultCoverImageView;

@property (nonatomic, strong) SwipeView *podcastCoverSwpieView;

@property (nonatomic, strong) UIBarButtonItem  *settingsButton;
@property (nonatomic, strong) UIBarButtonItem *playButton;

@property (nonatomic, strong) NSFetchedResultsController *podcastFRC;

@end

@implementation PodcastSwipeViewController

- (SettingsViewController *)settingsViewController
{
    if (! _settingsViewController) {
        _settingsViewController = [[SettingsViewController alloc] init];
        _settingsViewController.delegate = self.podcastListController;
    }
    return _settingsViewController;
}
- (UIImageView *)podcastCoverBorderView
{
    if (! _podcastCoverBorderView) {
        UIImage *coverBorder = [UIImage imageNamed:@"border"];
        _podcastCoverBorderView = [[UIImageView alloc] initWithImage:coverBorder];
        _podcastCoverBorderView.tag = 1;
        _podcastCoverBorderView.contentMode = UIViewContentModeCenter;
        _podcastCoverBorderView.userInteractionEnabled = YES;
        [_podcastCoverBorderView setFrame:CGRectMake(0, 0, self.self.view.bounds.size.width,
                                                     self.podcastBackgroundView.bounds.size.height)];
    }
    return _podcastCoverBorderView;
}
- (UIImageView *)defaultCoverImageView
{
    if (! _defaultCoverImageView) {
        _defaultCoverImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"default-album-art-144-144"]];
        _defaultCoverImageView.frame = self.podcastBackgroundView.bounds;
        _defaultCoverImageView.contentMode = UIViewContentModeCenter;
    }
    
    return _defaultCoverImageView;
}
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.modelManager = [PodcastModelManager defaultManager];
        self.podcastListController = [[PodcastListViewController alloc] init];
        [self addChildViewController:self.podcastListController];
        
        [self initPodcastData];
        [self.podcastListController initEpisodeData:self.podcastFRC.fetchedObjects];
        
        Podcast *podcast = [self.podcastFRC.fetchedObjects firstObject];
        self.title = podcast.title;
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor colorWithRed:228/255.0 green:241/255.0 blue:245/255.0 alpha:1];
    [self initNavBar];
    [self initPodcastTopView];
    [self initSwpieView];
    
    CGRect frame = self.podcastListController.podcastListView.frame;
    self.podcastListController.podcastListView.frame = CGRectMake(frame.origin.x,
                                                                  self.podcastBackgroundView.frame.size.height,
                                                                  frame.size.width,
                                                                  self.view.bounds.size.height
                                                                  - self.podcastBackgroundView.bounds.size.height);

    [self.view insertSubview:self.podcastListController.view atIndex:0];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (self.podcastListController.playViewController) {
        self.navigationItem.rightBarButtonItem.enabled = YES;
    }
    
}

- (void)initPodcastData
{
    self.podcastFRC = [[NSFetchedResultsController alloc] initWithFetchRequest:self.modelManager.fetchPodcastRequest managedObjectContext:self.modelManager.mainManagedObjectContext sectionNameKeyPath:nil cacheName:nil];
    self.podcastFRC.delegate = self;
    NSError *error = nil;
    if ([self.podcastFRC performFetch:&error]) {
        NSLog(@"Successfully fetched.");
    } else {
        NSLog(@"Failed to fatch.");
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initNavBar
{
    self.settingsButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose target:self action:@selector(settingsButtonPressed)];
    self.navigationItem.leftBarButtonItem = self.settingsButton;
    
    self.playButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemPlay target:self action:@selector(playButtonPressed)];
    
    self.navigationItem.rightBarButtonItem = self.playButton;
    self.navigationItem.rightBarButtonItem.enabled = NO;
    [[UINavigationBar appearance] setBarTintColor: self.podcastListController.view.backgroundColor];
}



- (void)initPodcastTopView
{
    
    CGFloat statusBarHeight = [[UIApplication sharedApplication] statusBarFrame].size.height;
    
    UIImage *background = [UIImage imageNamed:@"background-top"];
    self.podcastBackgroundBanner = [[UIImageView alloc] initWithImage:background];
    [self.podcastBackgroundBanner setFrame:CGRectMake(0, 0, self.view.bounds.size.width, background.size.height)];
    
    UIImage *stripe = [UIImage imageNamed:@"stripe"];
    self.podcastStripeView = [[UIImageView alloc] initWithImage:stripe];
    [self.podcastStripeView setFrame:CGRectMake(0, self.podcastBackgroundBanner.frame.origin.y + self.podcastBackgroundBanner.frame.size.height, self.view.bounds.size.width, stripe.size.height)];
    
    self.podcastBackgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, self.navigationController.navigationBar.bounds.size.height + statusBarHeight, self.view.bounds.size.width, self.podcastBackgroundBanner.bounds.size.height + self.podcastStripeView.bounds.size.height + 20)];
    
    [self.view addSubview:self.podcastBackgroundView];
    [self.podcastBackgroundView addSubview:self.podcastBackgroundBanner];
    [self.podcastBackgroundView addSubview:self.podcastStripeView];
 
    self.podcastTabs = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tabs"]];
    [self.podcastTabs setFrame:CGRectMake(0, 11, self.view.bounds.size.width, self.podcastBackgroundBanner.bounds.size.height)];
    self.podcastTabs.contentMode = UIViewContentModeBottom;
    [self.podcastBackgroundView addSubview:self.podcastTabs];
}

- (void)initSwpieView
{
    self.podcastCoverSwpieView = [[SwipeView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width,
                                                                             self.podcastBackgroundView.bounds.size.height)];
    
    self.podcastCoverSwpieView.delegate = self;
    self.podcastCoverSwpieView.dataSource = self;
    self.podcastCoverSwpieView.alignment = SwipeViewAlignmentCenter;
    self.podcastCoverSwpieView.itemsPerPage = 1;
    self.podcastCoverSwpieView.pagingEnabled = YES;
    self.podcastCoverSwpieView.currentItemIndex = 1;
    [self.podcastBackgroundView addSubview:self.podcastCoverSwpieView];
    
}


- (UIView *)swipeView:(SwipeView *)swipeView viewForItemAtIndex:(NSInteger)index reusingView:(UIView *)view
{
    
  
    UIImageView *copyBorderView = [NSKeyedUnarchiver unarchiveObjectWithData:
                             [NSKeyedArchiver archivedDataWithRootObject:self.podcastCoverBorderView]];
    
    Podcast *podcast = nil;
    if (self.podcastFRC.fetchedObjects.count > 0) {
        podcast = [self getPodcastByIndex:index];
    }
    
    if (view == nil) {
        view = [[UIView alloc] initWithFrame:CGRectMake(self.view.bounds.size.width/2, 0, self.view.bounds.size.width, self.podcastBackgroundView.bounds.size.height)];
        copyBorderView.center = view.center;
        [view addSubview:copyBorderView];
        
        if (podcast) {
            UIImage *coverImage = [[UIImage alloc] initWithData:podcast.artworkImage];
            UIButton *coverImageButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0,
                                                           self.defaultCoverImageView.image.size.width,
                                                           self.defaultCoverImageView.image.size.height)];
            coverImageButton.center = view.center;
            coverImageButton.tag = [podcast.collectionId integerValue];
            
            if (coverImage) {
                [coverImageButton setBackgroundImage:coverImage forState:UIControlStateNormal];
            } else {
                [coverImageButton setBackgroundImage:self.defaultCoverImageView.image forState:UIControlStateNormal];
            }
            
            [coverImageButton addTarget:self action:@selector(coverImageButtonPressed:)
                                                        forControlEvents:UIControlEventTouchUpInside];
            [view addSubview:coverImageButton];
        
        } else {
            [view addSubview:self.defaultCoverImageView];
            self.defaultCoverImageView.center = view.center;
        }
 
    } else {
            UIButton *coverImageButton = [view.subviews objectAtIndex:1];
            UIImage *coverImage = [[UIImage alloc] initWithData:podcast.artworkImage];
            [coverImageButton setBackgroundImage:coverImage forState:UIControlStateNormal];
            coverImageButton.tag = [podcast.collectionId integerValue];
    }
    
    return view;
}


- (NSInteger)numberOfItemsInSwipeView:(SwipeView *)swipeView;
{
    if (self.podcastFRC.fetchedObjects.count == 0) {
        return 1;
    }
    
    return self.podcastFRC.fetchedObjects.count + 2;
}


- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath
{
    switch(type) {
        case NSFetchedResultsChangeUpdate:
            break;
            
        case NSFetchedResultsChangeInsert:
            [self.podcastListController addEpisodeFRCByPodcast:anObject];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.podcastListController removeEpisodeByPodcast:anObject];
            break;
            
    }
    
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.podcastCoverSwpieView reloadData];
}

- (Podcast *)getPodcastByIndex:(NSInteger)index
{
    Podcast *podcast = nil;
    if (index == 0) {
        podcast = [self.podcastFRC.fetchedObjects lastObject];
    } else if (index == self.podcastFRC.fetchedObjects.count + 1) {
        podcast = [self.podcastFRC.fetchedObjects firstObject];
    } else {
        podcast = [self.podcastFRC.fetchedObjects objectAtIndex:index - 1];
    }

    return podcast;
}
- (CGSize)swipeViewItemSize:(SwipeView *)swipeView
{
   return CGSizeMake(self.view.bounds.size.width * 2, self.podcastBackgroundView.bounds.size.height);
    
}
- (void)swipeViewWillBeginDragging:(SwipeView *)swipeView
{
    _beginDraggingOffset = swipeView.scrollOffset;
}

- (void)swipeViewDidEndDecelerating:(SwipeView *)swipeView
{
    CGFloat _endDeceleratingOffset = swipeView.scrollOffset;
    int podcastCount = self.podcastFRC.fetchedObjects.count;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if (_endDeceleratingOffset == 0 && _beginDraggingOffset == 1) {
            [swipeView setCurrentItemIndex:podcastCount];
        } else if (_endDeceleratingOffset == _beginDraggingOffset + 1 && _beginDraggingOffset == podcastCount) {
            [swipeView setCurrentItemIndex:1];
        }
    });
}

- (void)swipeViewCurrentItemIndexDidChange:(SwipeView *)swipeView
{
    NSInteger index = swipeView.currentItemIndex;
    Podcast *podcast = [self getPodcastByIndex:index];
    self.title = podcast.title;
    [self.podcastListController changePodcastIndex:(NSInteger)index withPodcast:podcast];
}
- (void)coverImageButtonPressed:(UIButton *)sender
{
    podcastInfoViewController *infoViewController = [[podcastInfoViewController alloc] init];
    NSNumber *collectionId = @(sender.tag);
    Podcast *podcast = [self.modelManager getPodcastByCollectionId:collectionId];
    infoViewController.podcast = podcast;
    [infoViewController addCloseButton];
    
    [self presentViewController:infoViewController animated:YES completion:nil];
}
- (void)settingsButtonPressed
{
    [self presentViewController:self.settingsViewController animated:YES completion:^{
        self.settingsViewController.delegate = self.podcastListController;
    }];
}

- (void)playButtonPressed
{
    if (self.podcastListController.playViewController) {
        [self.navigationController pushViewController:self.podcastListController.playViewController animated:YES];
    }
}

@end
