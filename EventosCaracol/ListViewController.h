//
//  EventsListViewController.h
//  EventosCaracol
//
//  Created by Developer on 20/11/13.
//  Copyright (c) 2013 iAmStudio. All rights reserved.
//

#import <MessageUI/MessageUI.h>
#import <UIKit/UIKit.h>
#import "SWTableViewCell.h"
#import "ServerCommunicator.h"
#import "SWRevealViewController.h"
#import "DetailsViewController.h"
#import "PopUpView.h"
#import "FileSaver.h"
#import <Social/Social.h>
#import <MessageUI/MessageUI.h>
#import <SDWebImage/UIImageView+WebCache.h>
#import "LoginViewController.h"
#import "WebViewController.h"
#import "AppDelegate.h"
#import "MBHUDView.h"

@interface ListViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, SWTableViewCellDelegate, UIActionSheetDelegate, MFMailComposeViewControllerDelegate, MFMessageComposeViewControllerDelegate, UIPickerViewDataSource, UIPickerViewDelegate, ServerCommunicatorDelegate, UIAlertViewDelegate>

@property (strong, nonatomic) NSString *navigationBarTitle;
@property (strong, nonatomic) NSArray *menuItemsArray; //Of NSDictionary
@property (nonatomic) BOOL locationList;
@property (strong, nonatomic) NSString *menuID;
@property (strong, nonatomic) NSString *objectType;
@end
