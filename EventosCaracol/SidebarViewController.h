//
//  SidebarViewController.h
//  EventosCaracol
//
//  Created by Developer on 25/11/13.
//  Copyright (c) 2013 iAmStudio. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ServerCommunicator.h"
#import "SWRevealViewController.h"
#import "MenuTableViewCell.h"
#import "FileSaver.h"
#import "ListViewController.h"
#import "FavoriteListViewController.h"
#import "MapViewController.h"
#import "DetailsViewController.h"
#import "DestacadosViewController.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "AppDelegate.h"
#import "SocialActivityViewController.h"
#import <MessageUI/MessageUI.h>

@interface SidebarViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, ServerCommunicatorDelegate, UIAlertViewDelegate, UIActionSheetDelegate, UITabBarControllerDelegate, MFMailComposeViewControllerDelegate, UISearchDisplayDelegate>

@end
