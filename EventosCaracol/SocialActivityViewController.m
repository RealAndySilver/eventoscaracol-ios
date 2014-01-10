//
//  FacebookViewController.m
//  EventosCaracol
//
//  Created by Developer on 10/01/14.
//  Copyright (c) 2014 iAmStudio. All rights reserved.
//

#import "SocialActivityViewController.h"

@interface SocialActivityViewController ()

@end

@implementation SocialActivityViewController

-(void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = self.bgColor;
    
    /////////////////////////////////////////////////////
    //Create the left navigation bar button to open the side bar menu
    UIBarButtonItem *sideBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"SidebarIcon.png"]
                                                                          style:UIBarButtonItemStylePlain
                                                                         target:self.revealViewController
                                                                         action:@selector(revealToggle:)];
    //[self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    
    //Create a navigation bar to display the title and the
    //navigationbar button to open the slide menu
    UINavigationBar *navigationBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0.0,
                                                                                       20.0,
                                                                                       self.view.frame.size.width,
                                                                                       44.0)];
    navigationBar.delegate = self;
    navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor whiteColor]};
    navigationBar.tintColor = [UIColor whiteColor];
    navigationBar.barTintColor = [UIColor colorWithRed:29.0/255.0 green:80.0/255.0 blue:204.0/255.0 alpha:1.0];
    [self.view addSubview:navigationBar];
    
    //Create a navigation item to create the title that will be
    //display in the navigation bar
    UINavigationItem *navigationItem = [[UINavigationItem alloc] init];
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0,
                                                                    0.0,
                                                                    200.0,
                                                                    44.0)];
    titleLabel.text = @"Actividad en Redes";
    titleLabel.font = [UIFont fontWithName:@"Montserrat-Regular" size:17.0];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    
    navigationItem.titleView = titleLabel;
    navigationItem.leftBarButtonItem = sideBarButtonItem;
    [navigationBar pushNavigationItem:navigationItem animated:NO];
    
    ////////////////////////////////////////////////////////////
    //Create a web view to display the content
    UIWebView *webView = [[UIWebView alloc] initWithFrame:CGRectMake(0.0,
                                                                     navigationBar.frame.origin.y + navigationBar.frame.size.height,
                                                                     self.view.frame.size.width,
                                                                     self.view.frame.size.height - (navigationBar.frame.origin.y + navigationBar.frame.size.height) - 44.0)];
    
    //NSURL *url = [NSURL URLWithString:@"http://searchinstagram.com/cocktails"];
    //mobile.twitter.com/search/%23
    NSURL *url = [NSURL URLWithString:self.hashtagURLString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    webView.scalesPageToFit = YES;
    [webView loadRequest:request];
    [self.view addSubview:webView];
}

-(UIBarPosition)positionForBar:(id<UIBarPositioning>)bar
{
    return UIBarPositionTopAttached;
}

@end
