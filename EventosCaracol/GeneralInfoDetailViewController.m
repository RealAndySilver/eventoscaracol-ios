//
//  GeneralInfoDetailViewController.m
//  EventosCaracol
//
//  Created by Developer on 13/01/14.
//  Copyright (c) 2014 iAmStudio. All rights reserved.
//

#import "GeneralInfoDetailViewController.h"

@interface GeneralInfoDetailViewController ()

@end

@implementation GeneralInfoDetailViewController

-(void)viewDidLoad
{
    [super viewDidLoad];
    
    if (self.viewControllerWasPresentedFromASearch)
    {
        UIBarButtonItem *dismissViewControllerBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"X"
                                                                                               style:UIBarButtonItemStylePlain
                                                                                              target:self
                                                                                              action:@selector(dismissVC)];
        self.navigationItem.leftBarButtonItem = dismissViewControllerBarButtonItem;
    }
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(40.0,
                                                                    self.navigationController.navigationBar.frame.origin.x + self.navigationController.navigationBar.frame.size.height + 40.0,
                                                                    self.view.frame.size.width - 80.0,
                                                                    60.0)];
    titleLabel.text = self.mainTitle;
    titleLabel.numberOfLines = 0;
    titleLabel.font = [UIFont fontWithName:@"Montserrat-Regular" size:15.0];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:titleLabel];
    
    UITextView *detailLabel = [[UITextView alloc] initWithFrame:CGRectMake(20.0,
                                                                     titleLabel.frame.origin.y + titleLabel.frame.size.height + 20.0, self.view.frame.size.width - 40.0,
                                                                     self.view.frame.size.height - (titleLabel.frame.origin.y + titleLabel.frame.size.height + 20.0) - 40.0)];
    detailLabel.font = [UIFont fontWithName:@"Montserrat-Regular" size:15.0];
    detailLabel.textAlignment = NSTextAlignmentJustified;
    detailLabel.textColor = [UIColor lightGrayColor];
    detailLabel.text = @"Lorem ipsum dolor sit amet, consectetuer adipiscing elit, sed diam nonummy nibh euismod tincidunt ut laoreet dolore magna aliquam erat volutpat. Ut wisi enim ad minim veniam, quis nostrud exerci tation ullamcorper suscipit lobortis nisl ut aliquip ex ea commodo consequat. Duis autem vel eum iriure dolor in hendrerit in vulputate velit esse molestie consequat, vel illum dolore eu feugiat nulla facilisis at vero eros et accumsan et iusto odio dignissim qui blandit praesent luptatum zzril delenit augue duis dolore te feugait nulla facilisi. Nam liber tempor cum soluta nobis eleifend option congue nihil imperdiet doming id quod mazim placerat facer possim assum. Typi non haben";
    [self.view addSubview:detailLabel];
}

-(void)dismissVC
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
