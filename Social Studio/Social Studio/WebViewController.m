//
//  WebViewController.m
//  Social Studio
//
//  Created by Colby Tobin on 4/6/16.
//  Copyright © 2016 Social Studio. All rights reserved.
//

#import "WebViewController.h"
#import <AVFoundation/AVFoundation.h>
@interface WebViewController ()

@end

@implementation WebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.numberSongs = 0;
    self.songs = [[NSMutableArray alloc]init];
    if([[NSUserDefaults standardUserDefaults]objectForKey:@"songs"]!=nil){
        self.songs = [[NSUserDefaults standardUserDefaults]objectForKey:@"songs"];
    }
    
    self.webView.delegate = self;
    self.webAddress.keyboardType = UIKeyboardTypeURL;
    self.webAddress.autocapitalizationType = UITextAutocapitalizationTypeNone;
    self.webAddress.clearButtonMode = UITextFieldViewModeWhileEditing;
    [self.webAddress addTarget:self action:@selector(loadRequestFromAddressField:) forControlEvents:UIControlEventEditingDidEndOnExit];
    [self loadRequestFromString:self.webAddress.text];
}

-(void)loadRequestFromAddressField:(id)addressField{
    NSString *urlString = [addressField text];
    
    [self loadRequestFromString:urlString];
}

-(void)loadRequestFromString:(NSString *)urlString{
    NSURL *url = [NSURL URLWithString:urlString];
    if(!url.scheme)
    {
        NSString* modifiedURLString = [NSString stringWithFormat:@"http://%@", urlString];
        url = [NSURL URLWithString:modifiedURLString];
    }
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url];
    [self.webView loadRequest:urlRequest];
}

-(void)updateButtons{
    self.forward.enabled = self.webView.canGoForward;
    self.back.enabled = self.webView.canGoBack;
    self.cancel.enabled = self.webView.loading;
}

-(void)updateAddress:(NSURLRequest *)request{
    NSURL *url = [request mainDocumentURL];
    NSString *string = [url absoluteString];
    self.webAddress.text = string;
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    [self updateButtons];
   

}
- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    NSLog(@"hi");
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    [self updateButtons];
    [self updateAddress:[webView request]];
    
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if(buttonIndex == 0){
        NSURL *urlTarget = self.webView.request.URL;
        NSString *name = @"Testing testing testing";
        NSDictionary *dict = @{@"name":name,@"url":urlTarget};
        [self.songs addObject:dict];
   /* NSData *data = [NSData dataWithContentsOfURL:self.webView.request.URL];
    NSURL *tmpDirURL = [NSURL fileURLWithPath:NSTemporaryDirectory() isDirectory:YES];
    NSURL *fileURL = [[tmpDirURL URLByAppendingPathComponent:@"temp"] URLByAppendingPathExtension:@"mp3"];
    [data writeToURL:fileURL options:NSAtomicWrite error:nil];
    AVURLAsset *asset = [AVURLAsset URLAssetWithURL:fileURL options:nil];
    
        NSString *path = [NSHomeDirectory() stringByAppendingFormat:@"/Documents/%isong.mp3",self.numberSongs];
        NSURL *outputURL = [NSURL URLWithString:path];
        AVAssetExportSession *exporter = [[AVAssetExportSession alloc]initWithAsset:asset presetName:AVAssetExportPresetPassthrough];
        exporter.outputURL = outputURL;
        exporter.outputFileType = @"com.apple.quicktime-movie";
        [exporter exportAsynchronouslyWithCompletionHandler:^{
            NSLog(@"starting");
                self.numberSongs++;
                NSLog(@"Success - %lu",self.numberSongs);
            
        }];
        */
    }else{
        [self.webView goBack];
    }

}
-(void)viewWillDisappear:(BOOL)animated{
    //[[NSUserDefaults standardUserDefaults]setInteger:*(self.numberSongs) forKey:@"numSongs"];
    [[NSUserDefaults standardUserDefaults]setObject:self.songs forKey:@"songs"];

}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    [self updateButtons];
}

-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
    [self updateAddress:request];
    NSURL *url = [request URL];
    if([[[url pathExtension] lowercaseString] isEqualToString:@"mp3"]){
        NSLog(@"hi");
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Download Song?" message:@"Would you like to download this song?" delegate:self cancelButtonTitle:nil otherButtonTitles:@"Yes",@"No", nil];
        [alert show];
        return NO;
    }
    
    return YES;
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
