//
//  SettingsViewController.m
//  podsnatcher
//
//  Created by mingming on 14-4-25.
//  Copyright (c) 2014年 mingming. All rights reserved.
//

#import "SettingsViewController.h"
#import "SearchViewController.h"
#import "PodcastDownloader.h"
#import "PodcastModelManager.h"
#import "SettingTableViewCell.h"
#import "Podcast.h"
#import "PodcastParseManager.h"

@interface SettingsViewController ()

@property (nonatomic, strong) UITableView *podcastListView;
@property (nonatomic, strong) UINavigationBar *navigationBar;

@property (nonatomic, strong) UIBarButtonItem *editButton;
@property (nonatomic, strong) UIBarButtonItem *doneButton;
@property (nonatomic, strong) UIBarButtonItem *closeButton;
@property (nonatomic, strong) UINavigationItem *navigationTitle;

@property (nonatomic, strong) PodcastModelManager *modelManager;
@property (nonatomic, strong) PodcastParseManager *parseManager;


@end

@implementation SettingsViewController


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
        self.modelManager = [PodcastModelManager defaultManager];
        self.podcastFRC = [[NSFetchedResultsController alloc] initWithFetchRequest:self.modelManager.fetchPodcastRequest managedObjectContext:self.modelManager.mainManagedObjectContext sectionNameKeyPath:nil cacheName:nil];

        self.podcastFRC.delegate = self;
        
        NSError *error = nil;
        if ([self.podcastFRC performFetch:&error]) {
            NSLog(@"Successfully fetched.");
        } else {
            NSLog(@"Failed to fatch.");
        }
       
    }
    return self;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initNavigationBar];
    [self initPodcastListView];
}
- (void)initNavigationBar
{
    self.navigationBar = [[UINavigationBar alloc]initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 64)];
    self.navigationBar.TitleTextAttributes = @{NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue" size:22]};
    self.navigationBar.translucent = YES;
    [self.view addSubview:self.navigationBar];
    
    self.closeButton = [[UIBarButtonItem alloc] initWithTitle:@"Close" style:UIBarButtonItemStylePlain target:self action:@selector(closeButtonPressed)];
    
    self.editButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(editButtonPressed)];
    
   
    self.navigationTitle = [[UINavigationItem alloc] initWithTitle:@"Settings"];
    [self.navigationTitle setRightBarButtonItem:self.closeButton];
    [self.navigationTitle setLeftBarButtonItem:self.editButton];
    [self.navigationBar setItems:@[self.navigationTitle]];
}

- (void)addNewPodcastPressed
{
    SearchViewController *svc = [[SearchViewController alloc] init];
    svc.delegate = self;
    [self presentViewController:svc animated:YES completion:nil];
}

- (void)closeButtonPressed
{
    if ([self.podcastListView isEditing]) {
        [self.podcastListView setEditing:NO animated:YES];
        [self.navigationTitle setLeftBarButtonItem:self.editButton];
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)editButtonPressed
{
    [self.podcastListView setEditing:YES animated:YES];
    self.doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneButtonPressed)];
 
    [self.navigationTitle setLeftBarButtonItem:self.doneButton];
}
- (void)doneButtonPressed
{
    if ([self.podcastListView isEditing]) {
        [self.podcastListView setEditing:NO animated:YES];
        [self.navigationTitle setLeftBarButtonItem:self.editButton];
    }
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initPodcastListView
{
    self.podcastListView = [[UITableView alloc] initWithFrame:CGRectMake(10, self.navigationBar.bounds.size.height + 10, self.infoContentView.bounds.size.width - 20, 400) style:UITableViewStylePlain];
    self.podcastListView.dataSource = self;
    self.podcastListView.delegate = self;
    self.podcastListView.showsVerticalScrollIndicator = NO;
    self.podcastListView.backgroundColor = [UIColor clearColor];
    
    UIButton *addNewPodcastButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 36)];
    [addNewPodcastButton setTitle:@"添加新的播客" forState:UIControlStateNormal];
    [addNewPodcastButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    addNewPodcastButton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:14];
    [addNewPodcastButton setImage:[UIImage imageNamed:@"icon-add"] forState:UIControlStateNormal];
    [addNewPodcastButton addTarget:self action:@selector(addNewPodcastPressed) forControlEvents:UIControlEventTouchUpInside];
    self.podcastListView.tableFooterView = addNewPodcastButton;
    
    [self.infoContentView addSubview:self.podcastListView];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if (! cell) {
        cell = [[SettingTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        Podcast *podcast = [self.podcastFRC objectAtIndexPath:indexPath];
        cell.separatorInset = UIEdgeInsetsZero;
        cell.textLabel.text = podcast.title;
        cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:12];
        cell.backgroundColor = [UIColor clearColor];
        cell.imageView.image = [UIImage imageWithData:podcast.artworkImage];
    }
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.podcastFRC.sections.count;
    
}

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    [self.podcastListView beginUpdates];
}


- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath
{
    
    UITableView *tableView = self.podcastListView;
    switch(type) {
         case NSFetchedResultsChangeUpdate:
            [tableView reloadRowsAtIndexPaths: [NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
            
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            [self.podcastListView endUpdates];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:[NSArray
                                               arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:[NSArray
                                               arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id<NSFetchedResultsSectionInfo>)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
    switch(type) {
            
        case NSFetchedResultsChangeInsert:
            [self.podcastListView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.podcastListView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.podcastListView endUpdates];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    id <NSFetchedResultsSectionInfo> sectionInfo = [self.podcastFRC.sections objectAtIndex:section];
    NSInteger row = [sectionInfo numberOfObjects];
    if (row == 0) {
        [self.navigationItem.leftBarButtonItem setEnabled:NO];
    }
    return row;
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    Podcast *podcast = [self.podcastFRC objectAtIndexPath:indexPath];
    BOOL deletable = [self.delegate willDeletePodcast:podcast];
    if (!deletable) {
        [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationRight];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Warning" message:@"正在播放该播客，不允许删除"
                                                       delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        return;
    }
    
    self.podcastFRC.delegate = nil;
    [self.modelManager.mainManagedObjectContext deleteObject:podcast];
    [self.modelManager.mainManagedObjectContext performBlock:^{
    if ([podcast isDeleted]) {
        NSError *savingError = nil;
        if ([self.modelManager.mainManagedObjectContext save:&savingError]) {
                [self.modelManager saveContextWithWait:NO];
                
                NSError *fetchingError = nil;
                if ([self.podcastFRC performFetch:&fetchingError]) {
                    NSLog(@"Successfully fetched.");
                    NSArray *rowsToDelete = [[NSArray alloc] initWithObjects:indexPath, nil];
                    [self.podcastListView deleteRowsAtIndexPaths:rowsToDelete withRowAnimation:UITableViewRowAnimationAutomatic];
                } else {
                    NSLog(@"Failed to fetch with error = %@", fetchingError);
                }
                
            } else {
                NSLog(@"Failed to save the context with error = %@", savingError);
            }
        }
        self.podcastFRC.delegate = self;
    }];
}

- (void)didAddPodcast:(NSDictionary *)podcast
{
    NSNumber *collectionId = [podcast objectForKey:@"collectionId"];
    if ([self.modelManager getPodcastByCollectionId:collectionId]) {
        return;
    }
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    NSURL *imageUrl = [NSURL URLWithString:[podcast objectForKey:@"artworkUrl600"]];
    PodcastDownloader *downloader = [PodcastDownloader sharedDownloader];
    [downloader downloadTaskWithRUL:imageUrl completionHandler:^(NSURL *location, NSURLResponse *response, NSError *error) {
        if (error) {
            if (error.code != -999) {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:[error description] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [alertView show];
            }
        }
        
        // Initialize Feed Parser
        NSURL *feedURL = [NSURL URLWithString:[podcast objectForKey:@"feedUrl"]];
        PodcastParseManager *feedParser = [[PodcastParseManager alloc] initWithURL:feedURL forUpdate:nil];
        feedParser.artworkImageData = [NSData dataWithContentsOfURL:location];
        feedParser.artistName = [podcast objectForKey:@"artistName"];
        feedParser.collectionId = collectionId;
        feedParser.delegate = self.delegate;
        [feedParser.feedParser parse];
    }];
    
}
@end
