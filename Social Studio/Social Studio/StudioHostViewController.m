//
//  StudioHostViewController.m
//  Social Studio
//
//  Created by Colby Tobin on 2/22/16.
//  Copyright © 2016 Social Studio. All rights reserved.
//

#import "StudioHostViewController.h"
#import <MediaPlayer/MediaPlayer.h>
@interface StudioHostViewController (){
    NSInteger *count;
}

@end

@implementation StudioHostViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didReceiveDataWithNotification:)
                                                 name:@"MCDidReceiveDataNotification"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(peerDidChangeStateWithNotification:)
                                                 name:@"MCDidChangeStateNotification"
                                               object:nil];
    _appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    _musicPlayer = [MPMusicPlayerController systemMusicPlayer];
    _listOfMusic = [[NSMutableArray alloc]init];
    count = 0;
    [self showMediaPicker];
}

-(void)disconnect{//disconnects and goes back to main page
    NSDictionary *dict = @{@"datatype":@"disconnect",@"data":@"disconnecthost"};
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:dict];
    [self sendMessage:data];
    
    [self.appDelegate.mcManager.session disconnect];
    //go back to main page
    [self performSegueWithIdentifier:@"goToMainPage" sender:nil];
}


-(void)peerDidChangeStateWithNotification:(NSNotification *)notification{
    MCPeerID *peerID = [[notification userInfo] objectForKey:@"peerID"];
    NSString *peerDisplayName = peerID.displayName;
    MCSessionState state = [[[notification userInfo] objectForKey:@"state"] intValue];
    if (state != MCSessionStateConnecting) {
         if (state == MCSessionStateNotConnected){
             BOOL peersExist = ([[_appDelegate.mcManager.session connectedPeers] count] != 0);
             if(!peersExist){
                 //go back
                 [self disconnect];
             }
        }
        
    }
}

- (void) handle_NowPlayingItemChanged: (id) notification
{
    MPMediaItem *currentItem = [_musicPlayer nowPlayingItem];
    UIImage *artworkImage = [UIImage imageNamed:@"noArtworkImage.png"];
    MPMediaItemArtwork *artwork = [currentItem valueForProperty: MPMediaItemPropertyArtwork];
    
    if (artwork) {
        artworkImage = [artwork imageWithSize: CGSizeMake (200, 200)];
    }
    
    // [artworkImageView setImage:artworkImage];
    
    NSString *titleString = [currentItem valueForProperty:MPMediaItemPropertyTitle];
    if (titleString) {
        //titleLabel.text = [NSString stringWithFormat:@"Title: %@",titleString];
    } else {
        //titleLabel.text = @"Title: Unknown title";
    }
    
    NSString *artistString = [currentItem valueForProperty:MPMediaItemPropertyArtist];
    if (artistString) {
        // artistLabel.text = [NSString stringWithFormat:@"Artist: %@",artistString];
    } else {
        // artistLabel.text = @"Artist: Unknown artist";
    }
    
    NSString *albumString = [currentItem valueForProperty:MPMediaItemPropertyAlbumTitle];
    if (albumString) {
        //albumLabel.text = [NSString stringWithFormat:@"Album: %@",albumString];
    } else {
        //albumLabel.text = @"Album: Unknown album";
    }
    
    
    NSDictionary *dict = @{@"datatype":@"newmusicitem",
                           @"data":currentItem};
    
    NSData *dataToSend = [NSKeyedArchiver archivedDataWithRootObject:dict];
    [self sendMessage:dataToSend];
    
}

-(void)sendMessage: (NSData *)dataToSend{
    NSArray *allPeers = _appDelegate.mcManager.session.connectedPeers;
    NSError *error;
    
    [_appDelegate.mcManager.session sendData:dataToSend
                                     toPeers:allPeers
                                    withMode:MCSessionSendDataReliable
                                       error:&error];
    
    if (error) {
        NSLog(@"%@", [error localizedDescription]);
    }
}

- (void) handle_PlaybackStateChanged: (id) notification
{
    MPMusicPlaybackState playbackState = [_musicPlayer playbackState];
    
    if (playbackState == MPMusicPlaybackStatePaused) {
        //[playPauseButton setImage:[UIImage imageNamed:@"playButton.png"] forState:UIControlStateNormal];
        
    } else if (playbackState == MPMusicPlaybackStatePlaying) {
        //[playPauseButton setImage:[UIImage imageNamed:@"pauseButton.png"] forState:UIControlStateNormal];
        
    } else if (playbackState == MPMusicPlaybackStateStopped) {
        
        //[playPauseButton setImage:[UIImage imageNamed:@"playButton.png"] forState:UIControlStateNormal];
        [_musicPlayer stop];
        
    }
}

- (void) handle_VolumeChanged: (id) notification
{
    //[volumeSlider setValue:[musicPlayer volume]];
}

- (void)showMediaPicker
{
    MPMediaPickerController *mediaPicker = [[MPMediaPickerController alloc] initWithMediaTypes: MPMediaTypeAny];
    
    mediaPicker.delegate = self;
    mediaPicker.allowsPickingMultipleItems = YES;
    mediaPicker.prompt = @"Select 5 Songs for the Studio";
    
    [self presentViewController:mediaPicker animated:YES completion:nil];
}

- (void) mediaPicker: (MPMediaPickerController *) mediaPicker didPickMediaItems: (MPMediaItemCollection *) mediaItemCollection
{

    

    [mediaPicker dismissViewControllerAnimated:YES completion:^{
        if (mediaItemCollection) {
            
            [_listOfMusic addObjectsFromArray:[mediaItemCollection items]];
            //[_musicPlayer setQueueWithItemCollection: mediaItemCollection];
            //[_musicPlayer play];
            count += 1;
            
            if(count == [[_appDelegate.mcManager.session connectedPeers] count] + 1){
                for(int i=0;i<[_listOfMusic count];i++){
                    int r1 = arc4random() % [_listOfMusic count];
                    int r2 = arc4random() % [_listOfMusic count];
                    [_listOfMusic exchangeObjectAtIndex:r1 withObjectAtIndex:r2];
                }
                MPMediaItemCollection *coll = [[MPMediaItemCollection alloc]initWithItems:_listOfMusic];
                [_musicPlayer setQueueWithItemCollection:coll];
                NSLog(@"hi2");
                [_musicPlayer play];
            }
        }
    }];

    
}

- (void) mediaPickerDidCancel: (MPMediaPickerController *) mediaPicker
{
    [mediaPicker dismissViewControllerAnimated:YES completion:nil];
}


- (void) registerMediaPlayerNotifications
{
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    
    [notificationCenter addObserver: self
                           selector: @selector (handle_NowPlayingItemChanged:)
                               name: MPMusicPlayerControllerNowPlayingItemDidChangeNotification
                             object: _musicPlayer];
    
    [notificationCenter addObserver: self
                           selector: @selector (handle_PlaybackStateChanged:)
                               name: MPMusicPlayerControllerPlaybackStateDidChangeNotification
                             object: _musicPlayer];
    
    [notificationCenter addObserver: self
                           selector: @selector (handle_VolumeChanged:)
                               name: MPMusicPlayerControllerVolumeDidChangeNotification
                             object: _musicPlayer];
    
    [_musicPlayer beginGeneratingPlaybackNotifications];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)didReceiveDataWithNotification: (NSNotification *)notification{
    MCPeerID *peerID = [[notification userInfo] objectForKey:@"peerID"];
    NSString *peerDisplayName = peerID.displayName;
    
    NSData *receivedData = [[notification userInfo] objectForKey:@"data"];
    //NSLog([[notification userInfo] objectForKey:@"data"]);
    NSDictionary *dict = (NSDictionary *)[NSKeyedUnarchiver unarchiveObjectWithData:receivedData];
    NSString *datatype = [dict objectForKey:@"datatype"];
    NSLog(@"hi");
    if([datatype isEqualToString:@"anothernewsong"]){
        count++;
        MPMediaItemCollection *collectionFromPeer = [[MPMediaItemCollection alloc] initWithItems:[(MPMediaItemCollection*)[dict objectForKey:@"data"] items]];
        [_listOfMusic addObjectsFromArray:[collectionFromPeer items]];
        if(count == [[_appDelegate.mcManager.session connectedPeers] count] + 1){
            for(int i=0;i<[_listOfMusic count];i++){
                int r1 = arc4random() % [_listOfMusic count];
                int r2 = arc4random() % [_listOfMusic count];
                [_listOfMusic exchangeObjectAtIndex:r1 withObjectAtIndex:r2];
            }
            MPMediaItemCollection *coll = [[MPMediaItemCollection alloc]initWithItems:_listOfMusic];
            [_musicPlayer setQueueWithItemCollection:coll];
            NSLog(@"hi3");
            [_musicPlayer play];
        }
    }
    
    
}



@end
