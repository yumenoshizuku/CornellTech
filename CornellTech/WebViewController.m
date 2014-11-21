//
//  WebViewController.m
//  CornellTech
//
//  Created by Fanxing Meng on 11/21/14.
//  Copyright (c) 2014 Fanxing Meng. All rights reserved.
//

#import "WebViewController.h"



@implementation WebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    UIWebView *webview = [[UIWebView alloc] init];
    webview.frame = self.view.bounds;
    
    NSURL *url = [[NSURL alloc] initWithString:@"http://54.200.176.236/room_booking"];
    
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
    [webview loadRequest:request];
    
    [self.view addSubview:webview];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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