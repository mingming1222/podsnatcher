//
//  SearchViewController.h
//  podsnatcher
//
//  Created by mingming on 14-4-30.
//  Copyright (c) 2014年 mingming. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol PodcastSearchViewControllerDelegate <NSObject>
- (void)didAddPodcast:(NSDictionary *)podcast;
@end


@interface SearchViewController : UIViewController <UIScrollViewDelegate, UISearchDisplayDelegate, UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) id<PodcastSearchViewControllerDelegate> delegate;
@end
