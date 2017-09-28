//
//  MCManager.h
//  Social Studio
//
//  Created by Colby Tobin on 2/19/16.
//  Copyright © 2016 Social Studio. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MultipeerConnectivity/MultipeerConnectivity.h>
@interface MCManager : NSObject<MCSessionDelegate>

@property (nonatomic, strong) MCPeerID *peerID;
@property (nonatomic, strong) MCSession *session;
@property (nonatomic, strong) MCBrowserViewController *browser;
@property (nonatomic, strong) MCAdvertiserAssistant *advertiser;

-(void)setupPeerAndSessionWithDisplayName:(NSString *)displayName;
-(void)setupMCBrowser;
-(void)advertiseSelf:(BOOL)shouldAdvertise;

@end
