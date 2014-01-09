//
//  AppDelegate.h
//  EventosCaracol
//
//  Created by Andres Abril on 19/11/13.
//  Copyright (c) 2013 iAmStudio. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DetailsViewController.h"
#import <GoogleMaps/GoogleMaps.h>
#import "FileSaver.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate, UIAlertViewDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, readonly) int networkActivityCounter;
@property (nonatomic, readonly) int badgeNumberCounter;
-(void)incrementBadgeNumberCounter;
-(void)incrementNetworkActivity;
-(void)decrementNetworkActivity;
-(void)resetNetworkActivity;

@end
