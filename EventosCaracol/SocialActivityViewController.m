//
//  FacebookViewController.m
//  EventosCaracol
//
//  Created by Developer on 10/01/14.
//  Copyright (c) 2014 iAmStudio. All rights reserved.
//

#import "SocialActivityViewController.h"

@interface SocialActivityViewController ()
@property (strong, nonatomic) UIActivityIndicatorView *spinner;
@property (strong, nonatomic) UIView *blockTouchesView;
@property (strong, nonatomic) UIWebView *webView;
@end

@implementation SocialActivityViewController

-(void)viewDidLoad
{
    [super viewDidLoad];
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
    
    //////////////////////////////
    self.blockTouchesView = [[UIView alloc] initWithFrame:CGRectMake(0.0,
                                                                     navigationBar.frame.origin.y + navigationBar.frame.size.height,
                                                                     self.view.frame.size.width,
                                                                     self.view.frame.size.height - (navigationBar.frame.origin.y + navigationBar.frame.size.height))];

    
    //Create a navigation item to create the title that will be
    //display in the navigation bar
    UINavigationItem *navigationItem = [[UINavigationItem alloc] init];
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0,
                                                                    0.0,
                                                                    150.0,
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
    self.webView = [[UIWebView alloc] initWithFrame:CGRectMake(0.0,
                                                                     navigationBar.frame.origin.y + navigationBar.frame.size.height,
                                                                     self.view.frame.size.width,
                                                                     self.view.frame.size.height - (navigationBar.frame.origin.y + navigationBar.frame.size.height) - 44.0)];
    self.webView.delegate = self;
    
    //We have to add a spinner to our view to show the user that the page is loading.
    self.spinner = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(self.view.frame.size.width/2 - 20.0,
                                                                                                 self.view.frame.size.height/2 - 20.0,
                                                                                                 40.0,
                                                                                                 40.0)];
    self.spinner.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
    [self.spinner startAnimating];
    
    //Create the url to be loaded by the webview
    NSURL *url = [NSURL URLWithString:self.hashtagURLString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    self.webView.scalesPageToFit = YES;
    [self.webView loadRequest:request];
   
    [self.view addSubview:self.webView];
    [self.view addSubview:self.spinner];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.revealViewController.delegate = self;
    [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
}

#pragma  mark - UIWebViewDelegate

-(void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    //We implement this delegate method to show the user that there
    //was a problem loading the page
    NSLog(@"Fallo la carga de la página");
    [self.spinner stopAnimating];
    self.spinner = nil;
    [self.spinner removeFromSuperview];
    
    [[[UIAlertView alloc] initWithTitle:@"Error de Conexión."
                               message:@"La página no se pudo cargar. Revisa que tu dispositivo esté conectado a internet y vuelve a intentarlo. " delegate:self
                     cancelButtonTitle:@"Ok"
                      otherButtonTitles:nil] show];
}

-(void)webViewDidFinishLoad:(UIWebView *)webView
{
    [self.spinner stopAnimating];
    self.spinner = nil;
    [self.spinner removeFromSuperview];
}

#pragma mark - SWRevealViewControllerDelegate

-(void)revealController:(SWRevealViewController *)revealController didMoveToPosition:(FrontViewPosition)position
{
    if (position == FrontViewPositionLeft) {
        NSLog(@"Cerré el menú");
        [self.blockTouchesView removeFromSuperview];
    }
    else if (position == FrontViewPositionRight) {
        NSLog(@"Abrí el menú");
        [self.webView addSubview:self.blockTouchesView];
    }
}

#pragma mark - UIBarPositioningDelegate

-(UIBarPosition)positionForBar:(id<UIBarPositioning>)bar{
    return UIBarPositionTopAttached;
}

@end
