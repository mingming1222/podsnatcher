//
//  SearchViewController.m
//  podsnatcher
//
//  Created by mingming on 14-4-30.
//  Copyright (c) 2014年 mingming. All rights reserved.
//

#import "SearchViewController.h"
#import "PodcastDownloader.h"

@interface SearchViewController () <NSURLSessionDataDelegate, NSURLSessionDelegate>
@property (nonatomic, strong) UINavigationBar *navigationBar;
@property (nonatomic, strong) UIBarButtonItem *cancelButton;
@property (nonatomic, strong) UISearchDisplayController *searchController;
@property (nonatomic, strong) UISearchBar *searchBar;
@property (nonatomic, strong) UITableView *searchTableView;
@property (nonatomic, strong) NSMutableArray *searchResults;
@end

@implementation SearchViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad
{
    [self initNavBar];
}

- (void)initNavBar
{
    self.navigationBar = [[UINavigationBar alloc]initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 64)];
    [self.view addSubview:self.navigationBar];
    
    self.cancelButton = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelButtonPressed)];
    
    self.searchBar = [[UISearchBar alloc]initWithFrame:CGRectMake(0, 20, self.view.bounds.size.width, 44)];
    self.searchBar.autocorrectionType = UITextAutocorrectionTypeNo;
    self.searchBar.placeholder = @"Name of Podcast";
    self.searchBar.delegate = self;
    
    self.searchController = [[UISearchDisplayController alloc] initWithSearchBar:self.searchBar contentsController:self];
    self.searchController.delegate = self;
    self.searchController.searchResultsDelegate = self;
    self.searchController.searchResultsDataSource = self;
    self.searchController.searchResultsTitle = @"Add Postcast";
    self.searchController.displaysSearchBarInNavigationBar = YES;
    self.searchController.navigationItem.rightBarButtonItems = @[self.cancelButton];
    self.navigationBar.items = @[self.searchController.navigationItem];

}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (void)cancelButtonPressed
{
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.searchController.searchBar becomeFirstResponder];
}
- (void)viewWillDisappear:(BOOL)animated
{
    [self.searchController.searchBar resignFirstResponder];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    UIApplication *app = [UIApplication sharedApplication];
    
    if (searchString.length > 0) {
        app.networkActivityIndicatorVisible = YES;
    } else {
        app.networkActivityIndicatorVisible = NO;
    }
    
    PodcastDownloader *downloader = [PodcastDownloader sharedDownloader];
    [downloader dataTaskWithURL:[self urlForQuery:searchString] completionHandler:^(NSData *data, NSURLResponse *response, NSError *error){
        if (error) {
            if (error.code != -999) {
                NSLog(@"%@", error);
            }
        }
        
        
        dispatch_async(dispatch_get_main_queue(), ^{
            NSDictionary *result = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            NSArray *results = [result objectForKey:@"results"];
            if (results) {
                if (!self.searchResults) {
                    self.searchResults = [NSMutableArray array];
                }
            
                [self.searchResults removeAllObjects];
                [self.searchResults addObjectsFromArray:results];
                [self.searchController.searchResultsTableView reloadData];
                app.networkActivityIndicatorVisible = NO;
            }
        });
        
    }];
    
    return NO;
}

- (NSURL *)urlForQuery:(NSString *)query
{
    query = [[query stringByReplacingOccurrencesOfString:@" " withString:@"+"] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString *urlString = [NSString stringWithFormat:@"https://itunes.apple.com/search?media=podcast&entity=podcast&term=%@", query];
    NSURL *url = [NSURL URLWithString:urlString];
    return url;
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.searchResults ? 1:0;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.searchResults ? self.searchResults.count:0;
}

- (void)searchDisplayController:(UISearchDisplayController *)controller willShowSearchResultsTableView:(UITableView *)tableView
{
    [tableView setFrame:CGRectMake(0, self.navigationBar.bounds.size.height, self.view.bounds.size.width,
                                   self.view.bounds.size.height - self.navigationBar.bounds.size.height)];
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    tableView.backgroundColor = [UIColor clearColor];
    tableView.delegate = self;
    [self.view bringSubviewToFront:self.navigationBar];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"searchCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if(! cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier];
    }
    
    if(tableView == self.searchController.searchResultsTableView) {
        NSDictionary *podcast = [self.searchResults objectAtIndex:indexPath.row];
        cell.detailTextLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:12];
        cell.textLabel.text = [podcast objectForKey:@"collectionName"];
    }
    
    return cell;
}
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSDictionary *podcast = [self.searchResults objectAtIndex:indexPath.row];
    
    if ([self.delegate respondsToSelector:@selector(didAddPodcast:)]) {
        [self.delegate didAddPodcast:podcast];
    }
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

@end
