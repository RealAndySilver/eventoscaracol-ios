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
@property (strong, nonatomic) UIActivityIndicatorView *spinner;
@end

@implementation WebViewController

-(void)viewDidLoad
{
    [super viewDidLoad];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0,
                                                                    0.0,
                                                                    100.0,
                                                                    44.0)];
    titleLabel.text = @"eurocine 2014";
    titleLabel.font = [UIFont fontWithName:@"Montserrat-Regular" size:17.0];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.textColor = [UIColor colorWithRed:29.0/255.0 green:80.0/255.0 blue:204.0/255.0 alpha:1.0];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    self.navigationItem.titleView = titleLabel;
    
    self.navigationController.navigationBar.barTintColor = [UIColor whiteColor];
    self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:29.0/255.0 green:80.0/255.0 blue:204.0/255.0 alpha:1.0];
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor colorWithRed:144.0/255.0 green:192.0/255.0 blue:58.0/255.0 alpha:1.0]};
    
    ////////////////////////////////////////////////
    //Create the spinner
    self.spinner = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(self.view.frame.size.width/2 - 20.0,
                                                                             10.0,
                                                                             40.0,
                                                                             40.0)];
    self.spinner.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
    self.spinner.color = [UIColor colorWithRed:29.0/255.0 green:80.0/255.0 blue:204.0/255.0 alpha:1.0];
    [self.spinner startAnimating];
    
    UIBarButtonItem *spinnerBarButton = [[UIBarButtonItem alloc] initWithCustomView:self.spinner];
    self.navigationItem.rightBarButtonItem = spinnerBarButton;
    
    //Create a webView to display the URL content.
    self.webView = [[UIWebView alloc] initWithFrame:CGRectMake(0.0,
                                                                     0.0,
                                                                     self.view.frame.size.width,
                                                                     self.view.frame.size.height)];
    NSURL *url = [NSURL URLWithString:self.urlString];
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url];
    self.webView.scalesPageToFit = YES;
    [self.webView loadRequest:urlRequest];
    self.webView.delegate = self;
    [self.view addSubview:self.webView];
    [self.view addSubview:self.spinner];
    
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

-(void)webViewDidStartLoad:(UIWebView *)webView
{
    [self.spinner startAnimating];
}

-(void)webViewDidFinishLoad:(UIWebView *)webView
{
    [self.spinner stopAnimating];
    
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
