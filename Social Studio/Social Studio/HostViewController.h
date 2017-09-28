//
//  HostViewController.h
//  Social Studio
//
//  Created by Colby Tobin on 2/17/16.
//  Copyright © 2016 Social Studio. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
@interface HostViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>
-(void)peerDidChangeStateWithNotification:(NSNotification *)notification;
@property (nonatomic, strong) NSMutableArray *arrConnectedDevices;

@property (nonatomic, weak) IBOutlet UILabel *headingLabel;
@property (nonatomic, weak) IBOutlet UILabel *nameLabel;
@property (nonatomic, weak) IBOutlet UITextField *nameTextField;
@property (nonatomic, weak) IBOutlet UILabel *statusLabel;
@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, weak) IBOutlet UIButton *startButton;
@property (nonatomic, strong) AppDelegate *appDelegate;


@end
