//
//  WebViewController.m
//  EventosCaracol
//
//  Created by Developer on 5/12/13.
//  Copyright (c) 2013 iAmStudio. All rights reserved.
//

#import "WebViewController.h"

@interface WebViewController ()

@end

@implementation WebViewController

-(void)viewDidLoad
{
    [super viewDidLoad];
    
    UIWebView *webView = [[UIWebView alloc] initWithFrame:CGRectMake(0.0,
                                                                     self.navigationController.navigationBar.frame.origin.y + self.navigationController.navigationBar.frame.size.height,
                                                                     self.view.frame.size.width,
                                                                     self.view.frame.size.height - (self.navigationController.navigationBar.frame.origin.y + self.navigationController.navigationBar.frame.size.height))];
    NSURL *url = [NSURL URLWithString:self.urlString];
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url];
    webView.scalesPageToFit = YES;
    [webView loadRequest:urlRequest];
    [self.view addSubview:webView];
}

@end
