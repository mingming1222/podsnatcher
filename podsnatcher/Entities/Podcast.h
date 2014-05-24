//
//  Podcast.h
//  podsnatcher
//
//  Created by mingming on 14-5-21.
//  Copyright (c) 2014年 mingming. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class IGEpisode;

@interface Podcast : NSManagedObject

@property (nonatomic, retain) NSDate * addTime;
@property (nonatomic, retain) NSString * artistName;
@property (nonatomic, retain) NSData * artworkImage;
@property (nonatomic, retain) NSNumber * collectionId;
@property (nonatomic, retain) NSString * feedURL;
@property (nonatomic, retain) NSString * link;
@property (nonatomic, retain) NSString * summary;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSDate * lastUpdate;
@property (nonatomic, retain) NSSet *item;
@end

@interface Podcast (CoreDataGeneratedAccessors)

- (void)addItemObject:(IGEpisode *)value;
- (void)removeItemObject:(IGEpisode *)value;
- (void)addItem:(NSSet *)values;
- (void)removeItem:(NSSet *)values;

@end
