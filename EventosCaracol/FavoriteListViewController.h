//
//  FavoriteListViewController.h
//  EventosCaracol
//
//  Created by Developer on 9/12/13.
//  Copyright (c) 2013 iAmStudio. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ServerCommunicator.h"
#import "FileSaver.h"
#import "SWTableViewCell.h"
#import "PopUpView.h"
#import "LoginViewController.h"
#import "MBHUDView.h"
#import "DetailsViewController.h"
#import "UIImageView+WebCache.h"

@interface FavoriteListViewController : UIViewController <ServerCommunicatorDelegate, UITableViewDataSource, UITableViewDelegate, SWTableViewCellDelegate, SWRevealViewControllerDelegate>

@end
