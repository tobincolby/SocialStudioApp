//
//  JoinViewController.m
//  Social Studio
//
//  Created by Colby Tobin on 2/17/16.
//  Copyright © 2016 Social Studio. All rights reserved.
//

#import "JoinViewController.h"
@interface JoinViewController ()

@end

@implementation JoinViewController



- (void)viewDidLoad {
    [super viewDidLoad];
    _waitLabel.hidden = YES;
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didReceiveDataWithNotification:)
                                                 name:@"MCDidReceiveDataNotification"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(peerDidChangeStateWithNotification:)
                                                 name:@"MCDidChangeStateNotification"
                                               object:nil];
    
    // Do any additional setup after loading the view.
}

-(void)viewDidDisappear:(BOOL)animated{
   /* [[NSNotificationCenter defaultCenter] removeObserver:self
                                                name:@"MCDidReceiveDataNotification"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                 name:@"MCDidChangeStateNotification"
                                               object:nil];*/
}

-(void)peerDidChangeStateWithNotification:(NSNotification *)notification{
    MCPeerID *peerID = [[notification userInfo] objectForKey:@"peerID"];
    NSString *peerDisplayName = peerID.displayName;
    MCSessionState state = [[[notification userInfo] objectForKey:@"state"] intValue];
    if (state != MCSessionStateConnecting) {
        if (state == MCSessionStateConnected) {
            self.connectedHost = peerDisplayName;
        }
        else if (state == MCSessionStateNotConnected){
            self.connectedHost = @"";
            //go back
            
        }
        
        
    }
    
    if ([_appDelegate.mcManager.session.connectedPeers count] > 0) {
        [_appDelegate.mcManager.browser dismissViewControllerAnimated:YES completion:nil];
        _waitLabel.hidden = NO;
    }
}


- (IBAction)joinSession:(id)sender {
    
    _appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [[_appDelegate mcManager] setupPeerAndSessionWithDisplayName:[UIDevice currentDevice].name];
    [[_appDelegate mcManager] advertiseSelf:YES];
    
    [[_appDelegate mcManager] setupMCBrowser];
    [[[_appDelegate mcManager] browser] setDelegate:self];
    [self presentViewController:[[_appDelegate mcManager] browser] animated:YES completion:nil];
    
}

-(void)browserViewControllerDidFinish:(MCBrowserViewController *)browserViewController{
    [_appDelegate.mcManager.browser dismissViewControllerAnimated:YES completion:nil];
    if ([_appDelegate.mcManager.session.connectedPeers count] > 0){
        _waitLabel.hidden = NO;
    }
}

-(void)didReceiveDataWithNotification: (NSNotification *)notification{
    NSLog(@"hi");
    MCPeerID *peerID = [[notification userInfo] objectForKey:@"peerID"];
    NSString *peerDisplayName = peerID.displayName;
    
    NSData *receivedData = [[notification userInfo] objectForKey:@"data"];
    NSString *receivedText = [[NSString alloc] initWithData:receivedData encoding:NSUTF8StringEncoding];
    
    if([receivedText isEqualToString:@"beginstudio"]){
        [self performSegueWithIdentifier:@"peergoToMediaPicker" sender:nil];
    }
}


-(void)browserViewControllerWasCancelled:(MCBrowserViewController *)browserViewController{
    [_appDelegate.mcManager.browser dismissViewControllerAnimated:YES completion:nil];
}



@end
