//
//  EventsListViewController.m
//  EventosCaracol
//
//  Created by Developer on 20/11/13.
//  Copyright (c) 2013 iAmStudio. All rights reserved.
//

#import "ListViewController.h"

@interface ListViewController ()
@property (strong, nonatomic)  UITableView *tableView;
@property (strong, nonatomic) UIPickerView *locationPickerView;
@property (strong, nonatomic) UIPickerView *datePickerView;
@property (strong, nonatomic) UIView *containerLocationPickerView;
@property (strong, nonatomic) UIView *containerDatesPickerView;
@property (strong, nonatomic) UIImageView *updateImageView;
@property (nonatomic) NSUInteger rowIndex; //Used for detecting which row we have to update
                                            //when the user favorites an item.
@property (nonatomic) BOOL isPickerActivated;
@property (nonatomic) float offset;
@property (nonatomic) BOOL isUpdating;
@property (nonatomic) BOOL shouldUpdate;
@property (strong, nonatomic) UIActivityIndicatorView *spinner;
@property (strong, nonatomic) NSMutableArray *isFavoritedArray;
@property (nonatomic) NSUInteger favoriteIndex;
@end

#define ROW_HEIGHT 95.0

@implementation ListViewController

#pragma mark - View LifeCycle

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    
    //We need to set this properties every time the view appears, because
    //there are more view controllers that change this properties.
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:144.0/255.0 green:192.0/255.0 blue:58.0/255.0 alpha:1.0];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor whiteColor]};
}

-(void)viewDidLoad
{
    [super viewDidLoad];
    SWRevealViewController *revealViewController = [self revealViewController];

    //Add this view controller as an observer of the notification center. it will
    //observe for a notification that is post when the user favorites an item in
    //the item detail view.
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateFavItemsWithNotification:)
                                                 name:@"FavItemNotification"
                                               object:nil];
    
    //Set an array for storing the favorite state of the items. if an item is not
    //favorite, it will store 0, otherwise it will store 1. We need to know this
    //state for displaying the correct heart image when the user swipes left in a cell.
    self.isFavoritedArray = [[NSMutableArray alloc] initWithCapacity:[self.menuItemsArray count]];
    
    if (!self.locationList)
    {
        UIBarButtonItem *slideMenuBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"SidebarIcon.png"]
                                                                                   style:UIBarButtonItemStylePlain
                                                                                  target:revealViewController
                                                                                  action:@selector(revealToggle:)];
        self.navigationItem.leftBarButtonItem = slideMenuBarButtonItem;
        [self.view addGestureRecognizer:revealViewController.panGestureRecognizer];
    }
    
    //Configure the backBarButtonItem that will be displayed in the Navigation Bar when the user moves to EventDetailsViewController
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Atrás"
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:self
                                                                            action:nil];
    self.navigationItem.title = self.navigationBarTitle;
    
    ///////////////////////////////////////////////////////////////////
    //Create two buttons to filter the events list by date and by location
    //this buttons will not be displayed when the user is on the locations list.
    if (!self.locationList)
    {
        UIButton *filterByDayButton = [[UIButton alloc]
                                       initWithFrame:CGRectMake(0,
                                                                self.navigationController.navigationBar.frame.origin.y + self.navigationController.navigationBar.frame.size.height,
                                                                self.view.frame.size.width/2,
                                                                44.0)];
        
        //We need to set the button tag of filterByDayButton and filterByLocationButton to show the correct picker
        //when the user touches one of these buttons.
        filterByDayButton.tag = 1;
        
        [filterByDayButton addTarget:self action:@selector(showPickerView:) forControlEvents:UIControlEventTouchUpInside];
        [filterByDayButton setBackgroundImage:[UIImage imageNamed:@"BotonTodosLosSitios.png"] forState:UIControlStateNormal];
        [filterByDayButton setTitle:@"Todos los dias" forState:UIControlStateNormal];
        filterByDayButton.titleLabel.font = [UIFont fontWithName:@"Helvetica" size:14.0];
        [filterByDayButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
        [self.view addSubview:filterByDayButton];
        
        //Filter by location button
        UIButton *filterByLocationButton = [[UIButton alloc]
                                            initWithFrame:CGRectMake(self.view.frame.size.width/2,
                                                                     self.navigationController.navigationBar.frame.origin.y + self.navigationController.navigationBar.frame.size.height,
                                                                     self.view.frame.size.width/2,
                                                                     44.0)];
        filterByLocationButton.tag = 2;
        
        [filterByLocationButton addTarget:self action:@selector(showPickerView:) forControlEvents:UIControlEventTouchUpInside];
        [filterByLocationButton setBackgroundImage:[UIImage imageNamed:@"BotonTodosLosSitios.png"] forState:UIControlStateNormal];
        filterByLocationButton.titleLabel.font = [UIFont fontWithName:@"Helvetica" size:14.0];
        [filterByLocationButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
        [filterByLocationButton setTitle:@"Todos los lugares" forState:UIControlStateNormal];
        [self.view addSubview:filterByLocationButton];
        
        self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, filterByLocationButton.frame.origin.y + filterByLocationButton.frame.size.height, self.view.frame.size.width, self.view.frame.size.height - (filterByLocationButton.frame.origin.y + filterByLocationButton.frame.size.height)) style:UITableViewStylePlain];
        [self.view addSubview:self.tableView];
    }
    
    else
    {
        self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0,
                                                                       self.navigationController.navigationBar.frame.origin.y + self.navigationController.navigationBar.frame.size.height,
                                                                       self.view.frame.size.width,
                                                                       self.view.frame.size.height - ( self.navigationController.navigationBar.frame.origin.y + self.navigationController.navigationBar.frame.size.height))
                                                      style:UITableViewStylePlain];
        //self.tableView.contentInset = UIEdgeInsetsMake(64.0, 0.0, 0.0, 0.0);
        [self.view addSubview:self.tableView];
    }
    
    ///////////////////////////////////////////////////////////////////
    //Table View initialization and configuration
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.rowHeight = ROW_HEIGHT;
    self.tableView.allowsSelection = YES;
    //self.tableView.separatorInset = UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0);
    [self setupPullDownToRefreshView];
    
    ///////////////////////////////////////////////////////////////////
    //Configure locationPickerView
    self.locationPickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(0.0,
                                                                             0.0,
                                                                             self.containerLocationPickerView.frame.size.width,
                                                                             self.containerLocationPickerView.frame.size.height)];
    self.locationPickerView.tag = 2;
    self.locationPickerView.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:1.0];
    self.locationPickerView.delegate = self;
    self.locationPickerView.dataSource = self;
    
    /////////////////////////////////////////////////////////////////
    //Configure datePickerView
    self.datePickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(0.0,
                                                                         0.0,
                                                                         self.containerLocationPickerView.frame.size.width,
                                                                         self.containerLocationPickerView.frame.size.height)];
    self.datePickerView.tag = 1;
    self.datePickerView.delegate = self;
    self.datePickerView.dataSource = self;
    
    ////////////////////////////////////////////////////////////////////
    //Configure container view for the Location Picker
    self.containerLocationPickerView = [[UIView alloc] initWithFrame:CGRectMake(0.0, self.view.frame.size.height, self.view.frame.size.width, self.view.frame.size.height/2.5)];
    self.containerLocationPickerView.backgroundColor = [UIColor whiteColor];
    [self.containerLocationPickerView addSubview:self.locationPickerView];
    
    //////////////////////////////////////////////////////////////////
    //Configure container view for the Dates picker.
    self.containerDatesPickerView = [[UIView alloc] initWithFrame:CGRectMake(0.0, self.view.frame.size.height, self.view.frame.size.width, self.view.frame.size.height/2.5)];
    self.containerDatesPickerView.backgroundColor = [UIColor whiteColor];
    [self.containerDatesPickerView addSubview:self.datePickerView];

    
    /////////////////////////////////////////////////////////////////
    //Create a button to dismiss the location picker view.
    UIButton *dismissLocationPickerButton = [[UIButton alloc] initWithFrame:CGRectMake(self.containerLocationPickerView.frame.size.width - 40.0, self.containerLocationPickerView.frame.size.height - 40.0, 40.0, 40.0)];
    dismissLocationPickerButton.tag = 2;
    dismissLocationPickerButton.backgroundColor = [UIColor purpleColor];
    [dismissLocationPickerButton addTarget:self action:@selector(showPickerView:) forControlEvents:UIControlEventTouchUpInside];
    [self.containerLocationPickerView addSubview:dismissLocationPickerButton];
    
    /////////////////////////////////////////////////////////////////
    UIButton *dismissDatePickerButton = [[UIButton alloc] initWithFrame:CGRectMake(self.containerDatesPickerView.frame.size.width - 40.0,self.containerDatesPickerView.frame.size.height - 40.0, 40.0, 40.0)];
    dismissDatePickerButton.tag = 1;
    dismissDatePickerButton.backgroundColor = [UIColor purpleColor];
    [dismissDatePickerButton addTarget:self action:@selector(showPickerView:) forControlEvents:UIControlEventTouchUpInside];
    [self.containerDatesPickerView addSubview:dismissDatePickerButton];
}

-(void)viewWillDisappear:(BOOL)animated
{
    //If any of the picker containers views is on view, remove it.
    if ([self.containerLocationPickerView isDescendantOfView:self.view])
    {
        NSLog(@"ContainerLocationPickerView estaba en self.view");
        [self.containerLocationPickerView removeFromSuperview];
    }
    
    if ([self.containerDatesPickerView isDescendantOfView:self.view])
    {
        NSLog(@"ContainerDatesPickerView estaba en self.view ");
        [self.containerDatesPickerView removeFromSuperview];
    }
    
    //We have to set isPickerActivated to NO, so when the user come back to this view and press any of the buttons to
    //show the picker, it will animate.
    self.isPickerActivated = NO;
}

#pragma mark - UITableViewDelegate & UITableViewDataSource

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.menuItemsArray count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ///////////////////////////////////////////////////////////////////
    //Dequeue our custom cell SWTableViewCell
    static NSString *cellIdentifier=@"EventCell";
    SWTableViewCell *eventCell = (SWTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    //Array for storing our left and right buttons, which become visible when the user swipes in the cell.
    NSMutableArray *leftButtons = [[NSMutableArray alloc] init];
    
    //////////////////////////////////////////////////////////////////////////
    //Check if the cell's item is favorite or not.
    NSArray *favoriteItemsArray = [self getDictionaryWithName:@"user"][@"favorited_atoms"];
    UIImage *favoritedImage;
    if ([favoriteItemsArray containsObject:self.menuItemsArray[indexPath.row][@"_id"]])
    {
        [self.isFavoritedArray addObject:@1];
        favoritedImage = [UIImage imageNamed:@"SwipCellFavoriteActive.png"];
    }
    
    else
    {
        [self.isFavoritedArray addObject:@0];
        favoritedImage = [UIImage imageNamed:@"SwipCellFavorite.png"];
    }
    
    NSLog(@"%@", self.isFavoritedArray[indexPath.row]);

    [leftButtons sw_addUtilityButtonWithColor:[UIColor clearColor] icon:favoritedImage];
    [leftButtons sw_addUtilityButtonWithColor:[UIColor clearColor] icon:[UIImage imageNamed:@"SwipCellShare.png"]];
    
    eventCell = [[SWTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                        reuseIdentifier:cellIdentifier
                                    containingTableView:tableView
                                    leftUtilityButtons:leftButtons
                                    rightUtilityButtons:nil];
        
    eventCell.delegate = self;
    
    /////////////////////////////////////////////////////////////////////
    //Create the subviews that will contain the cell.
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(10.0, 10.0, 100.0, 75.0)];
    imageView.clipsToBounds = YES;
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    imageView.backgroundColor = [UIColor clearColor];
    
  
    [imageView setImageWithURL:self.menuItemsArray[indexPath.row][@"thumb_url"] placeholderImage:[UIImage imageNamed:@"CaracolPrueba4.png"]];
    
    [eventCell.contentView addSubview:imageView];
    
    UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(imageView.frame.origin.x + imageView.frame.size.width + 10,
                                                                   0.0,
                                                                   self.view.frame.size.width - (imageView.frame.origin.x + imageView.frame.size.width + 10),
                                                                   40.0)];
    nameLabel.textAlignment = NSTextAlignmentLeft;
    nameLabel.numberOfLines = 2;
    nameLabel.text = self.menuItemsArray[indexPath.row][@"name"];
    nameLabel.font = [UIFont fontWithName:@"Helvetica" size:15.0];
    [eventCell.contentView addSubview:nameLabel];
    
    ///////////////////////////////////////////////////////////////////////////////
    //Get the item location name
    NSString *itemLocationName = [[NSString alloc] init];
    //First check if we are in a list of locations items. if not, search for the
    //location_id of the item to display it's location in the cell
    if (!self.locationList)
    {
        //First we see if the item has a location associated.
        if ([self.menuItemsArray[indexPath.row][@"location_id"] length] > 0)
        {
            //Location id exist.
            NSArray *locationsArray = [self getDictionaryWithName:@"master"][@"locaciones"];
            for (int i = 0; i < [locationsArray count]; i++)
            {
                if ([self.menuItemsArray[indexPath.row][@"location_id"] isEqualToString:locationsArray[i][@"_id"]])
                {
                    itemLocationName = locationsArray[i][@"name"];
                    break;
                }
            }
        }
        
        else
        {
            itemLocationName = @"";
        }
    }
    
    //if we are in a list of location items, search for the short detail description
    //of the item to display it in the cell.
    else
    {
        itemLocationName = self.menuItemsArray[indexPath.row][@"short_detail"];
    }
    
    
    UILabel *descriptionLabel = [[UILabel alloc] initWithFrame:CGRectMake(nameLabel.frame.origin.x,
                                                                          40.0,
                                                                          self.view.frame.size.width - nameLabel.frame.origin.x,
                                                                          20.0)];
    
    descriptionLabel.text = [NSString stringWithFormat:@"📍%@", itemLocationName];
    descriptionLabel.font = [UIFont fontWithName:@"Helvetica" size:12.0];
    descriptionLabel.textColor = [UIColor lightGrayColor];
    [eventCell.contentView addSubview:descriptionLabel];
    
    /////////////////////////////////////////////////////////////////////////////
    //Get the date of the event
    NSString *eventTime = self.menuItemsArray[indexPath.row][@"event_time"];
    NSString *newString = [eventTime stringByReplacingOccurrencesOfString:@"T" withString:@" "];
    NSString *formattedEventTimeString = [newString stringByReplacingOccurrencesOfString:@".000Z" withString:@""];
    NSLog(@"%@", formattedEventTimeString);
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
    [dateFormatter setLocale:[NSLocale currentLocale]];
    [dateFormatter setTimeZone:[NSTimeZone systemTimeZone]];
    NSDate *sourceDate = [dateFormatter dateFromString:formattedEventTimeString];

    NSTimeZone  *sourceTimeZone = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
    NSTimeZone  *destinationTimeZone = [NSTimeZone systemTimeZone];
    
    NSInteger sourceGMTOffset = [sourceTimeZone secondsFromGMTForDate:sourceDate];
    NSInteger destinationGMTOffset = [destinationTimeZone secondsFromGMTForDate:sourceDate];
    NSTimeInterval interval = destinationGMTOffset - sourceGMTOffset;
    
    NSDate *destinationDate = [[NSDate alloc] initWithTimeInterval:interval sinceDate:sourceDate];
    
    /////////////////////////////////////////////////////////////////////////////////////
    //If we are not in the localist list view, display a label with the time of the event.
    //the location list view don't contain a label for this.
    if (!self.locationList)
    {
        UILabel *eventTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(descriptionLabel.frame.origin.x,
                                                                            descriptionLabel.frame.origin.y + descriptionLabel.frame.size.height, self.view.frame.size.width - descriptionLabel.frame.origin.x,
                                                                            20.0)];
        NSString *finalEventTime = [[destinationDate description] stringByReplacingOccurrencesOfString:@"+0000" withString:@""];
        eventTimeLabel.text = [NSString stringWithFormat:@"🕑 %@", finalEventTime];
        eventTimeLabel.font = [UIFont fontWithName:@"Helvetica" size:12.0];
        eventTimeLabel.textColor = [UIColor lightGrayColor];
        [eventCell.contentView addSubview:eventTimeLabel];
   
    }
    return eventCell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"me tocaron");
    
    //If the item has an external url, we have to check if the url is going to open inside or
    //outside the application.
    if (self.menuItemsArray[indexPath.row][@"external_url"])
    {
        if ([self.menuItemsArray[indexPath.row][@"open_inside"] isEqualToString:@"no"])
        {
            DetailsViewController *detailsVC = [self.storyboard instantiateViewControllerWithIdentifier:@"EventDetails"];
            detailsVC.objectInfo = self.menuItemsArray[indexPath.row];
            
            //We have to check if the cell that the user touched contained a location type object. If so, the next view controller
            //will display a map on screen.
            if (self.locationList)
                detailsVC.presentLocationObject = YES;
            
            detailsVC.navigationBarTitle = self.menuItemsArray[indexPath.row][@"name"];
            [self.navigationController pushViewController:detailsVC animated:YES];
        }
        
        else if ([self.menuItemsArray[indexPath.row][@"open_inside"] isEqualToString:@"outside"])
        {
            NSURL *url = [NSURL URLWithString:self.menuItemsArray[indexPath.row][@"external_url"]];
            if (![[UIApplication sharedApplication] openURL:url])
            {
                [[[UIAlertView alloc] initWithTitle:nil
                                           message:@"Oops!, no se pudo abrir la URL en este momento."
                                          delegate:self
                                 cancelButtonTitle:@"" otherButtonTitles:nil] show];
            }
        }
        
        else //Else if open_inside = inside
        {
            WebViewController *webViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"Web"];
            webViewController.urlString = self.menuItemsArray[indexPath.row][@"external_url"];
            [self.navigationController pushViewController:webViewController animated:YES];
        }
    }
    
    //if the item doesn't have an external url, open the detail view.
    else
    {
        DetailsViewController *detailsVC = [self.storyboard instantiateViewControllerWithIdentifier:@"EventDetails"];
        detailsVC.objectInfo = self.menuItemsArray[indexPath.row];
        //We have to check if the cell that the user touched contained a location type object. If so, the next view controller
        //will display a map on screen.
        if (self.locationList)
            detailsVC.presentLocationObject = YES;
        
        detailsVC.navigationBarTitle = self.menuItemsArray[indexPath.row][@"name"];
        [self.navigationController pushViewController:detailsVC animated:YES];
    }
}

#pragma mark - Custom methods

-(void)setupPullDownToRefreshView
{
    self.updateImageView = [[UIImageView alloc] initWithFrame:CGRectMake(self.view.frame.size.width/2 - 10, -50.0, 20.0, 40.0)];
    self.updateImageView.image = [UIImage imageNamed:@"updateArrow.png"];
    [self.tableView addSubview:self.updateImageView];
}

-(void)postLocalNotificationForItemAtIndex:(NSUInteger)index
{
    NSString *eventTime = self.menuItemsArray[index][@"event_time"];
    NSString *newString = [eventTime stringByReplacingOccurrencesOfString:@"T" withString:@" "];
    NSString *formattedEventTimeString = [newString stringByReplacingOccurrencesOfString:@".000Z" withString:@""];
    NSLog(@"%@", formattedEventTimeString);
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
    [dateFormatter setLocale:[NSLocale currentLocale]];
    [dateFormatter setTimeZone:[NSTimeZone systemTimeZone]];
    
    if (![dateFormatter dateFromString:formattedEventTimeString])
        NSLog(@"no lo formatée");
    else
    {
        /////////////////////////////////////////////////////////////////////////
        NSDate *sourceDate = [dateFormatter dateFromString:formattedEventTimeString];
        
        if ([sourceDate compare:[NSDate date]] == NSOrderedDescending)
        {
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
            ///////////////////////////////////////////////////////////////////////////
            
            UILocalNotification *localNotification = [[UILocalNotification alloc] init];
            localNotification.soundName = UILocalNotificationDefaultSoundName;
            localNotification.userInfo = @{@"name": self.menuItemsArray[index][@"_id"]};
            localNotification.alertBody = [NSString stringWithFormat:@"El evento '%@' es dentro de una hora, no te lo pierdas!", self.menuItemsArray[index][@"name"]];
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
            NSLog(@"EL evento ya pasó entonces no puse ninguna notificación");
        }
    }
}

-(void)updateFavItemsWithNotification:(NSNotification *)notification
{
    [self.tableView reloadData];
}

-(void)makeFavoriteWithIndex:(NSUInteger)index
{
    self.favoriteIndex = index;
    
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
    self.rowIndex = index;
    
    //Create a string that contains the parameters to send to the server.
    NSString *params = [NSString stringWithFormat:@"item_id=%@&user_id=%@&type=%@&app_id=%@", self.menuItemsArray[index][@"_id"], [self getDictionaryWithName:@"user"][@"_id"], self.menuItemsArray[index][@"type"], [self getDictionaryWithName:@"master"][@"app"][@"_id"]];
    ServerCommunicator *serverCommunicator = [[ServerCommunicator alloc] init];
    serverCommunicator.delegate = self;
    
    if ([self.isFavoritedArray[index] intValue] == 0)
    {
        [self postLocalNotificationForItemAtIndex:index];
        [MBHUDView hudWithBody:nil type:MBAlertViewHUDTypeActivityIndicator hidesAfter:1000 show:YES];
        [serverCommunicator callServerWithPOSTMethod:@"FavItem" andParameter:params httpMethod:@"POST"];
    }
    
    /*[MBHUDView hudWithBody:nil type:MBAlertViewHUDTypeActivityIndicator hidesAfter:1000 show:YES];
    
    //Communicate asynchronously with the server
    dispatch_queue_t server = dispatch_queue_create("server", nil);
    dispatch_async(server, ^(){
        if ([self.isFavoritedArray[index] intValue] == 1)
        {
            [serverCommunicator callServerWithPOSTMethod:@"UnFavItem" andParameter:params httpMethod:@"POST"];
            self.isFavoritedArray[index] = @0;
            NSLog(@"me tengo que desfavoritear");
        }
        else
        {
            [serverCommunicator callServerWithPOSTMethod:@"FavItem" andParameter:params httpMethod:@"POST"];
            //self.isFavoritedArray[index] = @1;
            NSLog(@"me tengo que favoritear");
        }
    });*/
     
    NSLog(@"%@", params);
}

-(void)showFavoriteAnimationWithImage:(UIImage *)image
{
    [PopUpView showPopUpViewOverView:self.view image:image];
}

#pragma mark - SWTableViewDelegate

-(void)swippableTableViewCell:(SWTableViewCell *)cell scrollingToState:(SWCellState)state
{
    static int activeCell = 0;
    if (state == kCellStateRight || state == kCellStateLeft)
    {
        NSLog(@"cell index: %d", [self.tableView indexPathForCell:cell].row);
        NSLog(@"scrolling");
        if ([self.tableView indexPathForCell:cell].row != activeCell)
        {
            NSLog(@"escondí");
            SWTableViewCell *cell = (SWTableViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:activeCell
                                                                                             inSection:0]];
            [cell hideUtilityButtonsAnimated:YES];
        }
        activeCell = [self.tableView indexPathForCell:cell].row;
        NSLog(@"Active cell: %d", activeCell);
    }
}

-(void)swippableTableViewCell:(SWTableViewCell *)cell didTriggerLeftUtilityButtonWithIndex:(NSInteger)index
{
    //If the user touches the favorite button of the cell.
    if (index == 0)
    {
        NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
        NSUInteger rowIndex = indexPath.row;
        [self makeFavoriteWithIndex:rowIndex];
    }
    
    //if the user touches the share button of the cell.
    else if (index == 1)
    {
        [[[UIActionSheet alloc] initWithTitle:@""
                                    delegate:self
                           cancelButtonTitle:@"Volver"
                      destructiveButtonTitle:nil
                           otherButtonTitles:@"SMS", @"Facebook", @"Twitter", @"Correo" ,nil] showInView:self.view];
    }
}

-(void)swippableTableViewCell:(SWTableViewCell *)cell didTriggerRightUtilityButtonWithIndex:(NSInteger)index
{
    [PopUpView showPopUpViewOverView:self.view image:[UIImage imageNamed:@"BorrarRojo.png"]];
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
            [messageViewController setBody:@"Hola! te recomiendo este evento!"];
            [self presentViewController:messageViewController animated:YES completion:nil];
            NSLog(@"presenté el viewcontroller");
        }
    }
    
    //Facebook button
    else if (buttonIndex == 1)
    {
        NSLog(@"Facebook");
       
        SLComposeViewController *facebookViewController = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
        [facebookViewController setInitialText:@"Me acabo de inscribir al evento que vamos a ir todos."];
        [self presentViewController:facebookViewController animated:YES completion:nil];
    }
    
    //Twitter button
    else if (buttonIndex == 2)
    {
        NSLog(@"Twitter");
    
        SLComposeViewController *twitterViewController = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
        [twitterViewController setInitialText:@"Me acbo de inscribir a este genial evento"];
        [self presentViewController:twitterViewController animated:YES completion:nil];
    }
    
    //Email button
    else if (buttonIndex == 3)
    {
        NSLog(@"Mail");
        MFMailComposeViewController *mailComposeViewController = [[MFMailComposeViewController alloc] init];
        [mailComposeViewController setSubject:@"Te recomiendo este evento!"];
        [mailComposeViewController setMessageBody:@"¡Hola!, me acabo de inscribir en la presentación del evento al que todos vamos a ir. " isHTML:NO];
        
        mailComposeViewController.mailComposeDelegate = self;
        [self presentViewController:mailComposeViewController animated:YES completion:nil];
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

#pragma mark - UIPickerViewDelegate & UIPickerViewDataSource

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    
}

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return 1;
}

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return @"hola";
}

#pragma mark - Actions

-(void)showPickerView:(id)sender
{
    UIView *containerView = nil;
    if ([sender tag] == 1)
        containerView = self.containerDatesPickerView;
    
    else if ([sender tag] == 2)
        containerView = self.containerLocationPickerView;
        
    //If pickerIsActivated = NO, create and animation to show the picker on screen.
    if (!self.isPickerActivated)
    {
        [self.view addSubview:containerView];
        NSLog(@"me oprimi");
        [UIView animateWithDuration:0.3
                              delay:0.0
                            options: UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             
                             //Bring up the corresponding container view.
                             
                             containerView.transform = CGAffineTransformMakeTranslation(0.0, -containerView.frame.size.height);
                             
                         }
                         completion:^(BOOL finished){
                             
                         }
         
         ];
        
        self.isPickerActivated = YES;
    }
    
    //else, create and animation to hide it from screen.
    else
    {
        [UIView animateWithDuration:0.3
                              delay:0.0
                            options: UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             
                             //bring searchView up
                             containerView.transform = CGAffineTransformMakeTranslation(0.0, containerView.frame.size.height);
                             
                         }
                         completion:^(BOOL finished){
                             [containerView removeFromSuperview];
                         }
         
         ];
        
        self.isPickerActivated = NO;

    }
}

#pragma mark - UIScrollViewDelegate

-(void)scrollViewDidScroll:(UIScrollView *)sender {
    
    self.offset = self.tableView.contentOffset.y;
    self.offset *= -1;
    if (self.offset > 0 && self.offset < 60) {
        /*if(!self.isUpdating)
         self.updateLabel.text = @"Hala para actualizar...";*/
        
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationBeginsFromCurrentState:YES];
        [UIView setAnimationDuration:0.2];
        self.updateImageView.transform = CGAffineTransformMakeRotation(0);
        [UIView commitAnimations];
        self.shouldUpdate = NO;
    }
    if (self.offset >= 60) {
        /*if(!self.isUpdating)
         self.updateLabel.text = @"Suelta para actualizar...";*/
        
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationBeginsFromCurrentState:YES];
        [UIView setAnimationDuration:0.2];
        self.updateImageView.transform = CGAffineTransformMakeRotation(M_PI);
        [UIView commitAnimations];
        self.shouldUpdate = YES;
    }
    if (self.isUpdating)
    {
        self.shouldUpdate = NO;
    }
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
{
    if (self.shouldUpdate)
    {
        [self updateMethod];
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.2];
        self.tableView.contentInset = UIEdgeInsetsMake(60, 0, 0, 0);
        [UIView commitAnimations];
    }
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

#pragma mark - Pull Down To Refresh methods

- (void) updateMethod
{
    self.spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.spinner.center = self.updateImageView.center;
    self.updateImageView.hidden = YES;
    [self.spinner startAnimating];
    [self.tableView addSubview:self.spinner];
    //self.updateLabel.text = @"Actualizando...";
    self.isUpdating = YES;
    
    AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    [appDelegate incrementNetworkActivity];
    
    [self getAllInfoFromServer];
}

-(void) finishUpdateMethod
{
    [self stopSpinner];
    [self.tableView reloadData];
    //[self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationBottom];
}

- (void) stopSpinner
{
    [self.spinner stopAnimating];
    [self.spinner removeFromSuperview];
    self.updateImageView.hidden = NO;
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.2];
    self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
    [UIView commitAnimations];
    self.isUpdating = NO;
}

-(void)updateDataFromServer
{
    NSArray *tempArray = [self getDictionaryWithName:@"master"][self.objectType];
    NSMutableArray *tempMutableArray = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < [tempArray count]; i++)
    {
        if ([tempArray[i][@"menu_item_id"] isEqualToString:self.menuID])
            [tempMutableArray addObject:tempArray[i]];
    }
    
    self.menuItemsArray = tempMutableArray;
}

#pragma mark - Server

-(void)getAllInfoFromServer
{
    ServerCommunicator *server = [[ServerCommunicator alloc]init];
    server.delegate = self;
    [server callServerWithGETMethod:@"GetAllInfoWithAppID" andParameter:[[self getDictionaryWithName:@"app_id"] objectForKey:@"app_id"]];
    /*//Load the info from the server asynchronously
    dispatch_queue_t infoLoader = dispatch_queue_create("InfoLoader", nil);
    dispatch_async(infoLoader, ^(){
    });*/
}

-(void)receivedDataFromServer:(NSDictionary *)dictionary withMethodName:(NSString *)methodName
{
    AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    [appDelegate decrementNetworkActivity];
    [MBHUDView dismissCurrentHUD];
    
    if ([methodName isEqualToString:@"FavItem"] || [methodName isEqualToString:@"UnFavItem"])
    {
        if ([dictionary[@"status"] boolValue])
        {
            NSLog(@"%@", dictionary);
            NSLog(@"Llego la informacion de los favoritos");
            [self setDictionary:dictionary[@"user"] withName:@"user"];
            
            if ([methodName isEqualToString:@"UnFavItem"])
                self.isFavoritedArray[self.favoriteIndex] = @0;
            else
                self.isFavoritedArray[self.favoriteIndex] = @1;
            
            [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:self.rowIndex inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
            [self.isFavoritedArray[self.favoriteIndex] intValue] ==  1 ? [self showFavoriteAnimationWithImage:nil] : [self showFavoriteAnimationWithImage:[UIImage imageNamed:@"BorrarRojo.png"]];
            NSLog(@"se pudo favoritear correctamente desde el listado");
        }
    }
    
    else if ([methodName isEqualToString:@"GetAllInfoWithAppID"])
    {
        NSLog(@"llego información del servidor");
        if ([dictionary objectForKey:@"app"])
        {
            [self setDictionary:dictionary withName:@"master"];
            [self updateDataFromServer];
            [self finishUpdateMethod];
            NSLog(@"Me actualizé");
        }
            
        else
        {
            //no puede pasar
        }
    }
}

-(void)serverError:(NSError *)error
{
    AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    [appDelegate decrementNetworkActivity];
    [self stopSpinner];
    
    [[[UIAlertView alloc] initWithTitle:nil
                               message:@"No hay conexión a internet"
                              delegate:self
                     cancelButtonTitle:@"Ok"
                     otherButtonTitles:nil] show];
}

-(NSDictionary*)getDictionaryWithName:(NSString*)name{
    FileSaver *file=[[FileSaver alloc]init];
    return [file getDictionary:name];
}
-(void)setDictionary:(NSDictionary*)dictionary withName:(NSString*)name{
    FileSaver *file=[[FileSaver alloc]init];
    [file setDictionary:dictionary withKey:name];
}

@end
