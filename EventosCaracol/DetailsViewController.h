//
//  EventDetailsViewController.h
//  EventosCaracol
//
//  Created by Developer on 20/11/13.
//  Copyright (c) 2013 iAmStudio. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ServerCommunicator.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import <MessageUI/MessageUI.h>
#import "PopUpView.h"
#import <Social/Social.h>
#import <GoogleMaps/GoogleMaps.h>
#import "FileSaver.h"
#import "LoginViewController.h"
#import "MBHUDView.h"

@interface DetailsViewController : UIViewController <ServerCommunicatorDelegate, UIAlertViewDelegate>
@property (strong, nonatomic) NSDictionary *objectInfo;
@property (strong, nonatomic) NSString *navigationBarTitle;
@property (strong, nonatomic) NSString *objectLocation;
@property (strong, nonatomic) NSString *objectTime;
@property (nonatomic) BOOL presentLocationObject;
@property (nonatomic) BOOL presentViewControllerFromSearchBar;
@end
