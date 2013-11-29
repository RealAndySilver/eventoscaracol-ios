//
//  EventsListViewController.h
//  EventosCaracol
//
//  Created by Developer on 20/11/13.
//  Copyright (c) 2013 iAmStudio. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SWTableViewCell.h"
#import <MessageUI/MessageUI.h>

@interface ListViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, SWTableViewCellDelegate, UIActionSheetDelegate, MFMailComposeViewControllerDelegate, MFMessageComposeViewControllerDelegate, UIPickerViewDataSource, UIPickerViewDelegate>

@property (strong, nonatomic) NSString *navigationBarTitle;
@property (strong, nonatomic) NSArray *menuItemsArray; //Of NSDictionary
@property (nonatomic) BOOL locationList;
@end
