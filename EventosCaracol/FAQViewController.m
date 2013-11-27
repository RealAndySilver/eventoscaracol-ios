//
//  FAQViewController.m
//  EventosCaracol
//
//  Created by Developer on 26/11/13.
//  Copyright (c) 2013 iAmStudio. All rights reserved.
//

#import "FAQViewController.h"
#import "SWRevealViewController.h"

@interface FAQViewController ()

@end

@implementation FAQViewController

-(void)viewDidLoad
{
    [super viewDidLoad];
    
    SWRevealViewController *revealViewController = [self revealViewController];
    
    //Create UIBarButtonItem to display the slide menu
    UIBarButtonItem *slideMenuBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Menu"
                                                                               style:UIBarButtonItemStylePlain
                                                                              target:revealViewController
                                                                              action:@selector(revealToggle:)];
    self.navigationItem.leftBarButtonItem = slideMenuBarButtonItem;
    
    [self.view addGestureRecognizer:revealViewController.panGestureRecognizer];
}

@end
