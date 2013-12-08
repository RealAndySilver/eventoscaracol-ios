//
//  AppDelegate.h
//  EventosCaracol
//
//  Created by Andres Abril on 19/11/13.
//  Copyright (c) 2013 iAmStudio. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, readonly) int networkActivityCounter;
-(void)incrementNetworkActivity;
-(void)decrementNetworkActivity;
-(void)resetNetworkActivity;

@end
