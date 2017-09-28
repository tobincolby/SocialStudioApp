//
//  JoinViewController.h
//  Social Studio
//
//  Created by Colby Tobin on 2/17/16.
//  Copyright © 2016 Social Studio. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MultipeerConnectivity/MultipeerConnectivity.h>
#import "AppDelegate.h"
@interface JoinViewController : UIViewController <MCBrowserViewControllerDelegate>

@property (nonatomic, strong) AppDelegate *appDelegate;

@property (nonatomic, strong)NSString *connectedHost;

@property (weak, nonatomic) IBOutlet UILabel *waitLabel;

@end
