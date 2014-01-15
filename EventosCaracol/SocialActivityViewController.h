//
//  FacebookViewController.h
//  EventosCaracol
//
//  Created by Developer on 10/01/14.
//  Copyright (c) 2014 iAmStudio. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SWRevealViewController.h"

@interface SocialActivityViewController : UIViewController <UIBarPositioningDelegate, UIWebViewDelegate>
@property (strong, nonatomic) NSString *hashtagURLString;
@property (strong, nonatomic) UIColor *bgColor;
@end
