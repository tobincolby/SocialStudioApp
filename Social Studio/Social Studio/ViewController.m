//
//  ViewController.m
//  Social Studio
//
//  Created by Colby Tobin on 2/17/16.
//  Copyright © 2016 Social Studio. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    NSMutableArray *imgArr = [[NSMutableArray alloc]init];
    for (int i=0;i<30;i++){
        [imgArr addObject:[UIImage imageNamed:[NSString stringWithFormat:@"frame_%i.gif",i ]]];
    }
    
    UIImage *img = [UIImage animatedImageWithImages:imgArr duration:1];
    self.gifTester.image = img;
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
