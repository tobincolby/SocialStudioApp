//
//  HostViewController.m
//  Social Studio
//
//  Created by Colby Tobin on 2/17/16.
//  Copyright © 2016 Social Studio. All rights reserved.
//

#import "HostViewController.h"

@interface HostViewController (){
}

@end

@implementation HostViewController
@synthesize headingLabel = _headingLabel, nameLabel = _nameLabel, nameTextField = _nameTextField, statusLabel = _statusLabel, tableView = _tableView, startButton = _startButton;

- (void)viewDidLoad {
    [super viewDidLoad];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    
    [_nameTextField setDelegate:self];
    
    _arrConnectedDevices = [[NSMutableArray alloc] init];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(peerDidChangeStateWithNotification:)
                                                 name:@"MCDidChangeStateNotification"
                                               object:nil];
    _startButton.enabled = NO;
}

-(void)viewDidDisappear:(BOOL)animated{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                 name:@"MCDidChangeStateNotification"
                                               object:nil];
}



-(void)peerDidChangeStateWithNotification:(NSNotification *)notification{
    MCPeerID *peerID = [[notification userInfo] objectForKey:@"peerID"];
    NSString *peerDisplayName = peerID.displayName;
    MCSessionState state = [[[notification userInfo] objectForKey:@"state"] intValue];
    if (state != MCSessionStateConnecting) {
        if (state == MCSessionStateConnected) {
            [_arrConnectedDevices addObject:peerDisplayName];
            [_tableView reloadData];
            NSLog(@"connected");
        }
        else if (state == MCSessionStateNotConnected){
            if ([_arrConnectedDevices count] > 0) {
                int indexOfPeer = [_arrConnectedDevices indexOfObject:peerDisplayName];
                [_arrConnectedDevices removeObjectAtIndex:indexOfPeer];
                [_tableView reloadData];
            }
        }
        
        
        if([_arrConnectedDevices count]>0){
            _startButton.enabled = YES;
        }else{
            _startButton.enabled = NO;
        }
    }
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [_nameTextField resignFirstResponder];
    _appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];

    _appDelegate.mcManager.peerID = nil;
    _appDelegate.mcManager.session = nil;
    _appDelegate.mcManager.browser = nil;
    
    [_appDelegate.mcManager.advertiser stop];
    _appDelegate.mcManager.advertiser = nil;
    
    
    [_appDelegate.mcManager setupPeerAndSessionWithDisplayName:[NSString stringWithFormat:@"%@ - Host",_nameTextField.text]];
    [_appDelegate.mcManager setupMCBrowser];
    [_appDelegate.mcManager advertiseSelf:YES];
    
    
    return YES;
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)startAction:(id)sender
{
    
    [self sendMessage:@"beginstudio" withTry:0];
    
    
}


-(void)sendMessage: (NSString *)message withTry: (NSInteger *)count{
    NSData *dataToSend = [message dataUsingEncoding:NSUTF8StringEncoding];
    NSArray *allPeers = _appDelegate.mcManager.session.connectedPeers;
    NSError *error;
    
    [_appDelegate.mcManager.session sendData:dataToSend
                                     toPeers:allPeers
                                    withMode:MCSessionSendDataReliable
                                       error:&error];
    if (error) {
        NSLog(@"%@", [error localizedDescription]);
        if (count < 3){
        [self sendMessage:message withTry:(count + 1)];
        }
    }else{
        [self performSegueWithIdentifier:@"hostgoToMediaPicker" sender:nil];
    }

}

#pragma mark - UITableViewDataSource

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [_appDelegate.mcManager.session.connectedPeers count];
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CellIdentifier"];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"CellIdentifier"];
    }
    
    cell.textLabel.text = [[_appDelegate.mcManager.session.connectedPeers objectAtIndex:indexPath.row] displayName];
    NSLog(@"added to table: %@",[_arrConnectedDevices objectAtIndex:indexPath.row]);
    return cell;
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60.0;
}



- (IBAction)disconnectAndBack:(id)sender {
    [_appDelegate.mcManager.session disconnect];
    
    _nameTextField.enabled = YES;
    
    [_arrConnectedDevices removeAllObjects];
    [_tableView reloadData];
    [self performSegueWithIdentifier:@"backToHome" sender:self];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
