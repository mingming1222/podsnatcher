//
//  PlayViewController.m
//  podsnatcher
//
//  Created by mingming on 14-4-23.
//  Copyright (c) 2014年 mingming. All rights reserved.
//

#import "PlayViewController.h"
#import <FSAudioStream.h>
#import "PlayViewControllerHelper.h"

@interface PlayViewController ()
@property (nonatomic, strong) UIButton *playButton;
@property (nonatomic, strong) UIButton *pauseButton;
@property (nonatomic, strong) UIButton *fastforwardButton;
@property (nonatomic, strong) UIButton *rewindButton;

@property (nonatomic, strong) UIImageView *playerControlsRepeatView;
@property (nonatomic, strong) UIImageView *playerControlsView;
@property (nonatomic, strong) UIView *playerControlsBackgroundView;

@property (nonatomic, assign) BOOL playControlBackgroundIsHide;
@property (nonatomic, strong) UISlider *progressSlider;

@property (nonatomic, strong) NSTimer *progressUpdateTimer;
@property (nonatomic, strong) IGEpisode *currentEpisode;
@property (nonatomic, assign) double longPressSeekToTime;
@property (nonatomic, strong) NSTimer *longPressTimer;
@property (nonatomic, assign) double seekToTime;
@end

#define INTERVAL_TIME 3

@implementation PlayViewController
- (FSAudioController *)audioController
{
    if (!_audioController) {
        _audioController = [[FSAudioController alloc] init];
    }
    
    return _audioController;
}

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
    [self initPlayControlView];
    [self initPlayControlBottomView];
    
    [self addNotification];
}
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (![self.currentEpisode.url isEqual:self.url]) {

        if (self.audioController.isPlaying) {
            
            double s = self.audioController.stream.currentTimePlayed.minute * 60
                                + self.audioController.stream.currentTimePlayed.second;
            [self.delegate audioStreamWillStop:s withEpisode:self.currentEpisode];
            [self.audioController stop];
        }
        
        self.audioController.url = self.url;
        self.currentEpisode = self.episode;
 
     
        [self.audioController play];
    }

    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    [self becomeFirstResponder];
    [self playerControlsAnimationWithAction:@"hide"];
    _progressUpdateTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self
                            selector:@selector(updatePlaybackProgress) userInfo:nil repeats:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)addNotification
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(audioStreamStateDidChange:)
                                                 name:FSAudioStreamStateChangeNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(audioStreamErrorOccurred:)
                                                 name:FSAudioStreamErrorNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationDidEnterBackgroundNotification:)
                                                 name:UIApplicationDidEnterBackgroundNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationWillEnterForegroundNotification:)
                                                 name:UIApplicationWillEnterForegroundNotification
                                               object:nil];
}

- (void)audioStreamStateDidChange:(NSNotification *)notification
{
    NSDictionary *dict = [notification userInfo];
    int state = [[dict valueForKey:FSAudioStreamNotificationKey_State] intValue];
    switch (state) {
        case kFsAudioStreamRetrievingURL:
            [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
            
            self.progressSlider.enabled = NO;
            self.playButton.hidden = YES;
            self.pauseButton.hidden = NO;
            self.isPaused = NO;
            break;
            
        case kFsAudioStreamStopped:
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
            self.progressSlider.enabled = NO;
            self.playButton.hidden = NO;
            self.pauseButton.hidden = YES;
            self.isPaused = NO;
            break;
            
        case kFsAudioStreamBuffering:
            
            [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
            self.progressSlider.enabled = NO;
            self.playButton.hidden = YES;
            self.pauseButton.hidden = NO;
            self.isPaused = NO;
            break;
            
        case kFsAudioStreamSeeking:
            
            [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
            self.progressSlider.enabled = NO;
            self.playButton.hidden = YES;
            self.pauseButton.hidden = NO;
            self.isPaused = NO;
            break;
            
        case kFsAudioStreamPlaying:
            
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
            self.progressSlider.enabled = YES;
            if (!self.progressUpdateTimer) {
                self.progressUpdateTimer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                                        target:self
                                                                      selector:@selector(updatePlaybackProgress)
                                                                      userInfo:nil
                                                                       repeats:YES];
            }
            
            self.playButton.hidden = YES;
            self.pauseButton.hidden = NO;
            self.isPaused = NO;
            break;
            
        case kFsAudioStreamFailed:
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
            self.progressSlider.enabled = NO;
            self.playButton.hidden = NO;
            self.pauseButton.hidden = YES;
            self.isPaused = NO;
            break;
    }
}

- (void)audioStreamErrorOccurred:(NSNotification *)notification
{
    NSDictionary *dict = [notification userInfo];
    int errorCode = [[dict valueForKey:FSAudioStreamNotificationKey_Error] intValue];
    
    NSString *errorDescription;
    
    switch (errorCode) {
        case kFsAudioStreamErrorOpen:
            errorDescription = @"Cannot open the audio stream";
            break;
        case kFsAudioStreamErrorStreamParse:
            errorDescription = @"Cannot read the audio stream";
            break;
        case kFsAudioStreamErrorNetwork:
            errorDescription = @"Network failed: cannot play the audio stream";
            break;
        case kFsAudioStreamErrorUnsupportedFormat:
            errorDescription = @"Unsupported format";
            break;
        case kFsAudioStreamErrorStreamBouncing:
            errorDescription = @"Network failed: cannot get enough data to play";
            break;
        default:
            errorDescription = @"Unknown error occurred";
            break;
    }
    
    UIAlertView *errorView = [[UIAlertView alloc] initWithTitle:@"Error" message:errorDescription delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
    [errorView show];
}

- (void)applicationDidEnterBackgroundNotification:(NSNotification *)notification
{
}

- (void)applicationWillEnterForegroundNotification:(NSNotification *)notification
{
}

- (void)remoteControlReceivedWithEvent:(UIEvent *)receivedEvent
{
    if (receivedEvent.type == UIEventTypeRemoteControl) {
        switch (receivedEvent.subtype) {
            case UIEventSubtypeRemoteControlTogglePlayPause:
                if (self.isPaused) {
                    [self playButtonPressed];
                } else {
                    [self pauseButtonPressed];
                }
                break;
            default:
                break;
        }
    }
}


- (void)initPlayControlView
{
    UIImage *playerControls = [UIImage imageNamed:@"player-controls"];
    self.playerControlsView = [[UIImageView alloc] initWithImage:playerControls];
    [self.playerControlsView setFrame:CGRectMake(0, 0, self.view.bounds.size.width, playerControls.size.height)];
    self.playerControlsView.userInteractionEnabled = YES;
    self.playerControlsView.alpha = 0.8;
    self.playerControlsView.contentMode = UIViewContentModeCenter;
    
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(playerControlsPressed)];
    [self.playerControlsView addGestureRecognizer:singleTap];
    
    self.playButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 25, 25)];
    self.playButton.center = CGPointMake(self.playerControlsView.frame.size.width/2, self.playerControlsView.frame.size.height/2);
    [self.playButton setImage:[UIImage imageNamed:@"player-controls-play"] forState:UIControlStateNormal];
    [self.playButton addTarget:self action:@selector(playButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    self.playButton.hidden = YES;
    
    self.pauseButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 25, 25)];
    self.pauseButton.center = CGPointMake(self.playerControlsView.frame.size.width/2, self.playerControlsView.frame.size.height/2);
    [self.pauseButton setImage:[UIImage imageNamed:@"player-controls-pause"] forState:UIControlStateNormal];
    [self.pauseButton addTarget:self action:@selector(pauseButtonPressed) forControlEvents:UIControlEventTouchUpInside];
 
    
    UILongPressGestureRecognizer *fasforwardButtonlongPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self
                                                                                            action:@selector(longPressed:)];
    fasforwardButtonlongPress.minimumPressDuration = 0.8;
    fasforwardButtonlongPress.cancelsTouchesInView = NO;
    
    self.fastforwardButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 25, 25)];
    self.fastforwardButton.center = CGPointMake(self.playerControlsView.frame.size.width/6 * 4, self.playerControlsView.frame.size.height/2);
    [self.fastforwardButton setImage:[UIImage imageNamed:@"player-controls-fastforward"] forState:UIControlStateNormal];
    [self.fastforwardButton addTarget:self action:@selector(fastforwardButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [self.fastforwardButton addGestureRecognizer:fasforwardButtonlongPress];
    self.fastforwardButton.tag = 2;
    
    self.rewindButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 25, 25)];
    self.rewindButton.center = CGPointMake(self.playerControlsView.frame.size.width/3, self.playerControlsView.frame.size.height/2);
    [self.rewindButton setImage:[UIImage imageNamed:@"player-controls-rewind"] forState:UIControlStateNormal];
    [self.rewindButton addTarget:self action:@selector(rewindButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    
    UILongPressGestureRecognizer *rewindButtonLongPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self
                                                                                            action:@selector(longPressed:)];
    rewindButtonLongPress.minimumPressDuration = 0.8;
    rewindButtonLongPress.cancelsTouchesInView = NO;
    [self.rewindButton addGestureRecognizer:rewindButtonLongPress];
    self.rewindButton.tag = 1;
    
    [self.playerControlsView addSubview:self.rewindButton];
    [self.playerControlsView addSubview:self.playButton];
    [self.playerControlsView addSubview:self.pauseButton];
    [self.playerControlsView addSubview:self.fastforwardButton];
    
}

- (void)initPlayControlBottomView
{
    self.progressSlider = [[UISlider alloc] initWithFrame:CGRectMake(5, 15, self.view.bounds.size.width -10, 20)];
    [self.progressSlider addTarget:self action:@selector(playerControlsSliderChange) forControlEvents:UIControlEventValueChanged];
    [self.progressSlider addTarget:self action:@selector(playerControlsSliderTouchUpInside)
                                                                                    forControlEvents:UIControlEventTouchUpInside];
    self.progressSlider.continuous = YES;
    
    self.remainderPlayTime = [[UILabel alloc] initWithFrame:CGRectMake(self.view.bounds.size.width - 42, self.progressSlider.bounds.size.height + 15, 60, 20)];
    self.remainderPlayTime.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:8];
    self.remainderPlayTime.textColor = [UIColor whiteColor];
    
    self.alreadyPlayTime = [[UILabel alloc] initWithFrame:CGRectMake(12,self.progressSlider.bounds.size.height + 15, 60, 20)];
    self.alreadyPlayTime.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:8];
    self.alreadyPlayTime.textColor = [UIColor whiteColor];
   
    UIImage *playerControlsRepeat = [UIImage imageNamed:@"player-controls-repeat"];
    self.playerControlsRepeatView = [[UIImageView alloc] initWithImage:playerControlsRepeat];
    [self.playerControlsRepeatView setFrame:CGRectMake(0, self.playerControlsView.bounds.size.height, self.view.bounds.size.width, 10 + self.progressSlider.bounds.size.height + self.remainderPlayTime.bounds.size.height)];
 
    self.playerControlsRepeatView.userInteractionEnabled = YES;
    [self.playerControlsRepeatView addSubview:self.progressSlider];
    [self.playerControlsRepeatView addSubview:self.alreadyPlayTime];
    [self.playerControlsRepeatView addSubview:self.remainderPlayTime];
    
    self.playerControlsBackgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - self.playerControlsView.bounds.size.height - self.playerControlsRepeatView.bounds.size.height, self.view.bounds.size.width, self.playerControlsView.bounds.size.height + self.playerControlsRepeatView.bounds.size.height)];
    
    [self.playerControlsBackgroundView addSubview:self.playerControlsView];
    [self.playerControlsBackgroundView addSubview:self.playerControlsRepeatView];
    [self.view addSubview:self.playerControlsBackgroundView];
}

- (void)updatePlaybackProgress
{
    if (self.audioController.stream.continuous) {
        self.progressSlider.enabled = NO;
        self.progressSlider.value = 0;
        self.alreadyPlayTime.text = @"00:00:00";
        self.remainderPlayTime.text = @"00:00:00";
    } else {
        
        self.progressSlider.enabled = YES;
        double s = self.audioController.stream.currentTimePlayed.minute * 60 + self.audioController.stream.currentTimePlayed.second;
        [self updatePlayTime:s];
        
   }
}

- (void)updatePlayTime:(double)currentTime
{
    
    double durationTime = self.audioController.stream.duration.minute * 60 + self.audioController.stream.duration.second;
    if (currentTime >= durationTime) {
        currentTime = durationTime;
    } else if (currentTime <= 0) {
        currentTime = 0;
    }
    
    self.progressSlider.value = currentTime / durationTime;
    
    timePosition playedTime = [PlayViewControllerHelper getPlayedTime:currentTime];
    timePosition reminderTime = [PlayViewControllerHelper getremainderTimewithDurationTime:durationTime withPlayedTime:currentTime];
   
    self.alreadyPlayTime.text = [NSString stringWithFormat:@"%02i:%02i:%02i", playedTime.hour, playedTime.minute, playedTime.second];
    self.remainderPlayTime.text = [NSString stringWithFormat:@"%02i:%02i:%02i",
                                                reminderTime.hour, reminderTime.minute, reminderTime.second];
    
    [self.delegate audioStreamPlaying:currentTime withEpisode:self.episode];
}

- (void)playButtonPressed
{
    if (self.isPaused) {
        [self.audioController pause];
        self.isPaused = NO;
    } else {
        [self.audioController play];
    }
    
    self.playButton.hidden = YES;
    self.pauseButton.hidden = NO;
}

- (void)pauseButtonPressed
{
    double s = self.audioController.stream.currentTimePlayed.minute * 60
                                + self.audioController.stream.currentTimePlayed.second;
    
    [self.delegate audioStreamWillPause:s];
    [self.audioController pause];
    self.isPaused = YES;
    self.pauseButton.hidden = YES;
    self.playButton.hidden = NO;
}

-(void)longPressed:(UILongPressGestureRecognizer *)gesture
{
    [self.longPressTimer invalidate];
    self.longPressTimer = nil;
    unsigned currentTime = self.audioController.stream.currentTimePlayed.minute * 60 + self.audioController.stream.currentTimePlayed.second;
    
    if ([gesture state] == UIGestureRecognizerStateBegan) {
        self.longPressSeekToTime = currentTime;
        self.longPressTimer = [NSTimer scheduledTimerWithTimeInterval:0.2 target:self
                                                             selector:@selector(fastforwardButtonPressed)
                                                             userInfo: [NSNumber numberWithDouble:gesture.view.tag]
                                                                        repeats:YES];
        
    } else if ([gesture state] == UIGestureRecognizerStateEnded) {
        [self.longPressTimer invalidate];
        self.longPressTimer = nil;
        
        [self seekToNewTime:self.longPressSeekToTime];
    } else if ([gesture state] == UIGestureRecognizerStateCancelled || [gesture state] == UIGestureRecognizerStateFailed) {
         [self.longPressTimer invalidate];
         self.longPressTimer = nil;
         self.longPressSeekToTime = 0;
    }
}


- (void)handleTimer:(NSTimer *)timer
{
    if ([[[timer userInfo] objectForKey:@"tag"] doubleValue] == 2) {
        self.longPressSeekToTime = self.longPressSeekToTime + INTERVAL_TIME;
    } else {
        self.longPressSeekToTime = self.longPressSeekToTime - INTERVAL_TIME;
    }
    
    [self updatePlayTime:self.longPressSeekToTime];
}

- (void)fastforwardButtonPressed
{
    if (self.longPressSeekToTime) {
        return;
    }
    
    [self.progressUpdateTimer invalidate];
    self.progressUpdateTimer = nil;
    
    double currentTime = self.audioController.stream.currentTimePlayed.minute * 60
                                            + self.audioController.stream.currentTimePlayed.second;
    
    currentTime = currentTime + INTERVAL_TIME;
    [self updatePlayTime:currentTime];
    [self seekToNewTime:currentTime];
}

- (void)rewindButtonPressed
{
    if (self.longPressSeekToTime) {
        return;
    }
 
    [self.progressUpdateTimer invalidate];
    self.progressUpdateTimer = nil;
    
    double currentTime = self.audioController.stream.currentTimePlayed.minute * 60
                                            + self.audioController.stream.currentTimePlayed.second;
    currentTime = currentTime - INTERVAL_TIME;

    [self updatePlayTime:currentTime];
    [self seekToNewTime:currentTime];
    
}

- (void)playerControlsSliderChange
{
    double seekToPoint = self.progressSlider.value;
    
    [self.progressUpdateTimer invalidate];
    self.progressUpdateTimer = nil;
    
    double time = (self.audioController.stream.duration.minute * 60 +
                            self.audioController.stream.duration.second) * seekToPoint;
    
    self.seekToTime = time;
    [self updatePlayTime:time];
}

- (void)playerControlsSliderTouchUpInside
{
    [self seekToNewTime:self.seekToTime];
    self.seekToTime = 0;
}

- (void)seekToNewTime:(double)seekTime
{
    double durationTime = self.audioController.stream.duration.minute * 60 + self.audioController.stream.duration.second;
    if (seekTime >= durationTime) {
        seekTime = durationTime;
    } else if (seekTime <= 0) {
        seekTime = 0;
    }
    
    int second, minute;
    second = (int)seekTime % 60;
    minute = (int)seekTime / 60;
    
    FSStreamPosition pos;
    pos.minute = minute;
    pos.second = second;
    
    [self.audioController.stream seekToPosition:pos];
}


- (void)playerControlsPressed
{
    if (self.playControlBackgroundIsHide) {
        [self playerControlsAnimationWithAction:@"show"];
    } else {
        [self playerControlsAnimationWithAction:@"hide"];
    }
}
- (void)playerControlsAnimationWithAction:(NSString *)action
{
    [UIView animateWithDuration:0.5 animations:^{
        if ([action isEqualToString:@"show"]) {
            [self.playerControlsBackgroundView setFrame:CGRectMake(0, self.view.frame.size.height - self.playerControlsView.bounds.size.height - self.playerControlsRepeatView.bounds.size.height, self.view.bounds.size.width, self.playerControlsView.bounds.size.height + self.playerControlsRepeatView.bounds.size.height)];
            self.playControlBackgroundIsHide = NO;
    
        } else if ([action isEqualToString:@"hide"]) {
            [self.playerControlsBackgroundView setFrame:CGRectMake(0, self.view.frame.size.height - self.playerControlsView.bounds.size.height - 8, self.view.bounds.size.width, self.playerControlsView.bounds.size.height + 8)];
            self.playControlBackgroundIsHide = YES;
        }
    }];
}

@end
