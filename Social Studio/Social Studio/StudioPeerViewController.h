//
//  StudioViewController.h
//  Social Studio
//
//  Created by Colby Tobin on 2/21/16.
//  Copyright © 2016 Social Studio. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import "AppDelegate.h"
@interface StudioPeerViewController : UIViewController <MPMediaPickerControllerDelegate>

@property (nonatomic,weak)AppDelegate *appDelegate;
@property (nonatomic,weak)MPMusicPlayerController *musicPlayer;
@end
