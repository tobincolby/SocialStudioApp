//
//  WebViewController.h
//  Social Studio
//
//  Created by Colby Tobin on 4/6/16.
//  Copyright © 2016 Social Studio. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WebViewController : UIViewController <UIWebViewDelegate, UIAlertViewDelegate>
@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (weak, nonatomic) IBOutlet UITextField *webAddress;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *back;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *cancel;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *refresh;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *forward;
@property (nonatomic)NSInteger *numberSongs;
@property (nonatomic)NSMutableArray *songs;

-(void)loadRequestFromString:(NSString *)url;
@end
