//
//  AppDelegate.m
//  EventosCaracol
//
//  Created by Andres Abril on 19/11/13.
//  Copyright (c) 2013 iAmStudio. All rights reserved.
//

#import <GoogleMaps/GoogleMaps.h>
#import "FileSaver.h"
#import "AppDelegate.h"

@interface AppDelegate()
@property (nonatomic, readwrite) int networkActivityCounter;
@property (nonatomic, readwrite) int badgeNumberCounter;
@end

@implementation AppDelegate

#pragma mark - Application LifeCycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    sleep(2);
    [GMSServices provideAPIKey:@"AIzaSyC8pPYE33R1zoeR1GuOMrThOw3nwJrgXtE"];
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
    
    NSString *deviceBrand = @"Apple";
    NSString *deviceModel = [[UIDevice currentDevice] model];
    NSString *systemVersion = [[UIDevice currentDevice] systemVersion];
    
    NSDictionary *dic = @{@"Model": deviceModel, @"SystemVersion" : systemVersion, @"Brand" : deviceBrand};
    FileSaver *fileSaver = [[FileSaver alloc] init];
    [fileSaver setDictionary:@{@"app_id": @"528c1c396e9f990000000001"} withKey:@"app_id"];
    [fileSaver setDictionary:dic withKey:@"DeviceInfo"];
    
    ////////////////////////////////////////////////////////////////////////
    //Si la aplicación inicia con una notificación
    /*UILocalNotification *localNotification = [launchOptions objectForKey:UIApplicationLaunchOptionsLocalNotificationKey];
    if (localNotification)
    {
        application.applicationIconBadgeNumber = 0;
        NSLog(@"cambie el badge");
    }*/
    application.applicationIconBadgeNumber = 0;
    
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.    
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    [[NSNotificationCenter defaultCenter] postNotificationName:@"foreground" object:nil];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    application.applicationIconBadgeNumber = 0;
    self.badgeNumberCounter = 0;
    NSArray *localNotifications = [[UIApplication sharedApplication] scheduledLocalNotifications];
    NSLog(@"Number of local notifications pending: %d", [localNotifications count]);
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    for (int i = 0; i < [localNotifications count]; i++)
    {
        UILocalNotification *localNotification = localNotifications[i];
        localNotification.applicationIconBadgeNumber = i + 1;
        NSLog(@"Local notification badge number: %d", localNotification.applicationIconBadgeNumber);
        [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
    }
    
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark - Notifications

-(void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    FileSaver *file = [[FileSaver alloc] init];
    [file setToken:[[[[NSString stringWithFormat:@"%@", deviceToken] stringByReplacingOccurrencesOfString:@" " withString:@""] stringByReplacingOccurrencesOfString:@"<" withString:@""] stringByReplacingOccurrencesOfString:@">" withString:@""]];
    
    NSString *result = [NSString stringWithFormat:@"El token que se guardó fue %@", [file getToken]];
    NSLog(@"%@", result);
}

-(void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
    if ([application applicationState] == UIApplicationStateActive)
    {
        [[[UIAlertView alloc] initWithTitle:nil
                                    message:@"¡Uno de los eventos que tienes como favorito empezará dentro de una hora!"
                                   delegate:self
                          cancelButtonTitle:@"Ok"
                          otherButtonTitles:nil] show];
    }
    application.applicationIconBadgeNumber = 0;
}

-(void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    NSLog(@"Error obteniendo el token, error: %@", error);
}

-(void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"notification" object:userInfo];
}

#pragma mark - NetworkActivityIndicator

-(void)incrementNetworkActivity
{
    self.networkActivityCounter ++;
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

-(void)decrementNetworkActivity
{
    if (self.networkActivityCounter > 0)
        self.networkActivityCounter --;
    
    if (self.networkActivityCounter == 0)
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

-(void)resetNetworkActivity
{
    self.networkActivityCounter = 0;
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

#pragma mark - BadgeNumberCounter

-(void)incrementBadgeNumberCounter
{
    self.badgeNumberCounter++;
}

@end
