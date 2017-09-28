//
//  StudioHostViewController.h
//  Social Studio
//
//  Created by Colby Tobin on 2/22/16.
//  Copyright © 2016 Social Studio. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import "AppDelegate.h"
@interface StudioHostViewController : UIViewController <MPMediaPickerControllerDelegate>

@property (nonatomic,weak)AppDelegate *appDelegate;
@property (nonatomic,weak)MPMusicPlayerController *musicPlayer;
@property (nonatomic,strong)NSMutableArray *listOfMusic;

@end
