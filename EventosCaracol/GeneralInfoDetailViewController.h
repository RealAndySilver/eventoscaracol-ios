//
//  GeneralInfoDetailViewController.h
//  EventosCaracol
//
//  Created by Developer on 13/01/14.
//  Copyright (c) 2014 iAmStudio. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GeneralInfoDetailViewController : UIViewController
@property (strong, nonatomic) NSString *mainTitle;
@property (strong, nonatomic) NSString *detailText;
@property (nonatomic) BOOL viewControllerWasPresentedFromASearch;
@end
