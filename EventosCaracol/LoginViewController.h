//
//  LoginViewController.h
//  EventosCaracol
//
//  Created by Developer on 19/11/13.
//  Copyright (c) 2013 iAmStudio. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ServerCommunicator.h"
#import <FacebookSDK/FacebookSDK.h>
#import "FileSaver.h"
#import "ServerCommunicator.h"
#import "DestacadosViewController.h"
#import "SidebarViewController.h"
#import "SWRevealViewController.h"
#import "MBHUDView.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "AppDelegate.h"
#import "TutorialViewController.h"

@interface LoginViewController : UIViewController <ServerCommunicatorDelegate>
@property (nonatomic) BOOL loginWasPresentedFromFavoriteButtonAlert;
@property (nonatomic) BOOL loginWasPresentedFromSideBarMenu;
@end
