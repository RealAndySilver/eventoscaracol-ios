//
//  WebViewController.m
//  EventosCaracol
//
//  Created by Developer on 5/12/13.
//  Copyright (c) 2013 iAmStudio. All rights reserved.
//

#import "WebViewController.h"

@interface WebViewController ()
@property (strong, nonatomic) UIWebView *webView;
@property (strong, nonatomic) UIBarButtonItem *backBarButtonItem;
@property (strong, nonatomic) UIBarButtonItem *forwardBarButtonItem;
@end

@implementation WebViewController

-(void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationController.navigationBar.barTintColor = [UIColor whiteColor];
    self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:29.0/255.0 green:80.0/255.0 blue:204.0/255.0 alpha:1.0];
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor colorWithRed:144.0/255.0 green:192.0/255.0 blue:58.0/255.0 alpha:1.0]};
    
    //Create a webView to display the URL content.
    self.webView = [[UIWebView alloc] initWithFrame:CGRectMake(0.0,
                                                                     self.navigationController.navigationBar.frame.origin.y + self.navigationController.navigationBar.frame.size.height,
                                                                     self.view.frame.size.width,
                                                                     self.view.frame.size.height - (self.navigationController.navigationBar.frame.origin.y + self.navigationController.navigationBar.frame.size.height))];
    NSURL *url = [NSURL URLWithString:self.urlString];
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url];
    self.webView.scalesPageToFit = YES;
    [self.webView loadRequest:urlRequest];
    self.webView.delegate = self;
    [self.view addSubview:self.webView];
    
    /////////////////////////////////////////////////////////////////
    //Create a UIToolbar that will contain the back and forward buttons
    //of the webView.
    UIToolbar *webToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0.0,
                                                                        self.view.frame.size.height - 44.0,
                                                                        self.view.frame.size.width,
                                                                        44.0)];
    
    //Create the back and forward buttons
    self.backBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Back.png"]
                                                                          style:UIBarButtonItemStylePlain
                                                                         target:self
                                                                         action:@selector(goBack)];
    //If the user can´t go back in the webView, change the back button
    //color to gray.
    if (![self.webView canGoBack])
        self.backBarButtonItem.tintColor = [UIColor grayColor];
    
    self.forwardBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Forward.png"]
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:self
                                                                            action:@selector(goForward)];
    if (![self.webView canGoForward])
        self.forwardBarButtonItem.tintColor = [UIColor grayColor];
    
    //Add the buttons to the toolbar
    [webToolbar setItems:@[self.backBarButtonItem, self.forwardBarButtonItem]];
    [self.view addSubview:webToolbar];
}

#pragma mark - Actions

-(void)goBack
{
    [self.webView goBack];
}

-(void)goForward
{
    [self.webView goForward];
}

#pragma mark - UIWebVieDelegate

-(void)webViewDidFinishLoad:(UIWebView *)webView
{
    if (![self.webView canGoBack])
        self.backBarButtonItem.tintColor = [UIColor grayColor];
    else
        self.backBarButtonItem.tintColor = [UIColor blueColor];
    
    if (![self.webView canGoForward])
        self.forwardBarButtonItem.tintColor = [UIColor grayColor];
    else
        self.forwardBarButtonItem.tintColor = [UIColor blueColor];
}

@end
