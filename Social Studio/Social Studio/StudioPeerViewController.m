//
//  StudioViewController.m
//  Social Studio
//
//  Created by Colby Tobin on 2/21/16.
//  Copyright © 2016 Social Studio. All rights reserved.
//

#import "StudioPeerViewController.h"
#import <AVFoundation/AVFoundation.h>
@interface StudioPeerViewController ()

@end

@implementation StudioPeerViewController

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
    [self showMediaPicker];
}

-(void)peerDidChangeStateWithNotification:(NSNotification *)notification{
    MCPeerID *peerID = [[notification userInfo] objectForKey:@"peerID"];
    NSString *peerDisplayName = peerID.displayName;
    MCSessionState state = [[[notification userInfo] objectForKey:@"state"] intValue];
    if (state != MCSessionStateConnecting) {
         if (state == MCSessionStateNotConnected){
            //go back
        }
        
        
    }
}

- (void) currentSong: (MPMediaItem *)musicItem fromUser:(NSString *)name
{
    MPMediaItem *currentItem = musicItem;
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
}

-(void)disconnect{
    [self.appDelegate.mcManager.session disconnect];
    
    //go back to main page
    [self performSegueWithIdentifier:@"goToMainPage" sender:nil];
}


- (void)showMediaPicker
{
    MPMediaPickerController *mediaPicker = [[MPMediaPickerController alloc] initWithMediaTypes: MPMediaTypeAny];
    
    mediaPicker.delegate = self;
    mediaPicker.allowsPickingMultipleItems = YES;
    mediaPicker.prompt = @"Select 5 songs for the Studio";
    [self presentViewController:mediaPicker animated:YES completion:nil];
}

- (void) mediaPicker: (MPMediaPickerController *) mediaPicker didPickMediaItems: (MPMediaItemCollection *) mediaItemCollection
{
    
    [mediaPicker dismissViewControllerAnimated:YES completion:^{
        if (mediaItemCollection && mediaItemCollection != nil && [[mediaItemCollection items] count] > 0) {
            
            NSMutableArray *arrAssets = [[NSMutableArray alloc]init];
            for(int i=0;i<[[mediaItemCollection items] count];i++){
                NSURL *url = [[[mediaItemCollection items] objectAtIndex:i] valueForProperty:MPMediaItemPropertyAssetURL];
                AVAsset *asset = [AVAsset assetWithURL:url];
                [arrAssets addObject:asset];
            }
            NSDictionary *dict = @{@"datatype":@"musiclist",@"data":arrAssets};
            NSData *dataToSend = [NSKeyedArchiver archivedDataWithRootObject:dict];
            [self sendMessage:dataToSend];
            
        }
    }];
   
}

- (void) mediaPickerDidCancel: (MPMediaPickerController *) mediaPicker
{
    [mediaPicker dismissViewControllerAnimated:YES completion:nil];
}

-(void)didReceiveDataWithNotification: (NSNotification *)notification{
    MCPeerID *peerID = [[notification userInfo] objectForKey:@"peerID"];
    NSString *peerDisplayName = peerID.displayName;
    NSLog(@"hiiiiii");
    NSData *receivedData = [[notification userInfo] objectForKey:@"data"];
    NSDictionary *dict = (NSDictionary *)[NSKeyedUnarchiver unarchiveObjectWithData:receivedData];
    if([[dict objectForKey:@"datatype"] isEqualToString:@"newmusicitem"]){
        MPMediaItem *currentMusic = [dict objectForKey:@"data"];
        //setup current appearance of music
        [self currentSong:currentMusic fromUser:peerDisplayName];
    }else if([[dict objectForKey:@"datatype"] isEqualToString:@"disconnect"]){
        if ([[dict objectForKey:@"data"]isEqualToString:@"disconnecthost"]){
            //host disconnected so session is over
            //go back to main screen
        }
    }
   
}


-(void)sendMessage: (NSData *)data{
    NSArray *allPeers = _appDelegate.mcManager.session.connectedPeers;
    NSError *error;
    NSDictionary *dict = /*(NSDictionary *)*/[NSKeyedUnarchiver unarchiveObjectWithData:data];
    NSLog(dict);
    [_appDelegate.mcManager.session sendData:data
                                     toPeers:allPeers
                                    withMode:MCSessionSendDataReliable
                                       error:&error];
    
    if (error) {
        NSLog(@"%@", [error localizedDescription]);
    }
}



@end
