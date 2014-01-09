//
//  EventDetailsViewController.m
//  EventosCaracol
//
//  Created by Developer on 20/11/13.
//  Copyright (c) 2013 iAmStudio. All rights reserved.
//

#import "DetailsViewController.h"

@interface DetailsViewController () <UIActionSheetDelegate, MFMailComposeViewControllerDelegate, MFMessageComposeViewControllerDelegate, UIScrollViewDelegate>
@property (strong, nonatomic) UIScrollView *scrollView;
@property (nonatomic) BOOL isFavorited;
@property (strong, nonatomic) UIButton *favoriteButton;
@property (strong, nonatomic) UILabel *favoriteCountLabel;
@end

@implementation DetailsViewController

-(void)viewDidLoad
{
    [super viewDidLoad];
    
    ////////////////////////////////////////////////////////////////////////////////
    //Time formatting
    NSLog(@"%@", [NSDate date]);
    
    ///////////////////////////////////////////////////////////////////////////////
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0,
                                                                    0.0,
                                                                    200.0,
                                                                    44.0)];
    titleLabel.text = self.navigationBarTitle;
    titleLabel.font = [UIFont fontWithName:@"Montserrat-Regular" size:17.0];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.textColor = [UIColor colorWithRed:29.0/255.0 green:80.0/255.0 blue:204.0/255.0 alpha:1.0];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    self.navigationItem.titleView = titleLabel;
    //self.navigationItem.title = self.navigationBarTitle;
    self.navigationController.navigationBar.barTintColor = [UIColor whiteColor];
    self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:29.0/255.0 green:80.0/255.0 blue:204.0/255.0 alpha:1.0];
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor colorWithRed:29.0/255.0 green:80.0/255.0 blue:204.0/255.0 alpha:1.0]};

    //Create the UIBarButtonItem to share the event.
    UIBarButtonItem *shareBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ShareIcon.png"]
                                                                           style:UIBarButtonItemStylePlain
                                                                          target:self
                                                                          action:@selector(shareEvent)];
    
    self.navigationItem.rightBarButtonItem = shareBarButtonItem;
    
    //If this controller was presented from a search bar table view selection, create a UIBarButtomItem to dismiss it.
    if (self.presentViewControllerFromSearchBar)
    {
        UIBarButtonItem *dismissBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Atrás"
                                                                                 style:UIBarButtonItemStylePlain
                                                                                target:self
                                                                                action:@selector(dismiss)];
        self.navigationItem.leftBarButtonItem = dismissBarButtonItem;
    }
    
    //UIImageVIew that will display the object's image (artist, news, event).
    UIImageView *mainImageView;
    
    //If we are in the detail view of a location object
    if (self.presentLocationObject)
    {
        GMSCameraPosition *cameraPosition = [GMSCameraPosition cameraWithLatitude:[self.objectInfo[@"lat"] doubleValue]
                                                                        longitude:[self.objectInfo[@"lon"] doubleValue]
                                                                             zoom:12.0];
        
        GMSMapView *mapView = [GMSMapView mapWithFrame:CGRectMake(0.0,
                                                                  self.navigationController.navigationBar.frame.origin.y + self.navigationController.navigationBar.frame.size.height + 0.0,
                                                                  self.view.frame.size.width ,
                                                                  (self.view.frame.size.height/2 - 20) -(self.navigationController.navigationBar.frame.origin.y + self.navigationController.navigationBar.frame.size.height + 20.0))
                                                camera:cameraPosition];
        
        mapView.myLocationEnabled = YES;
        mapView.userInteractionEnabled = NO;
        double markerLatitude = [self.objectInfo[@"lat"] doubleValue];
        double markerLongitude = [self.objectInfo[@"lon"] doubleValue];
        GMSMarker *marker = [GMSMarker markerWithPosition:CLLocationCoordinate2DMake(markerLatitude, markerLongitude)];
        marker.title = self.objectInfo[@"name"];
        marker.map = mapView;
        [self.view addSubview:mapView];
        
        //////////////////////////////////////////////////////////////////////
        //Create the scroll view to make all the content scrollable. The scroll view will be below the map view.
        //The mapview is always static, it's not in the scroll view.
        self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0.0,
                                                                                  mapView.frame.origin.y + mapView.frame.size.height + 10,
                                                                                  self.view.frame.size.width,
                                                                                  self.view.frame.size.height - (mapView.frame.origin.y + mapView.frame.size.height + 10))];
        
        
        
        mainImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0,
                                                                      0.0,
                                                                      self.view.frame.size.width,
                                                                      self.view.frame.size.height/2.5)];
        
    }
    
    //...if we are not in the detail view of a location object.
    else
    {
        //If the object doen's have a youtube url, create a scroll view to contain all the subviews.
        if ([self.objectInfo[@"youtube_url"] isEqualToString:@""])
        {
            //Create the scroll view of the entire screen, because there is not map view.
            NSLog(@"no hay youtube");
            self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0.0,
                                                                             self.navigationController.navigationBar.frame.origin.y + self.navigationController.navigationBar.frame.size.height,
                                                                             self.view.frame.size.width,
                                                                             self.view.frame.size.height - (self.navigationController.navigationBar.frame.origin.y + self.navigationController.navigationBar.frame.size.height))];
        }
        //If the object has an URL to a youutube video, we have to create a webview to display it, and below it we create the scroll view.
        else
        {
            NSLog(@"si hay youtube");
            UIWebView *webView = [[UIWebView alloc] initWithFrame:CGRectMake(0.0,
                                                                             self.navigationController.navigationBar.frame.origin.y + self.navigationController.navigationBar.frame.size.height,
                                                                             self.view.frame.size.width - 10,
                                                                             self.view.frame.size.height/3.0)];
            [webView.scrollView setScrollEnabled:NO];
            NSString *embebedHTML = self.objectInfo[@"youtube_url"];
            NSString *formattedHTML = [NSString stringWithFormat:@"<meta name=\"viewport\", content=\"width=device-width\", user-scalable=no>%@",[embebedHTML stringByReplacingOccurrencesOfString:@"//" withString:@"http://"]];
            [webView loadHTMLString:formattedHTML baseURL:nil];
            [self.view addSubview:webView];
            
            self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0.0,webView.frame.origin.y + webView.frame.size.height + 10,
                                                                             self.view.frame.size.width,
                                                                             self.view.frame.size.height - (                                                                           webView.frame.origin.y + webView.frame.size.height))];
        }
        
        mainImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0,
                                                                      0.0,
                                                                      self.view.frame.size.width,
                                                                      self.view.frame.size.height/2.5)];
    }
    
    mainImageView.backgroundColor = [UIColor cyanColor];
    mainImageView.clipsToBounds = YES;
    mainImageView.contentMode = UIViewContentModeScaleAspectFill;
    [mainImageView setImageWithURL:[NSURL URLWithString:self.objectInfo[@"image_url"][0]]
                  placeholderImage:[UIImage imageNamed:@"CaracolPrueba4.png"]];
    
    self.scrollView.delegate = self;
    self.scrollView.alwaysBounceVertical = YES;
    [self.scrollView addSubview:mainImageView];
    [self.view addSubview:self.scrollView];
    
    //////////////////////////////////////////////////////////////////////////////////////////
    self.favoriteButton = [[UIButton alloc] initWithFrame:CGRectMake(10.0,
                                                                          mainImageView.frame.origin.y + mainImageView.frame.size.height + 10.0,
                                                                          self.view.frame.size.width/5.33,
                                                                          self.view.frame.size.height/9.46)];
    //[self.favoriteButton setTitle:@"Fav" forState:UIControlStateNormal];
    [self.favoriteButton addTarget:self action:@selector(makeFavorite) forControlEvents:UIControlEventTouchUpInside];
    
    //Store the favorited atoms of the user (array of NSString)
    NSArray *favoritedObjectsArray;
    if (self.presentLocationObject)
        favoritedObjectsArray = [self getDictionaryWithName:@"user"][@"favorited_locations"];
    else
        favoritedObjectsArray = [self getDictionaryWithName:@"user"][@"favorited_atoms"];
    
    //If the current object is favorite, show the favorite button with purple color.
    if ([favoritedObjectsArray containsObject:self.objectInfo[@"_id"]])
    {
        NSLog(@"el objeto está favoriteado oís");
        //self.favoriteButton.backgroundColor = [UIColor purpleColor];
        [self.favoriteButton setBackgroundImage:[UIImage imageNamed:@"CorazonPrendido.png"] forState:UIControlStateNormal];
        self.isFavorited = YES;
    }
    
    //...if not, show it with gray color.
    else
    {
        NSLog(@"el objeto no está favoriteado oís");
        self.isFavorited = NO;
        [self.favoriteButton setBackgroundImage:[UIImage imageNamed:@"CorazonApagado.png"] forState:UIControlStateNormal];
        //self.favoriteButton.backgroundColor = [UIColor grayColor];
    }
    
    [self.scrollView addSubview:self.favoriteButton];
    
    ///////////////////////////////////////////////////////////////////////////////////////////
    UILabel *objectName = [[UILabel alloc] initWithFrame:CGRectMake(20.0 + self.favoriteButton.frame.size.width,
                                                                   self.favoriteButton.frame.origin.y,
                                                                   self.view.frame.size.width - (20.0 + self.favoriteButton.frame.size.width + 20) - 10,
                                                                    self.view.frame.size.height/18.93)];
    objectName.numberOfLines = 2;
    objectName.textAlignment = NSTextAlignmentLeft;
    objectName.text = self.objectInfo[@"name"];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        objectName.font = [UIFont fontWithName:@"Montserrat-Regular" size:40.0];
    else
        objectName.font = [UIFont fontWithName:@"Montserrat-Regular" size:20.0];
    
    [self.scrollView addSubview:objectName];
    
    ///////////////////////////////////////////////////////////////////////////////////////////
    /*UILabel *eventLocationLabel = [[UILabel alloc] initWithFrame:CGRectMake(20.0 + self.favoriteButton.frame.size.width,
                                                                            objectName.frame.origin.y + objectName.frame.size.height,
                                                                            self.view.frame.size.width - (20.0 + self.favoriteButton.frame.size.width + 20) - 20,
                                                                            self.view.frame.size.height/28.4)];
    //eventLocationLabel.text = @"Plaza Cervantes";
    eventLocationLabel.text = [NSString stringWithFormat:@"📍%@", self.objectLocation];
    eventLocationLabel.textColor = [UIColor lightGrayColor];*/
    
    UIButton *eventLocationButton = [[UIButton alloc] initWithFrame:CGRectMake(- 40 + 20.0 + self.favoriteButton.frame.size.width,
                                                                               objectName.frame.origin.y + objectName.frame.size.height,
                                                                               self.view.frame.size.width - (20.0 + self.favoriteButton.frame.size.width + 20) - 20,
                                                                               self.view.frame.size.height/28.4)];
    [eventLocationButton setTitle:[NSString stringWithFormat:@"📍%@", self.objectLocation] forState:UIControlStateNormal];
    eventLocationButton.titleLabel.textAlignment = NSTextAlignmentLeft;
    
    if (![self.objectInfo[@"type"] isEqualToString:@"locaciones"])
    {
        [eventLocationButton addTarget:self action:@selector(goToItemLocationDetail) forControlEvents:UIControlEventTouchUpInside];
        [eventLocationButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    }
    else
        [eventLocationButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        eventLocationButton.titleLabel.font = [UIFont fontWithName:@"Montserrat-Regular" size:24.0];

    else
        eventLocationButton.titleLabel.font = [UIFont fontWithName:@"Montserrat-Regular" size:12.0];
    
    [self.scrollView addSubview:eventLocationButton];
    
    ///////////////////////////////////////////////////////////////////////////////////////////
    UILabel *eventTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(20.0 + self.favoriteButton.frame.size.width,
                                                                        eventLocationButton.frame.origin.y + eventLocationButton.frame.size.height,
                                                                        self.view.frame.size.width - (20.0 + self.favoriteButton.frame.size.width + 20) - 20,
                                                                        self.view.frame.size.height/28.4)];
    //eventTimeLabel.text = @"11:30AM";
    if (!self.presentLocationObject)
        eventTimeLabel.text = [NSString stringWithFormat:@"🕑 %@", self.objectTime];
    else
        eventTimeLabel.text = @"";
    
    eventTimeLabel.textColor = [UIColor lightGrayColor];
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        eventTimeLabel.font = [UIFont fontWithName:@"Montserrat-Regular" size:24.0];
    else
        eventTimeLabel.font = [UIFont fontWithName:@"Montserrat-Regular" size:12.0];
    
    [self.scrollView addSubview:eventTimeLabel];
    
    /////////////////////////////////////////////////////////////////////////////////////////
    UILabel *dotsLabel = [[UILabel alloc] initWithFrame:CGRectMake(20.0,
                                                                   eventTimeLabel.frame.origin.y + eventTimeLabel.frame.size.height,
                                                                   self.view.frame.size.width - 40.0,
                                                                   10.0)];
    dotsLabel.text = @"..................................................................";
    dotsLabel.textColor = [UIColor lightGrayColor];
    [self.scrollView addSubview:dotsLabel];
    
    ///////////////////////////////////////////////////////////////////////////////////////////
    UITextView *description = [[UITextView alloc]
                                    initWithFrame:CGRectMake(20.0,
                                                             eventTimeLabel.frame.origin.y + eventTimeLabel.frame.size.height + 20,
                                                             self.view.frame.size.width - 40.0,
                                                             self.view.frame.size.height - (eventTimeLabel.frame.origin.y + eventTimeLabel.frame.size.height + 20) - 80)];
    //description.text = self.objectInfo[@"detail"];
    description.text = @"Lorem ipsum dolor sit amet, consectetuer adipiscing elit, sed diam nonummy nibh euismod tincidunt ut laoreet dolore magna aliquam erat volutpat. Ut wisi enim ad minim veniam, quis nostrud exerci tation ullamcorper suscipit lobortis nisl ut aliquip ex ea commodo consequat. Duis autem vel eum iriure dolor in hendrerit in vulputate velit esse molestie consequat, vel illum dolore eu feugiat nulla facilisis at vero eros et accumsan et iusto odio dignissim qui blandit praesent luptatum zzril delenit augue duis dolore te feugait nulla facilisi. Nam liber tempor cum soluta nobis eleifend option congue nihil imperdiet doming id quod mazim placerat facer possim assum. Typi non haben";
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        description.font = [UIFont fontWithName:@"Montserrat-Regular" size:28.0];
    else
        description.font = [UIFont fontWithName:@"Montserrat-Regular" size:15.0];
    
    description.selectable = YES;
    description.textAlignment = NSTextAlignmentJustified;
    description.textColor = [UIColor lightGrayColor];
    description.editable = NO;
    [self.scrollView addSubview:description];
    self.scrollView.contentSize = CGSizeMake(self.view.frame.size.width, description.frame.origin.y + description.frame.size.height + 20);
}

#pragma mark - Actions

-(void)goToItemLocationDetail
{
    NSString *itemLocationID = self.objectInfo[@"location_id"];
    NSDictionary *locationItem;
    
    NSArray *locationsArray = [self getDictionaryWithName:@"master"][@"locaciones"];
    for (int i = 0; i < [locationsArray count]; i++)
    {
        if ([locationsArray[i][@"_id"] isEqualToString:itemLocationID])
        {
            locationItem = locationsArray[i];
            break;
        }
    }
    
    DetailsViewController *locationDetailsViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"EventDetails"];
    locationDetailsViewController.navigationBarTitle = locationItem[@"name"];
    locationDetailsViewController.objectInfo = locationItem;
    locationDetailsViewController.objectLocation = locationItem[@"short_detail"];
    locationDetailsViewController.presentLocationObject = YES;
    [self.navigationController pushViewController:locationDetailsViewController animated:YES];
}

-(void)dismiss
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)makeFavorite
{
    //If the dictionary 'user' doesn't exist, we don't allow the user to favorite the items.
    //it's neccesary to log in facebook to fav items.
    if (![self getDictionaryWithName:@"user"][@"_id"])
    {
        [[[UIAlertView alloc] initWithTitle:nil
                                   message:@"Ops! Debes iniciar sesión con Facebook para poder asignar favoritos."
                                  delegate:self
                         cancelButtonTitle:@"Ok"
                         otherButtonTitles:@"Iniciar Sesión", nil] show];
        return;
    }
    
    //Create a string that contains the parameters to send to the server.
    NSString *params = [NSString stringWithFormat:@"item_id=%@&user_id=%@&type=%@&app_id=%@", self.objectInfo[@"_id"], [self getDictionaryWithName:@"user"][@"_id"], self.objectInfo[@"type"], [self getDictionaryWithName:@"master"][@"app"][@"_id"]];
    ServerCommunicator *serverCommunicator = [[ServerCommunicator alloc] init];
    serverCommunicator.delegate = self;
    
    if (!self.isFavorited)
    {
        
        [self postLocalNotification];
        
        [MBHUDView hudWithBody:nil type:MBAlertViewHUDTypeActivityIndicator hidesAfter:1000 show:YES];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"FavItemNotification"
                                                            object:nil];
         
        [serverCommunicator callServerWithPOSTMethod:@"FavItem" andParameter:params httpMethod:@"POST"];
    }
    
    /*[MBHUDView hudWithBody:nil type:MBAlertViewHUDTypeActivityIndicator hidesAfter:1000 show:YES];
    
    //Communicate asynchronously with the server
    dispatch_queue_t server = dispatch_queue_create("server", nil);
    dispatch_async(server, ^(){
        if (self.isFavorited)
            [serverCommunicator callServerWithPOSTMethod:@"UnFavItem" andParameter:params httpMethod:@"POST"];
        else
            [serverCommunicator callServerWithPOSTMethod:@"FavItem" andParameter:params httpMethod:@"POST"];
    });*/
    NSLog(@"%@", params);
}

-(void)postLocalNotification
{
    NSString *eventTime = self.objectInfo[@"event_time"];
    NSString *newString = [eventTime stringByReplacingOccurrencesOfString:@"T" withString:@" "];
    NSString *formattedEventTimeString = [newString stringByReplacingOccurrencesOfString:@".000Z" withString:@""];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    [dateFormatter setLocale:[NSLocale localeWithLocaleIdentifier:@"en_US"]];
    [dateFormatter setTimeZone:[NSTimeZone localTimeZone]];
    
    if (![dateFormatter dateFromString:formattedEventTimeString])
        NSLog(@"no lo formatée");
    else
    {
        ///////////////////////////////////////////////////////////////////////////
        NSDate *sourceDate = [dateFormatter dateFromString:formattedEventTimeString];
        
        NSTimeZone  *sourceTimeZone = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
        NSTimeZone  *destinationTimeZone = [NSTimeZone systemTimeZone];
        
        NSInteger sourceGMTOffset = [sourceTimeZone secondsFromGMTForDate:sourceDate];
        NSInteger destinationGMTOffset = [destinationTimeZone secondsFromGMTForDate:sourceDate];
        NSTimeInterval interval = destinationGMTOffset - sourceGMTOffset;
        
        NSDate *destinationDate = [[NSDate alloc] initWithTimeInterval:interval sinceDate:sourceDate];
        
        //We have to substract one hour from the event time because we want the reminder notification
        //to be post one hour earlier.
        NSDate *oneHourEarlierDate = [destinationDate dateByAddingTimeInterval:-(60*60)];
        NSLog(@"si pude formatear y cambiar al time zone adecuado: %@", [destinationDate descriptionWithLocale:[NSLocale currentLocale]]);
        NSLog(@"recordaré del evento a las : %@", [oneHourEarlierDate descriptionWithLocale:[NSLocale currentLocale]]);
        NSLog(@"Hour: %@", oneHourEarlierDate);
        NSLog(@"Actual hour: %@", [NSDate date]);
        
        if ([oneHourEarlierDate compare:[NSDate date]] == NSOrderedDescending)
        {
            UILocalNotification *localNotification = [[UILocalNotification alloc] init];
            localNotification.soundName = UILocalNotificationDefaultSoundName;
            localNotification.userInfo = @{@"name": self.objectInfo[@"_id"]};
            localNotification.alertBody = [NSString stringWithFormat:@"El evento '%@' es dentro de una hora, no te lo pierdas!", self.objectInfo[@"name"]];
            localNotification.fireDate = oneHourEarlierDate;
            NSLog(@"Fire Date: %@", [localNotification.fireDate descriptionWithLocale:[NSLocale currentLocale]]);
            localNotification.alertAction = @"Ver el evento";
            localNotification.timeZone = [NSTimeZone systemTimeZone];
            localNotification.applicationIconBadgeNumber = [UIApplication sharedApplication].applicationIconBadgeNumber + 1;
            [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
            NSLog(@"postée la notificación");
        }
        
        else
        {
            NSLog(@"No posteé la notificación porque el evento ya pasó");
        }
    }
}

-(void)updateFavoritedButton
{
    if (self.isFavorited)
        [self.favoriteButton setBackgroundImage:[UIImage imageNamed:@"CorazonPrendido.png"] forState:UIControlStateNormal];
    else
        [self.favoriteButton setBackgroundImage:[UIImage imageNamed:@"CorazonApagado.png"] forState:UIControlStateNormal];
}

-(void)showFavoriteAnimationWithImage:(UIImage *)image
{
    [PopUpView showPopUpViewOverView:self.view image:image];
}

-(void)shareEvent
{
    [[[UIActionSheet alloc] initWithTitle:nil
                                delegate:self
                       cancelButtonTitle:@"Volver"
                  destructiveButtonTitle:nil
                       otherButtonTitles:@"SMS", @"Facebook", @"Twitter", @"Correo", nil] showInView:self.view];
}

#pragma mark - ServerComunnicatorDelegate

-(void)receivedDataFromServer:(NSDictionary *)dictionary withMethodName:(NSString *)methodName
{
    [MBHUDView dismissCurrentHUD];
    
    if ([methodName isEqualToString:@"UnFavItem"] || [methodName isEqualToString:@"FavItem"])
    {
        if ([dictionary[@"status"] boolValue])
        {
            NSLog(@"%@", dictionary);
            [self setDictionary:dictionary[@"user"] withName:@"user"];
            self.isFavorited = !self.isFavorited;
            [self updateFavoritedButton];
            self.isFavorited ? [self showFavoriteAnimationWithImage:nil] :
            [self showFavoriteAnimationWithImage:[UIImage imageNamed:@"BorrarRojo.png"]];
            NSLog(@"Se pudo favoritear o desfavoritear correctamente");
            [[NSNotificationCenter defaultCenter] postNotificationName:@"serverUpdateNeededNotification" object:nil];
        }
        
        else
        {
            [[[UIAlertView alloc] initWithTitle:nil
                                       message:@"Hubo un error con el servidor. Por favor intenta de nuevo."
                                      delegate:self
                             cancelButtonTitle:@"Ok"
                             otherButtonTitles:nil] show];
        }
    }
}

-(void)serverError:(NSError *)error
{
    [MBHUDView dismissCurrentHUD];
    
    NSLog(@"error con el servidor");
    [[[UIAlertView alloc] initWithTitle:nil
                               message:@"No hay conexión."
                              delegate:self
                     cancelButtonTitle:@"Ok"
                     otherButtonTitles:nil] show];
}

#pragma mark - UIActionSheetDelegate

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *textToShare = [self.objectInfo[@"name"] stringByAppendingString:@" : "];
    textToShare = [textToShare stringByAppendingString:self.objectInfo[@"short_detail"]];
    textToShare = [textToShare stringByAppendingString:@"\n Enviado desde la aplicación 'EuroCine 2014'"];
    if(buttonIndex == 0)
    {
        NSLog(@"SMS");
        if (![MFMessageComposeViewController canSendText])
        {
            [[[UIAlertView alloc] initWithTitle:@"Error"
                                       message:@"No se pueden enviar mensajes desde este dispositivo"
                                      delegate:self
                             cancelButtonTitle:@"Ok"
                             otherButtonTitles:nil] show];
        }
        
        else
        {
            MFMessageComposeViewController *messageViewController = [[MFMessageComposeViewController alloc] init];
            messageViewController.messageComposeDelegate = self;
            [messageViewController setBody:textToShare];
            [self presentViewController:messageViewController animated:YES completion:nil];
            NSLog(@"presenté el viewcontroller");
        }
    }
    
    else if (buttonIndex == 1)
    {
        NSLog(@"Facebook");
        
        SLComposeViewController *facebookViewController = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
        [facebookViewController setInitialText:textToShare];
        [self presentViewController:facebookViewController animated:YES completion:nil];
    }
    
    else if (buttonIndex == 2)
    {
        NSLog(@"Twitter");
        
        SLComposeViewController *twitterViewController = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
        [twitterViewController setInitialText:textToShare];
        [self presentViewController:twitterViewController animated:YES completion:nil];
    }
    
    else if (buttonIndex == 3)
    {
        NSLog(@"Mail");
        MFMailComposeViewController *mailComposeViewController = [[MFMailComposeViewController alloc] init];
        [mailComposeViewController setSubject:@"¡EuroCine 2014!"];
        [mailComposeViewController setMessageBody:textToShare isHTML:NO];
        
        mailComposeViewController.mailComposeDelegate = self;
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
            mailComposeViewController.modalPresentationStyle = UIModalPresentationFormSheet;
        
        [self presentViewController:mailComposeViewController animated:YES completion:nil];
    }
}

#pragma mark - MFMailComposeViewControllerDelegate

-(void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - MFMessageComposeViewControllerDelegate

-(void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result
{
    [self dismissViewControllerAnimated:YES completion:nil];
}


-(NSDictionary*)getDictionaryWithName:(NSString*)name{
    FileSaver *file=[[FileSaver alloc]init];
    return [file getDictionary:name];
}
-(void)setDictionary:(NSDictionary*)dictionary withName:(NSString*)name{
    FileSaver *file=[[FileSaver alloc]init];
    [file setDictionary:dictionary withKey:name];
}
#pragma mark - UIAlertViewDelegate

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1)
    {
        LoginViewController *loginVC = [self.storyboard instantiateViewControllerWithIdentifier:@"Login"];
        loginVC.loginWasPresentedFromFavoriteButtonAlert = YES;
        [self presentViewController:loginVC animated:YES completion:nil];
    }
}

@end
