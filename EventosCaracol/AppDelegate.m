//
//  AppDelegate.m
//  EventosCaracol
//
//  Created by Andres Abril on 19/11/13.
//  Copyright (c) 2013 iAmStudio. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate(){
    UIView *statusBarBackgroundView;
}
@property (nonatomic, readwrite) int networkActivityCounter;
@property (nonatomic, readwrite) int badgeNumberCounter;
@property (strong, nonatomic) NSDictionary *itemInfo;
@end

@implementation AppDelegate

-(void)notificationReceived:(NSNotification *)notification {
    NSDictionary *info = [notification userInfo];
    CGFloat alpha = [info[@"PanningProgress"] floatValue];
    NSLog(@"alpha: %f", alpha);
    statusBarBackgroundView.alpha = alpha;
}

-(void)statusBarMustBeTransparentNotificationReceived:(NSNotification *)notification {
    NSLog(@"status bar must be transparent notification received");
    [UIView animateWithDuration:0.1
                     animations:^(){
                         statusBarBackgroundView.alpha = 0.0;
                     }];
}

-(void)statusBarMustBeOpaqueNotificationReceived:(NSNotification *)notification {
    NSLog(@"Status bar must be opaque");
    [UIView animateWithDuration:0.1
                     animations:^(){
                         statusBarBackgroundView.alpha = 1.0;
                     }];
}

#pragma mark - Application LifeCycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationReceived:) name:@"PanningNotification" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(statusBarMustBeTransparentNotificationReceived:) name:@"StatusBarMustBeTransparentNotification" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(statusBarMustBeOpaqueNotificationReceived:)
                                                 name:@"StatusBarMustBeOpaqueNotification" object:nil];
    // Window framing changes condition for iOS7 or greater
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7) {
        statusBarBackgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.window.frame.size.width, 20)];//statusBarBackgroundView is normal uiview
        //statusBarBackgroundView.backgroundColor = [UIColor blackColor];
        statusBarBackgroundView.backgroundColor = [UIColor colorWithRed:199.0/255.0 green:157.0/255.0 blue:9.0/255.0 alpha:1.0];
        statusBarBackgroundView.alpha = 0.0;
        [self.window addSubview:statusBarBackgroundView];
        //self.window.bounds = CGRectMake(0, 20, self.window.frame.size.width, self.window.frame.size.height);
    }

    // Override point for customization after application launch.
    [GMSServices provideAPIKey:@"AIzaSyDxAZJ0eANVycpx0uv6Jlru-93u-G-zAzA"];
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
    
    NSString *deviceBrand = @"Apple";
    NSString *deviceModel = [[UIDevice currentDevice] model];
    NSString *systemVersion = [[UIDevice currentDevice] systemVersion];
    
    NSDictionary *dic = @{@"Model": deviceModel, @"SystemVersion" : systemVersion, @"Brand" : deviceBrand};
    FileSaver *fileSaver = [[FileSaver alloc] init];
    //[fileSaver setDictionary:@{@"app_id": @"528c1c396e9f990000000001"} withKey:@"app_id"];
    [fileSaver setDictionary:@{@"app_id": @"528c1c396e9f990000000001"} withKey:@"app_id"];

    [fileSaver setDictionary:dic withKey:@"DeviceInfo"];
    
    ////////////////////////////////////////////////////////////////////////
    //If the application launch from a local notification
    /*UILocalNotification *localNotification = [launchOptions objectForKey:UIApplicationLaunchOptionsLocalNotificationKey];
    if (localNotification)
    {
        //application.applicationIconBadgeNumber = 0;
        //NSLog(@"cambie el badge");
        [[NSNotificationCenter defaultCenter] postNotificationName:@"appStartedFromNotification"
                                                            object:nil
                                                          userInfo:@{@"notificationInfo": localNotification}];
        NSDictionary *notificationInfoDic = [NSDictionary dictionaryWithObjectsAndKeys:localNotification,@"notificationInfo", nil];
        [fileSaver setDictionary:notificationInfoDic withKey:@"notificationInfo"];
        NSLog(@"Entré desde una notificación");
        
        if ([fileSaver getDictionary:@"notificationInfo"])
            NSLog(@"Pude guardar el dic de la notificacion correctamente %@", [fileSaver getDictionary:@"notificationInfo"]);
        else
            NSLog(@"No pude guardar el diccionario de info de la notificacion");
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
    [self.window bringSubviewToFront:statusBarBackgroundView];
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
                          otherButtonTitles:@"Ver el evento", nil] show];
        
        NSString *itemID = notification.userInfo[@"name"];
        NSMutableArray *allItemsArray = [[NSMutableArray alloc] init];
        [allItemsArray addObjectsFromArray:[self getDictionaryWithName:@"master"][@"artistas"]];
        [allItemsArray addObjectsFromArray:[self getDictionaryWithName:@"master"][@"locaciones"]];
        [allItemsArray addObjectsFromArray:[self getDictionaryWithName:@"master"][@"noticias"]];
        [allItemsArray addObjectsFromArray:[self getDictionaryWithName:@"master"][@"eventos"]];
        
        for (int i = 0; i < [allItemsArray count]; i++)
        {
            if ([allItemsArray[i][@"_id"] isEqualToString:itemID])
            {
                self.itemInfo = allItemsArray[i];
                break;
            }
        }
    }
    
    else if ([application applicationState] == UIApplicationStateInactive)
    {
        NSLog(@"recibí la notificación desde un estado inactivo");
        NSString *itemID = notification.userInfo[@"name"];
        NSMutableArray *allItemsArray = [[NSMutableArray alloc] init];
        [allItemsArray addObjectsFromArray:[self getDictionaryWithName:@"master"][@"artistas"]];
        [allItemsArray addObjectsFromArray:[self getDictionaryWithName:@"master"][@"locaciones"]];
        [allItemsArray addObjectsFromArray:[self getDictionaryWithName:@"master"][@"noticias"]];
        [allItemsArray addObjectsFromArray:[self getDictionaryWithName:@"master"][@"eventos"]];
        
        for (int i = 0; i < [allItemsArray count]; i++)
        {
            if ([allItemsArray[i][@"_id"] isEqualToString:itemID])
            {
                self.itemInfo = allItemsArray[i];
                break;
            }
        }
        
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main_iPhone" bundle:nil];
        DetailsViewController *detailsViewController = [storyboard instantiateViewControllerWithIdentifier:@"EventDetails"];
        detailsViewController.objectInfo = self.itemInfo;
        detailsViewController.objectLocation = [self getItemLocationName:self.itemInfo];
        detailsViewController.objectTime = [self getFormattedItemDate:self.itemInfo];
        detailsViewController.navigationBarTitle = self.itemInfo[@"name"];
        detailsViewController.presentViewControllerFromSearchBar = YES;
        UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:detailsViewController];
        UIViewController *actualViewController = [[[[UIApplication sharedApplication] delegate] window] rootViewController];
        while (actualViewController.presentedViewController)
        {
            actualViewController = actualViewController.presentedViewController;
        }
        [actualViewController presentViewController:navigationController animated:YES completion:nil];
    }
    
    application.applicationIconBadgeNumber = 0;
}

-(void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    NSLog(@"Error obteniendo el token, error: %@", error);
}

-(void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    NSLog(@"User info: %@", userInfo);
    [[NSNotificationCenter defaultCenter] postNotificationName:@"notification" object:userInfo];
    
    [[[UIAlertView alloc] initWithTitle:nil
                               message:userInfo[@"aps"][@"alert"]
                              delegate:self
                     cancelButtonTitle:@"Ok"
                      otherButtonTitles:nil] show];
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

#pragma mark - UIAlertViewDelegate

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1)
    {
        NSLog(@"Entré a ver el evento que posteó la notificación");
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main_iPhone" bundle:nil];
        DetailsViewController *detailsViewController = [storyboard instantiateViewControllerWithIdentifier:@"EventDetails"];
        detailsViewController.objectInfo = self.itemInfo;
        detailsViewController.objectLocation = [self getItemLocationName:self.itemInfo];
        detailsViewController.objectTime = [self getFormattedItemDate:self.itemInfo];
        detailsViewController.navigationBarTitle = self.itemInfo[@"name"];
        detailsViewController.presentViewControllerFromSearchBar = YES;
        UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:detailsViewController];
        UIViewController *actualViewController = [[[[UIApplication sharedApplication] delegate] window] rootViewController];
        while (actualViewController.presentedViewController)
        {
            actualViewController = actualViewController.presentedViewController;
        }
        [actualViewController presentViewController:navigationController animated:YES completion:nil];
    }
}

#pragma mark - FileSaver

-(NSDictionary*)getDictionaryWithName:(NSString*)name{
    FileSaver *file=[[FileSaver alloc]init];
    return [file getDictionary:name];
}
-(void)setDictionary:(NSDictionary*)dictionary withName:(NSString*)name{
    FileSaver *file=[[FileSaver alloc]init];
    [file setDictionary:dictionary withKey:name];
}

-(NSString *)getFormattedItemDate:(NSDictionary *)item
{
    NSString *eventTime = item[@"event_time"];
    NSLog(@"Fecha del server: %@", eventTime);
    NSString *newString = [eventTime stringByReplacingOccurrencesOfString:@"T" withString:@" "];
    NSString *formattedEventTimeString = [newString stringByReplacingOccurrencesOfString:@".000Z" withString:@""];
    NSLog(@"Formatted string: %@", formattedEventTimeString);
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    //[dateFormatter setTimeStyle:NSDateFormatterMediumStyle];
    //[dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    [dateFormatter setLocale:[NSLocale localeWithLocaleIdentifier:@"en_US"]];
    NSLog(@"Locale: %@", [[NSLocale currentLocale] localeIdentifier]);
    //[NSTimeZone resetSystemTimeZone];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"GMT"]];
    NSLog(@"TImeZone: %@", [[NSTimeZone timeZoneWithAbbreviation:@"GMT"] description]);
    NSDate *sourceDate = [dateFormatter dateFromString:formattedEventTimeString];
    NSLog(@"SourceDate: %@", sourceDate);
    
    [dateFormatter setDateFormat:nil];
    [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    [dateFormatter setLocale:[NSLocale currentLocale]];
    
    NSTimeInterval timeInterval = [sourceDate timeIntervalSinceDate:[NSDate dateWithTimeIntervalSinceReferenceDate:0.0]];
    NSDate *SourceDateFormatted = [NSDate dateWithTimeIntervalSinceReferenceDate:timeInterval];
    NSLog(@"SourceDate Formatted: %@", [dateFormatter stringFromDate:SourceDateFormatted]);
    
    NSTimeZone  *sourceTimeZone = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
    NSTimeZone  *destinationTimeZone = [NSTimeZone localTimeZone];
    
    ///!!!!!!!!! cambiar sourcedate por sourcedateformatted
    NSInteger sourceGMTOffset = [sourceTimeZone secondsFromGMTForDate:SourceDateFormatted];
    NSInteger destinationGMTOffset = [destinationTimeZone secondsFromGMTForDate:SourceDateFormatted];
    NSTimeInterval interval = destinationGMTOffset - sourceGMTOffset;
    
    NSDate *destinationDate = [[NSDate alloc] initWithTimeInterval:interval sinceDate:SourceDateFormatted];
    NSLog(@"Destination Date Formatted: %@", [dateFormatter stringFromDate:destinationDate]);
    NSString *date = [dateFormatter stringFromDate:destinationDate];
    return date;
}

-(NSString *)getItemLocationName:(NSDictionary *)item
{
    NSString *itemLocationName = [[NSString alloc] init];
    //First we see if the item has a location associated.
    if ([item[@"location_id"] length] > 0)
    {
        //Location id exist.
        NSArray *locationsArray = [self getDictionaryWithName:@"master"][@"locaciones"];
        for (int i = 0; i < [locationsArray count]; i++)
        {
            if ([item[@"location_id"] isEqualToString:locationsArray[i][@"_id"]])
            {
                itemLocationName = locationsArray[i][@"name"];
                break;
            }
        }
    }
    
    else
    {
        itemLocationName = @"No hay locación asignada";
    }
    
    return itemLocationName;
}

@end
