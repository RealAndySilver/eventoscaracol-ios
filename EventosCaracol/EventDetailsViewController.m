//
//  EventDetailsViewController.m
//  EventosCaracol
//
//  Created by Developer on 20/11/13.
//  Copyright (c) 2013 iAmStudio. All rights reserved.
//

#import "EventDetailsViewController.h"

@interface EventDetailsViewController ()

@end

@implementation EventDetailsViewController

-(void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.title = @"Detalles Evento";
    
    //Create the view's content and added it as subview of self.view
    UIImageView *eventImage = [[UIImageView alloc] initWithFrame:CGRectMake(20.0, 77.0, 280.0, 200.0)];
    eventImage.backgroundColor = [UIColor cyanColor];
    [self.view addSubview:eventImage];
    
    UIButton *favoriteButton = [[UIButton alloc] initWithFrame:CGRectMake(20.0, 285.0, 44.0, 44.0)];
    [favoriteButton setTitle:@"Fav" forState:UIControlStateNormal];
    [favoriteButton setBackgroundColor:[UIColor purpleColor]];
    [self.view addSubview:favoriteButton];
    
    UILabel *eventName = [[UILabel alloc] initWithFrame:CGRectMake(74.0, 285.0, 206, 44.0)];
    eventName.text = @"Desfile de las flores";
    eventName.font = [UIFont fontWithName:@"@Helvetica" size:15.0];
    [self.view addSubview:eventName];
    
    UILabel *eventLocationLabel = [[UILabel alloc] initWithFrame:CGRectMake(74.0, 340.0, 200.0, 20.0)];
    eventLocationLabel.text = @"Plaza Cervantes";
    eventLocationLabel.font = [UIFont fontWithName:@"Helvetica" size:12.0];
    [self.view addSubview:eventLocationLabel];
    
    UILabel *eventTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(74.0, 360.0, 200.0, 20.0)];
    eventTimeLabel.text = @"11:30AM";
    eventTimeLabel.font = [UIFont fontWithName:@"Helvetica" size:12.0];
    [self.view addSubview:eventTimeLabel];
    
    
    UITextView *eventDescription = [[UITextView alloc] initWithFrame:CGRectMake(20.0,
                                                                                self.view.frame.size.height/1.5,
                                                                                self.view.frame.size.width-40,
                                                                                self.view.frame.size.height-self.view.frame.size.height/1.5)];
    eventDescription.text = @"Lorem ipsum dolor sit amet, consectetuer adipiscing elit, sed diam nonummy nibh euismod tincidunt ut laoreet dolore magna aliquam erat volutpat. Ut wisi enim ad minim veniam, quis nostrud exerci tation ullamcorper suscipit lobortis nisl ut aliquip ex ea commodo consequat. Duis autem vel eum iriure dolor in hendrerit in vulputate velit esse molestie consequat, vel illum dolore eu feugiat nulla facilisis at vero eros et accumsan et iusto odio dignissim qui blandit praesent luptatum zzril delenit augue duis dolore te feugait nulla facilisi. Nam liber tempor cum soluta nobis eleifend option congue nihil imperdiet doming id quod mazim placerat facer possim assum. Typi non haben";
    eventDescription.font = [UIFont fontWithName:@"Helvetica" size:14.0];
    eventDescription.selectable = NO;
    eventDescription.editable = NO;
    eventDescription.scrollEnabled = YES;
    eventDescription.userInteractionEnabled = YES;
    [self.view addSubview:eventDescription];
}









@end
