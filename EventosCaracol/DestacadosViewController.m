//
//  DestacadosViewController.m
//  EventosCaracol
//
//  Created by Developer on 22/11/13.
//  Copyright (c) 2013 iAmStudio. All rights reserved.
//

#import "DestacadosViewController.h"

#define SPECIAL_IDENTIFIER @"SpecialCell"
#define FEATURED_IDENTIFIER @"FeaturedCell"

@interface DestacadosViewController () <UICollectionViewDataSource, UICollectionViewDelegate>

@property (strong, nonatomic) NSArray *featuredEventsArray; //Of NSDictionary
@property (strong, nonatomic) NSArray *specialItemsArray; //Of NSDictionary
@property (strong, nonatomic) UICollectionView *specialItemsCollectionView;
@property (strong, nonatomic) NSTimer * timer;
@property (nonatomic) NSInteger currentPage;
@property (strong, nonatomic) NSString *itemLocationName;
@end

@implementation DestacadosViewController

#pragma mark - View Lifecycle

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.currentPage = 1;
    
    //Create a timer that fires every five seconds. this timer is used to make
    //a slide show (like a presentation) of the special events that are displayed
    //in the top ScrollView of the screen.
    self.timer = [NSTimer scheduledTimerWithTimeInterval:5.0
                                                  target:self
                                                selector:@selector(slideShowSpecialItems)
                                                userInfo:nil
                                                 repeats:YES];
    
    //Set the color properties of the NavigationBar. we have to do this every
    //time the view appears, because this properties are differente in the other
    //controllers.
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:29.0/255.0 green:80.0/255.0 blue:204.0/255.0 alpha:1.0];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor whiteColor]};
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    NSLog(@"desaparecí");
    //Stop the timer.
    [self.timer invalidate];
    self.timer = nil;
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self.specialItemsCollectionView setContentOffset:CGPointMake(0.0, 0.0) animated:NO];
}

-(void)viewDidLoad
{
    [super viewDidLoad];
    
    //Register as an observer of the appStartedFromNotification notification
    /*[[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appStartedFromNotificationReceivedWithNotification:)
                                                 name:@"appStartedFromNotification"
                                               object:nil];*/
    
    //Create the back button that will be displayed in the next view controller
    //that is push by this view controller.
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Atrás"
                                                                            style:UIBarButtonItemStylePlain
                                                                           target:self
                                                                           action:nil];

    
    //////////////////////////////////////////////////////
    //Create the back button of the NavigationBar. When pressed, this button
    //display the slide menu.
    UIBarButtonItem *sideBarButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"SidebarIcon.png"]
                                                                      style:UIBarButtonItemStylePlain
                                                                     target:self.revealViewController
                                                                     action:@selector(revealToggle:)];
    
    //Create a NavigationBar button to share the app.
    UIBarButtonItem *shareButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ShareIcon.png"]
                                                                    style:UIBarButtonItemStylePlain
                                                                   target:self
                                                                   action:@selector(shareApp)];
    
    //Add the buttons to the NavigationBar.
    self.navigationItem.rightBarButtonItem = shareButton;
    self.navigationItem.leftBarButtonItem = sideBarButton;
    
    //Add a pan gesture to the view, that allows the user to display the slide
    //menu by panning on screen.
    [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    
    ///////////////////////////////////////////////////////////////////////////
    //Store the JSON info in a dictionary
    NSDictionary *myDictionary = [self getDictionaryWithName:@"master"][@"app"];
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0,
                                                                    0.0,
                                                                    200.0,
                                                                    44.0)];
    titleLabel.text = [myDictionary objectForKey:@"name"];
    titleLabel.font = [UIFont fontWithName:@"Montserrat-Regular" size:17.0];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    self.navigationItem.titleView = titleLabel;
    
    //define an array with only the featured events information
    self.featuredEventsArray = [self getDictionaryWithName:@"master"][@"destacados"];
    
    //Define an array with the special items
    self.specialItemsArray = [self getDictionaryWithName:@"master"][@"especiales"];
    
    /////////////////////////////////////////////////////////////
    //Create UICollectionView to display the special items
    UICollectionViewFlowLayout *specialItemsCollectionViewLayout = [[UICollectionViewFlowLayout alloc] init];
    specialItemsCollectionViewLayout.minimumInteritemSpacing = 0;
    specialItemsCollectionViewLayout.minimumLineSpacing = 0;
    specialItemsCollectionViewLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    self.specialItemsCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0.0, self.navigationController.navigationBar.frame.origin.y + self.navigationController.navigationBar.frame.size.height, self.view.frame.size.width, self.view.frame.size.height/4.3) collectionViewLayout:specialItemsCollectionViewLayout];
    self.specialItemsCollectionView.tag = 0;
    self.specialItemsCollectionView.showsHorizontalScrollIndicator = NO;
    self.specialItemsCollectionView.dataSource = self;
    self.specialItemsCollectionView.delegate = self;
    self.specialItemsCollectionView.alwaysBounceHorizontal = YES;
    self.specialItemsCollectionView.pagingEnabled = YES;
    [self.specialItemsCollectionView registerClass:[DestacadosCollectionViewCell class] forCellWithReuseIdentifier:SPECIAL_IDENTIFIER];
    self.specialItemsCollectionView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.specialItemsCollectionView];
    
    /////////////////////////////////////////////////////////
    //Create UICollectionView that display the list of featured items
    UICollectionViewFlowLayout *collectionViewLayout = [[UICollectionViewFlowLayout alloc] init];
    UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0.0, self.specialItemsCollectionView.frame.origin.y + self.specialItemsCollectionView.frame.size.height + 10.0, self.view.frame.size.width, self.view.frame.size.height - (self.specialItemsCollectionView.frame.origin.y + self.specialItemsCollectionView.frame.size.height + 20.0)) collectionViewLayout:collectionViewLayout];
    collectionView.tag = 1;
    collectionView.showsVerticalScrollIndicator = NO;
    collectionView.dataSource = self;
    [collectionView setAlwaysBounceVertical:YES];
    collectionView.contentInset = UIEdgeInsetsMake(0.0, 10.0, 0.0, 10.0);
    collectionView.delegate = self;
    [collectionView registerClass:[DestacadosCollectionViewCell class] forCellWithReuseIdentifier:FEATURED_IDENTIFIER];
    collectionView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:collectionView];
    
    ///////////////////////////////////////////////////////////////
    //Check if there is a notificationInfo dictionary stored in the
    //app. If so, that means the app was launch from a local
    //notification, so we have to present the view controller of the
    //notification event from this view controller.
    /*FileSaver *fileSaver = [[FileSaver alloc] init];
    if ([fileSaver getDictionary:@"notificationInfo"])
    {
        NSLog(@"Si existía el dic entonces toca mostrar el detail del evento");
        //The dictionary exist, so we have to present the detail view
        //controller of the notification event
        [[[UIAlertView alloc] initWithTitle:nil
                                    message:@"me presenté desde una notificación"
                                   delegate:self
                          cancelButtonTitle:@"Ok"
                          otherButtonTitles:nil] show];
        
        //Erase the dictionary info
        //[self setDictionary:nil withName:@"notificationInfo"];
    }
    
    else
    {
        NSLog(@"el diccionario no existe");
    }*/

}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    FileSaver *fileSaver = [[FileSaver alloc] init];
    if (![fileSaver getDictionary:@"firstAppLaunch"])
    {
        TutorialViewController *tutorialVC = [self.storyboard instantiateViewControllerWithIdentifier:@"Tutorial"];
        [self presentViewController:tutorialVC animated:YES completion:nil];
        [fileSaver setDictionary:@{@"firstAppLaunch": @YES} withKey:@"firstAppLaunch"];
    }
}

-(void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    NSLog(@"recibí un aviso de memoria");
}

#pragma mark - Notification Handler

/*-(void)appStartedFromNotificationReceivedWithNotification:(NSNotification *)notification
{
    NSDictionary *info = [notification userInfo];
    [[[UIAlertView alloc] initWithTitle:nil
                               message:@"La aplicacion empezó desde una notificación"
                              delegate:self
                     cancelButtonTitle:@"Ok"
                      otherButtonTitles:nil] show];
    NSLog(@"llegó la notificación");
}*/

#pragma mark - Custom Methods

-(void)shareApp
{
    [[[UIActionSheet alloc] initWithTitle:@""
                                 delegate:self
                        cancelButtonTitle:@"Volver"
                   destructiveButtonTitle:nil
                        otherButtonTitles:@"SMS", @"Facebook", @"Twitter", @"Correo" ,nil] showInView:self.view];
}

-(void)slideShowSpecialItems
{
    //This methods gets called every time the timer fires.
    
    //It's neccesary to know the max number of 'pages' that are going to be
    //displayed in the top scrollview. So, when the presentation gets to this page
    //it returns to the page 1.
    NSUInteger maxPage = [self.specialItemsArray count];
    
    //Change the content offset of the ScrollView.
    [self.specialItemsCollectionView setContentOffset:CGPointMake(self.view.frame.size.width*self.currentPage, 0.0) animated:YES];
    
    //If the presentation is in the last page, go back to page 1.
    if (self.currentPage == maxPage)
    {
        [self.specialItemsCollectionView setContentOffset:CGPointMake(0.0, 0.0) animated:YES];
        self.currentPage = 1;
    }
}

-(NSString *)getFormattedItemDate:(NSDictionary *)item
{
    /////////////////////////////////////////////////////////
    //This method returns a NSString object that contains the
    //the date of the item formatted to the locale of the user
    
    //Obtains the date string from the server and delete the
    //unnecesary characters
    NSString *eventTime = item[@"event_time"];
    NSLog(@"Fecha del server: %@", eventTime);
    NSString *newString = [eventTime stringByReplacingOccurrencesOfString:@"T" withString:@" "];
    NSString *formattedEventTimeString = [newString stringByReplacingOccurrencesOfString:@".000Z" withString:@""];
    NSLog(@"Formatted string: %@", formattedEventTimeString);
    
    //Create a NSDateFormatter to get a NSDate object from the
    //date string obtained from the server
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
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
    
    //We have to convert the NSDate object, which is on GMT Time to
    //our locale time.
    NSTimeInterval timeInterval = [sourceDate timeIntervalSinceDate:[NSDate dateWithTimeIntervalSinceReferenceDate:0.0]];
    NSDate *SourceDateFormatted = [NSDate dateWithTimeIntervalSinceReferenceDate:timeInterval];
    NSLog(@"SourceDate Formatted: %@", [dateFormatter stringFromDate:SourceDateFormatted]);
    
    NSTimeZone  *sourceTimeZone = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
    NSTimeZone  *destinationTimeZone = [NSTimeZone localTimeZone];
    
    NSInteger sourceGMTOffset = [sourceTimeZone secondsFromGMTForDate:SourceDateFormatted];
    NSInteger destinationGMTOffset = [destinationTimeZone secondsFromGMTForDate:SourceDateFormatted];
    NSTimeInterval interval = destinationGMTOffset - sourceGMTOffset;
    
    //Create the NSDate object with the locale date & time.
    NSDate *destinationDate = [[NSDate alloc] initWithTimeInterval:interval sinceDate:SourceDateFormatted];
    NSLog(@"Destination Date Formatted: %@", [dateFormatter stringFromDate:destinationDate]);
    NSString *date = [dateFormatter stringFromDate:destinationDate];
    return date;
}

-(NSString *)getItemLocation:(NSDictionary *)item
{
    NSString *itemLocation = [[NSString alloc] init];
    ////////////////////////////////////////////////////////////
    //obtain the item location to pass it to the next view controller
    //First check if we are in a list of locations items. if not, search for the
    //location_id of the item to display it's location in the cell
    if (![item[@"type"] isEqualToString:@"locaciones"])
    {
        //First we see if the item has a location associated.
        if ([item[@"location_id"] length] > 0)
        {
            //Location id exist.
            NSArray *locationsArray = [self getDictionaryWithName:@"master"][@"locaciones"];
            for (int i = 0; i < [locationsArray count]; i++)
            {
                if ([item[@"location_id"] isEqualToString:locationsArray[i][@"_id"]])
                {
                    itemLocation = locationsArray[i][@"name"];
                    break;
                }
            }
        }
        
        else
        {
            itemLocation = @"No hay locación asignada";
        }
    }
    
    //if we are in a list of location items, search for the short detail description
    //of the item to display it in the cell.
    else
    {
        itemLocation = item[@"short_detail"];
    }
    
    return itemLocation;
    /////////////////////////////////////////////////////////////////////////////////
}

-(void)goToNextViewControllerFromItemInArray:(NSArray *)array atIndex:(NSInteger)index
{
    //If the item has an external url, we have to check if the url is going to open inside or
    //outside the application.
    if (array[index][@"external_url"])
    {
        //If the open inside value is 'no', we present the details of the item in DetailsViewController.
        if ([array[index][@"open_inside"] isEqualToString:@"no"])
        {
            DetailsViewController *detailsVC = [self.storyboard instantiateViewControllerWithIdentifier:@"EventDetails"];
            detailsVC.objectInfo = array[index];
            self.itemLocationName = [self getItemLocation:array[index]];
            NSString *itemDate = [self getFormattedItemDate:array[index]];
            
            if ([array[index][@"type"] isEqualToString:@"eventos"])
                detailsVC.objectTime = itemDate;
            else
                detailsVC.objectTime = array[index][@"short_detail"];
            detailsVC.objectLocation = self.itemLocationName;
            detailsVC.navigationBarTitle = array[index][@"name"];
            [self.navigationController pushViewController:detailsVC animated:YES];
        }
        
        //If open inside value is 'outside', we open the url externally using safari.
        else if ([array[index][@"open_inside"] isEqualToString:@"outside"])
        {
            NSURL *url = [NSURL URLWithString:array[index][@"external_url"]];
            
            //If the URL couldn't be opened, display an alert to inform the user.
            if (![[UIApplication sharedApplication] openURL:url])
            {
                [[[UIAlertView alloc] initWithTitle:nil
                                            message:@"Oops!, no se pudo abrir la URL en este momento."
                                           delegate:self
                                  cancelButtonTitle:@"" otherButtonTitles:nil] show];
            }
        }
        
        //If open inside is 'inside', display the url internally using our WebViewController.
        else
        {
            WebViewController *webViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"Web"];
            webViewController.urlString = array[index][@"external_url"];
            [self.navigationController pushViewController:webViewController animated:YES];
        }
    }
    
    //if the item doesn't have an external url, open the detail view.
    else
    {
        DetailsViewController *detailsVC = [self.storyboard instantiateViewControllerWithIdentifier:@"EventDetails"];
        detailsVC.objectInfo = array[index];
        self.itemLocationName = [self getItemLocation:array[index]];
        NSString *itemDate = [self getFormattedItemDate:array[index]];
        
        if ([array[index][@"type"] isEqualToString:@"eventos"])
            detailsVC.objectTime = itemDate;
        else
            detailsVC.objectTime = array[index][@"short_detail"];

        detailsVC.objectLocation = self.itemLocationName;
        detailsVC.navigationBarTitle = array[index][@"name"];
        [self.navigationController pushViewController:detailsVC animated:YES];
    }
}

#pragma mark - UICollectionViewDelegate & UICollectionViewDataSource

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    //When the user selectes an item in the CollectionView's, first we have to
    //determine which CollectionView was pressed, and the index path of the
    //the selected item and pass this info to -goToNextViewControllerFromItems...,
    //method than handles the selection.
    if (collectionView.tag == 0)
        [self goToNextViewControllerFromItemInArray:self.specialItemsArray atIndex:indexPath.row];
    
    if (collectionView.tag == 1)
        [self goToNextViewControllerFromItemInArray:self.featuredEventsArray atIndex:indexPath.row];
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if (collectionView.tag == 0)
    {
        return [self.specialItemsArray count];
    }
    
    else if (collectionView.tag == 1)
        return [self.featuredEventsArray count];
    else
        return 0;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    //Special items CollectionView
    if (collectionView.tag == 0)
    {
        /*AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
        [appDelegate incrementNetworkActivity];*/
        
        DestacadosCollectionViewCell *specialEventCell = (DestacadosCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:SPECIAL_IDENTIFIER forIndexPath:indexPath];
        
        specialEventCell.featuredEventNameLabel.text = self.specialItemsArray[indexPath.item][@"short_detail"];
        specialEventCell.featuredEventImageView.image = [UIImage imageNamed:@"CaracolPrueba4.png"];
        
        //Use the method -setImageURL to download the image from the server and store it in caché.
        [specialEventCell.featuredEventImageView setImageWithURL:self.specialItemsArray[indexPath.row][@"thumb_url"]
                                                placeholderImage:[UIImage imageNamed:@"CaracolPrueba4.png"]
                                                       completed:^(UIImage *image, NSError *error, SDImageCacheType type){
                                                           //[appDelegate decrementNetworkActivity];
                                                       }];
        
        
        return specialEventCell;
    }
    
    //Featured items collection view.
    else if (collectionView.tag == 1)
    {
        /*AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
        [appDelegate incrementNetworkActivity];*/
        
        DestacadosCollectionViewCell *featuredEventCell = (DestacadosCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:FEATURED_IDENTIFIER forIndexPath:indexPath];
        
        featuredEventCell.featuredEventNameLabel.text = self.featuredEventsArray[indexPath.item][@"short_detail"];
        
        [featuredEventCell.featuredEventImageView setImageWithURL:self.featuredEventsArray[indexPath.row][@"thumb_url"]
                                                 placeholderImage:[UIImage imageNamed:@"CaracolPrueba4.png"]
                                                        completed:^(UIImage *image, NSError *error, SDImageCacheType type){
                                                            //[appDelegate decrementNetworkActivity];
                                                        }];
        
        return featuredEventCell;
    }
    else
        return nil;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (collectionView.tag == 0)
        return CGSizeMake(self.view.frame.size.width, self.view.frame.size.height/4.3);
    
    else if (collectionView.tag == 1)
    {
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
            return indexPath.item % 3 ? CGSizeMake(367, 205) : CGSizeMake(collectionView.frame.size.width - 20, 205);
        else
            return indexPath.item % 3 ? CGSizeMake(144, 114):CGSizeMake(collectionView.frame.size.width - 20, 114);
    }
    
    else
        return CGSizeZero;
}

#pragma mark - UIScrollViewDelegate
-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (scrollView.tag == 0)
    {
        NSLog(@"terminé de dragearme");
        [self.timer invalidate];
        self.timer = nil;
        self.timer = [NSTimer scheduledTimerWithTimeInterval:5.0
                                                      target:self
                                                    selector:@selector(slideShowSpecialItems)
                                                    userInfo:nil
                                                     repeats:YES];
    }
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if ([scrollView tag] == 0)
    {
        //We use this method to determine the curren page of the special items ScrollView.
        CGFloat pageWidth = self.specialItemsCollectionView.frame.size.width;
        float fractionalPage = self.specialItemsCollectionView.contentOffset.x / pageWidth;
        self.currentPage = round(fractionalPage) + 1;
    }
}

#pragma mark - MFMailComposeDelegate

-(void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - MFMessageComposeViewControllerDelegate

-(void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UIActionSheetDelegate

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    //SMS button
    if(buttonIndex == 0)
    {
        NSLog(@"SMS");
        if (![MFMessageComposeViewController canSendText])
        {
            NSLog(@"No se pueden enviar mensajes");
        }
        
        else
        {
            MFMessageComposeViewController *messageViewController = [[MFMessageComposeViewController alloc] init];
            messageViewController.messageComposeDelegate = self;
            [messageViewController setBody:@"¿Ya conoces la aplicación BogoTaxi?, BogoTaxi es la mejor herramienta para medir tu trayectoria y calcular el costo a pagar en un Taxi para la ciudad de Bogotá. Disponible en el AppStore. https://itunes.apple.com/co/app/bogotaxi/id474509867?mt=8"];
            //[messageViewController addAttachmentURL:<#(NSURL *)#> withAlternateFilename:<#(NSString *)#>]
            [self presentViewController:messageViewController animated:YES completion:nil];
            NSLog(@"presenté el viewcontroller");
        }
    }
    
    //Facebook button
    else if (buttonIndex == 1)
    {
        NSLog(@"Facebook");
        
        SLComposeViewController *facebookViewController = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
        [facebookViewController setInitialText:@"Post de Prueba. ¿Ya conoces la aplicación BogoTaxi?, BogoTaxi es la mejor herramienta para medir tu trayectoria y calcular el costo a pagar en un Taxi para la ciudad de Bogotá. Disponible en el AppStore."];
        [facebookViewController addURL:[NSURL URLWithString:@"https://itunes.apple.com/co/app/bogotaxi/id474509867?mt=8"]];
        [self presentViewController:facebookViewController animated:YES completion:nil];
    }
    
    //Twitter button
    else if (buttonIndex == 2)
    {
        NSLog(@"Twitter");
        
        SLComposeViewController *twitterViewController = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
        [twitterViewController setInitialText:@"Post de Prueba. ¿Ya conoces la aplicación BogoTaxi?, BogoTaxi es la mejor herramienta para medir tu trayectoria y calcular el costo a pagar en un Taxi para la ciudad de Bogotá. Disponible en el AppStore."];
        [twitterViewController addURL:[NSURL URLWithString:@"https://itunes.apple.com/co/app/bogotaxi/id474509867?mt=8"]];
        [self presentViewController:twitterViewController animated:YES completion:nil];
    }
    
    //Email button
    else if (buttonIndex == 3)
    {
        NSLog(@"Mail");
        MFMailComposeViewController *mailComposeViewController = [[MFMailComposeViewController alloc] init];
        [mailComposeViewController setSubject:@"Te recomiendo la app 'BogoTaxi'"];
        [mailComposeViewController setMessageBody:@"¿Ya conoces la aplicación BogoTaxi?, BogoTaxi es la mejor herramienta para medir tu trayectoria y calcular el costo a pagar en un Taxi para la ciudad de Bogotá. Disponible en el AppStore. https://itunes.apple.com/co/app/bogotaxi/id474509867?mt=8" isHTML:NO];
        
        mailComposeViewController.mailComposeDelegate = self;
        [self presentViewController:mailComposeViewController animated:YES completion:nil];
    }
}

#pragma mark - FileSaver Stuff

-(NSDictionary*)getDictionaryWithName:(NSString*)name
{
    FileSaver *file=[[FileSaver alloc]init];
    return [file getDictionary:name];
}

-(void)setDictionary:(NSDictionary*)dictionary withName:(NSString*)name
{
    FileSaver *file=[[FileSaver alloc]init];
    [file setDictionary:dictionary withKey:name];
}

@end
