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
@property (strong, nonatomic) UIScrollView *scrollView;
@property (strong, nonatomic) UICollectionView *specialItemsCollectionView;
@property (strong, nonatomic) NSTimer * timer;
@property (nonatomic) NSInteger currentPage;
@property (strong, nonatomic) NSString *itemLocationName;
@property (strong, nonatomic) UIView *blockTouchesView;
@property (strong, nonatomic) UIButton *sideBarButton;
@property (strong, nonatomic) UIButton *shareButton;
@property (assign, nonatomic) int numberOfPages;
@property (assign, nonatomic) BOOL draggingScrollView;
@property (assign, nonatomic) NSInteger automaticCounter;
@end

@implementation DestacadosViewController

#pragma mark - View Lifecycle

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    NSLog(@"Aparecí y activé el timer");
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
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:249.0/255.0 green:170.0/255.0 blue:0.0 alpha:1.0];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor whiteColor]};
    
    //////////////////////////////////////////////////////
    //Create the back button of the NavigationBar. When pressed, this button
    //display the slide menu.
    self.sideBarButton = [[UIButton alloc] initWithFrame:CGRectMake(5.0, 9.0, 30.0, 30.0)];
    [self.sideBarButton addTarget:self action:@selector(showSideBarMenu:) forControlEvents:UIControlEventTouchUpInside];
    [self.sideBarButton setBackgroundImage:[UIImage imageNamed:@"SidebarIcon.png"] forState:UIControlStateNormal];
    [self.navigationController.navigationBar addSubview:self.sideBarButton];
    
    //ShareButton
    self.shareButton = [[UIButton alloc] initWithFrame:CGRectMake(self.navigationController.navigationBar.frame.size.width - 40.0, 5.0, 35.0, 35.0)];
    [self.shareButton addTarget:self action:@selector(shareApp) forControlEvents:UIControlEventTouchUpInside];
    [self.shareButton setBackgroundImage:[UIImage imageNamed:@"ShareIconWhite.png"] forState:UIControlStateNormal];
    [self.navigationController.navigationBar addSubview:self.shareButton];
}

-(void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    self.scrollView.contentOffset = CGPointMake(self.scrollView.contentOffset.x, 0.0);
}


-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    NSLog(@"desaparecí");
    //Stop the timer.
    [self.timer invalidate];
    self.timer = nil;
    NSLog(@"desapareceré y desactivaré el timer");
    
    [self.sideBarButton removeFromSuperview];
    [self.shareButton removeFromSuperview];
}

/*-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    //[self.specialItemsCollectionView setContentOffset:CGPointMake(0.0, 0.0) animated:NO];
}*/

-(void)viewDidLoad
{
    [super viewDidLoad];
    self.automaticCounter = 2;
    self.revealViewController.delegate = self;
    self.blockTouchesView = [[UIView alloc] initWithFrame:self.view.frame];
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

    
    /*UIBarButtonItem *sideBarButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"SidebarIcon.png"]
                                                                      style:UIBarButtonItemStylePlain
                                                                     target:self.revealViewController
                                                                     action:@selector(revealToggle:)];*/
    
    //Create a NavigationBar button to share the app.
    /*UIBarButtonItem *shareButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ShareIcon.png"]
                                                                    style:UIBarButtonItemStylePlain
                                                                   target:self
                                                                   action:@selector(shareApp)];*/
    
    //Add the buttons to the NavigationBar.
    //self.navigationItem.rightBarButtonItem = shareButton;
    //self.navigationItem.leftBarButtonItem = sideBarButton;
    
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
    titleLabel.textColor = [UIColor colorWithRed:133.0/255.0 green:101.0/255.0 blue:0.0 alpha:1.0];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    self.navigationItem.titleView = titleLabel;
    
    //define an array with only the featured events information
    self.featuredEventsArray = [self getDictionaryWithName:@"master"][@"destacados"];
    
    //Define an array with the special items
    self.specialItemsArray = [self getDictionaryWithName:@"master"][@"especiales"];
    
    /////////////////////////////////////////////////////////////
    //Create UICollectionView to display the special items
    /*UICollectionViewFlowLayout *specialItemsCollectionViewLayout = [[UICollectionViewFlowLayout alloc] init];
    specialItemsCollectionViewLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    self.specialItemsCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0.0, self.navigationController.navigationBar.frame.origin.y + self.navigationController.navigationBar.frame.size.height, self.view.bounds.size.width, self.view.bounds.size.height/4.3) collectionViewLayout:specialItemsCollectionViewLayout];
    
    specialItemsCollectionViewLayout.minimumInteritemSpacing = 1;
    specialItemsCollectionViewLayout.minimumLineSpacing = 1;
    self.specialItemsCollectionView.contentInset = UIEdgeInsetsMake(1.0, 1.0, 1.0, 1.0);
    
    self.specialItemsCollectionView.tag = 0;
    self.specialItemsCollectionView.showsHorizontalScrollIndicator = NO;
    self.specialItemsCollectionView.dataSource = self;
    self.specialItemsCollectionView.delegate = self;
    self.specialItemsCollectionView.alwaysBounceHorizontal = YES;
    self.specialItemsCollectionView.pagingEnabled = YES;
    self.specialItemsCollectionView.backgroundColor = [UIColor cyanColor];
    [self.specialItemsCollectionView registerClass:[DestacadosCollectionViewCell class] forCellWithReuseIdentifier:SPECIAL_IDENTIFIER];
    self.specialItemsCollectionView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.specialItemsCollectionView];*/
    
    /////////////////////////////////////////////////////////////
    //1. Create a ScrollView to display the main images
    self.scrollView = [[UIScrollView alloc] init];
    self.scrollView.frame = CGRectMake(0.0, self.navigationController.navigationBar.frame.origin.y + self.navigationController.navigationBar.frame.size.height, self.view.bounds.size.width, self.view.bounds.size.height/4.3);
    self.scrollView.backgroundColor = [UIColor whiteColor];
    self.scrollView.pagingEnabled = YES;
    self.scrollView.delegate = self;
    self.scrollView.tag = 2;
    self.scrollView.alwaysBounceVertical = NO;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.directionalLockEnabled = YES;
    self.scrollView.userInteractionEnabled = YES;
    [self.view addSubview:self.scrollView];
    
    //Create two pages at the left and right limit of the scroll view, this is used to
    //make the effect of a circular scroll view.
    [self createPageAtPosition:0 withSpecialItemInfo:[self.specialItemsArray lastObject]];
    [self createPageAtPosition:[self.specialItemsArray count] + 1 withSpecialItemInfo:[self.specialItemsArray firstObject]];
    
    for (int i = 1; i <= [self.specialItemsArray count]; i++) {
        NSDictionary *specialItemDic = self.specialItemsArray[i - 1];
        [self createPageAtPosition:i withSpecialItemInfo:specialItemDic];
        self.numberOfPages = i;
    }
    
    self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width*(self.numberOfPages + 2), self.scrollView.frame.size.height);
    self.scrollView.contentOffset = CGPointMake(320.0, 0.0);
    [self.view addSubview:self.scrollView];
    NSLog(@"Scrollview content size: %@", NSStringFromCGSize(self.scrollView.contentSize));
    NSLog(@"Scrollview frame: %@", NSStringFromCGRect(self.scrollView.bounds));
    
    //Agregar un tap gesture al scrollview
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(specialItemTapped)];
    [self.scrollView addGestureRecognizer:tapGesture];
    
    /////////////////////////////////////////////////////////
    //Create UICollectionView that display the list of featured items
    float margin = 0;
    UICollectionViewFlowLayout *collectionViewLayout = [[UICollectionViewFlowLayout alloc] init];
    UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0.0, self.scrollView.frame.origin.y + self.scrollView.frame.size.height + margin, self.view.frame.size.width, self.view.frame.size.height - (self.scrollView.frame.origin.y + self.scrollView.frame.size.height + margin)) collectionViewLayout:collectionViewLayout];
    collectionView.tag = 1;
    
    collectionViewLayout.minimumInteritemSpacing = 1;
    collectionViewLayout.minimumLineSpacing=1;
    collectionView.contentInset = UIEdgeInsetsMake(1.0, 1.0, 1.0, 1.0);
    
    collectionView.showsVerticalScrollIndicator = NO;
    collectionView.dataSource = self;
    [collectionView setAlwaysBounceVertical:YES];
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

#pragma mark - Custom Methods

-(void)specialItemTapped {
    [self goToNextViewControllerFromItemInArray:self.specialItemsArray atIndex:self.currentPage];
}

-(void)createPageAtPosition:(int)pagePosition withSpecialItemInfo:(NSDictionary *)specialItemDic {
    //Method used to create the pages of the scroll view.
    
    UIView *page = [[UIView alloc] initWithFrame:CGRectMake(self.scrollView.frame.size.width*pagePosition,
                                                            0.0,
                                                            self.scrollView.frame.size.width,
                                                            self.scrollView.frame.size.height)];
    /*-------------------------------------------------------------*/
    //1. ImageView to display the main image
    UIImageView *pageImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0,
                                                                               0.0,
                                                                               self.scrollView.frame.size.width,
                                                                               self.scrollView.frame.size.height)];
    pageImageView.clipsToBounds = YES;
    pageImageView.contentMode = UIViewContentModeScaleAspectFill;
    
    NSURL *pageImageURL = [NSURL URLWithString:specialItemDic[@"thumb_url"]];
    [pageImageView sd_setImageWithURL:pageImageURL placeholderImage:[UIImage imageNamed:@"CaracolPrueba4.png"]];
    [page addSubview:pageImageView];
    
    //Patter view
    UIView *patternView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, page.bounds.size.width, page.bounds.size.height)];
    UIImage *patternImage = [UIImage imageNamed:@"Pattern.png"];
    patternImage = [MyUtilities imageWithName:patternImage ScaleToSize:CGSizeMake(1.0, page.frame.size.height)];
    patternView.backgroundColor = [UIColor colorWithPatternImage:patternImage];
    [page addSubview:patternView];
    
    //2. Name label
    UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0, page.frame.size.height - 40.0, page.frame.size.width - 20.0, 40.0)];
    nameLabel.text = specialItemDic[@"short_detail"];
    nameLabel.font = [UIFont fontWithName:@"Montserrat-Regular" size:13.0];
    nameLabel.textColor = [UIColor whiteColor];
    [page addSubview:nameLabel];
    [self.scrollView addSubview:page];
}

-(void)showSideBarMenu:(id)sender {
    NSLog(@"me oprimiste vé");
    [self.revealViewController revealToggle:sender];
}

-(void)shareApp
{
    [[[UIActionSheet alloc] initWithTitle:nil
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
    /*NSUInteger maxPage = [self.specialItemsArray count];
    
    //Change the content offset of the ScrollView.
    [self.specialItemsCollectionView setContentOffset:CGPointMake(self.view.frame.size.width*self.currentPage, 0.0) animated:YES];
    
    //If the presentation is in the last page, go back to page 1.
    if (self.currentPage == maxPage)
    {
        [self.specialItemsCollectionView setContentOffset:CGPointMake(0.0, 0.0) animated:YES];
        self.currentPage = 1;
    }*/
    
    [self.scrollView setContentOffset:CGPointMake(self.scrollView.bounds.size.width*self.automaticCounter, 0.0) animated:YES];
    self.automaticCounter ++;
    NSLog(@"el contador está en %d", self.automaticCounter);
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
        [specialEventCell.featuredEventImageView sd_setImageWithURL:self.specialItemsArray[indexPath.row][@"thumb_url"]
                                                   placeholderImage:[UIImage imageNamed:@"CaracolPrueba4.png"]];
        
        return specialEventCell;
    }
    
    //Featured items collection view.
    else if (collectionView.tag == 1)
    {
        /*AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
        [appDelegate incrementNetworkActivity];*/
        
        DestacadosCollectionViewCell *featuredEventCell = (DestacadosCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:FEATURED_IDENTIFIER forIndexPath:indexPath];
        
        featuredEventCell.featuredEventNameLabel.text = self.featuredEventsArray[indexPath.item][@"short_detail"];
        [featuredEventCell.featuredEventImageView sd_setImageWithURL:self.featuredEventsArray[indexPath.row][@"thumb_url"] placeholderImage:[UIImage imageNamed:@"CaracolPrueba4.png"]];
        /*[featuredEventCell.featuredEventImageView setImageWithURL:self.featuredEventsArray[indexPath.row][@"thumb_url"]
                                                 placeholderImage:[UIImage imageNamed:@"CaracolPrueba4.png"]
                                                        completed:^(UIImage *image, NSError *error, SDImageCacheType type){
                                                            //[appDelegate decrementNetworkActivity];
                                                        }];*/
        
        return featuredEventCell;
    }
    else
        return nil;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (collectionView.tag == 0)
        return CGSizeMake([UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height/4.3);
    
    else if (collectionView.tag == 1)
    {
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
            return indexPath.item % 3 ? CGSizeMake(367, 205) : CGSizeMake(collectionView.frame.size.width - 20, 205);
        else
            //return indexPath.item % 3 ? CGSizeMake(149, 114):CGSizeMake(collectionView.frame.size.width - 12, 114);
            return indexPath.item % 3 ? CGSizeMake(158.5, 114):CGSizeMake(collectionView.frame.size.width - 2, 114);

    }
    
    else
        return CGSizeZero;
}

#pragma mark - UIScrollViewDelegate
-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (scrollView.tag == 0)
    {
        /*NSLog(@"terminé de dragearme");
        [self.timer invalidate];
        self.timer = nil;
        self.timer = [NSTimer scheduledTimerWithTimeInterval:5.0
                                                      target:self
                                                    selector:@selector(slideShowSpecialItems)
                                                    userInfo:nil
                                                     repeats:YES];*/
    } else if (scrollView.tag == 2) {
        NSLog(@"Terminaré de draggearme");
        self.draggingScrollView = NO;
    }
}

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    NSLog(@"Empzaréeee");
    self.draggingScrollView = YES;
    [self.timer invalidate];
    self.timer = nil;
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView.tag == 2) {
        float pageWidth = self.scrollView.frame.size.width;
        float fractionalPage = self.scrollView.contentOffset.x / pageWidth;
        NSInteger page = lroundf(fractionalPage);
        self.currentPage = page - 1;
        
        //NSLog(@"Content offset: %f", scrollView.contentOffset.y);
        if (self.draggingScrollView && scrollView.contentOffset.y != 0) {
            [scrollView setContentOffset:CGPointMake(scrollView.contentOffset.x, 0.0) animated:NO];
        }
    }
    else if ([scrollView tag] == 0)
    {
        //We use this method to determine the curren page of the special items ScrollView.
        /*CGFloat pageWidth = self.specialItemsCollectionView.frame.size.width;
        float fractionalPage = self.specialItemsCollectionView.contentOffset.x / pageWidth;
        self.currentPage = round(fractionalPage) + 1;*/
    }
}

-(void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    NSLog(@"terminé de animarme");
    if (self.scrollView.contentOffset.x < 320.0) {
        //the user scroll from page 1 to the left, so we have to set the content offset
        //of the scroll view to the last page
        [self.scrollView setContentOffset:CGPointMake(320.0*self.numberOfPages, 0.0) animated:NO];
        self.currentPage = [self.specialItemsArray count] - 1;
    } else if (self.scrollView.contentOffset.x >= 320 * (self.numberOfPages + 1)) {
        NSLog(@"llegué al final");
        [self.scrollView setContentOffset:CGPointMake(320.0, 0.0) animated:NO];
        self.currentPage = 0;
        self.automaticCounter = 2;
    }
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if (self.scrollView.contentOffset.x < 320.0) {
        //the user scroll from page 1 to the left, so we have to set the content offset
        //of the scroll view to the last page
        [self.scrollView setContentOffset:CGPointMake(320.0*self.numberOfPages, 0.0) animated:NO];
        self.currentPage = [self.specialItemsArray count] - 1;
    } else if (self.scrollView.contentOffset.x >= 320 * (self.numberOfPages + 1)) {
        [self.scrollView setContentOffset:CGPointMake(320.0, 0.0) animated:NO];
        self.currentPage = 0;
    }
    
    self.automaticCounter = self.currentPage + 2;
    
    [self.timer invalidate];
    self.timer = nil;
    self.timer = [NSTimer scheduledTimerWithTimeInterval:5.0
                                                  target:self
                                                selector:@selector(slideShowSpecialItems)
                                                userInfo:nil
                                                 repeats:YES];
}

#pragma mark - SWRevealViewControllerDelegate

-(void)revealController:(SWRevealViewController *)revealController didMoveToPosition:(FrontViewPosition)position
{
    if (position == FrontViewPositionLeft) {
        NSLog(@"Cerré el menú");
        [self.blockTouchesView removeFromSuperview];
        [self.timer invalidate];
        self.timer = nil;
        self.timer = [NSTimer scheduledTimerWithTimeInterval:5.0
                                                      target:self
                                                    selector:@selector(slideShowSpecialItems)
                                                    userInfo:nil
                                                     repeats:YES];
        
    }
    else if (position == FrontViewPositionRight) {
        NSLog(@"Abrí el menú");
        [self.view addSubview:self.blockTouchesView];
        [self.timer invalidate];
    }
}

-(void)revealController:(SWRevealViewController *)revealController animateToPosition:(FrontViewPosition)position {
    if (position == FrontViewPositionLeft) {
        NSLog(@"me animé a la pantalla principal");
        [[NSNotificationCenter defaultCenter] postNotificationName:@"StatusBarMustBeTransparentNotification" object:nil];
    } else {
        NSLog(@"Me animé al menú");
        [[NSNotificationCenter defaultCenter] postNotificationName:@"StatusBarMustBeOpaqueNotification" object:nil];
    }
    
}

-(void)revealController:(SWRevealViewController *)revealController willMoveToPosition:(FrontViewPosition)position {
    NSLog(@"me moveré");
}

-(void)revealController:(SWRevealViewController *)revealController panGestureMovedToLocation:(CGFloat)location progress:(CGFloat)progress {
    //NSLog(@"moviendooo: %f", progress);
    [[NSNotificationCenter defaultCenter] postNotificationName:@"PanningNotification" object:nil userInfo:@{@"PanningProgress": @(progress)}];
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
            [[[UIAlertView alloc] initWithTitle:@"No se puede enviar SMS"
                                       message:@"Tu dispositivo no está configurado para enviar mensajes."
                                      delegate:self
                             cancelButtonTitle:@"Ok"
                              otherButtonTitles:nil] show];
        }
        
        else
        {
            MFMessageComposeViewController *messageViewController = [[MFMessageComposeViewController alloc] init];
            messageViewController.messageComposeDelegate = self;
            [messageViewController setBody:[self getDictionaryWithName:@"master"][@"app"][@"social_message"]];
            [self presentViewController:messageViewController animated:YES completion:nil];
            NSLog(@"presenté el viewcontroller");
        }
    }
    
    //Facebook button
    else if (buttonIndex == 1)
    {
        NSLog(@"Facebook");
        
        SLComposeViewController *facebookViewController = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
        [facebookViewController setInitialText:[self getDictionaryWithName:@"master"][@"app"][@"social_message"]];
        [self presentViewController:facebookViewController animated:YES completion:nil];
    }
    
    //Twitter button
    else if (buttonIndex == 2)
    {
        NSLog(@"Twitter");
        
        SLComposeViewController *twitterViewController = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
        [twitterViewController setInitialText:[self getDictionaryWithName:@"master"][@"app"][@"social_message"]];
        [self presentViewController:twitterViewController animated:YES completion:nil];
    }
    
    //Email button
    else if (buttonIndex == 3)
    {
        NSLog(@"Mail");
        MFMailComposeViewController *mailComposeViewController = [[MFMailComposeViewController alloc] init];
        [mailComposeViewController setSubject:@"Te recomiendo la app 'eurocine 2014'"];
        [mailComposeViewController setMessageBody:[self getDictionaryWithName:@"master"][@"app"][@"social_message"] isHTML:NO];
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
            mailComposeViewController.modalPresentationStyle = UIModalPresentationFormSheet;
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
