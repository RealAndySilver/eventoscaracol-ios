//
//  SidebarViewController.m
//  EventosCaracol
//
//  Created by Developer on 25/11/13.
//  Copyright (c) 2013 iAmStudio. All rights reserved.
//

#import "SidebarViewController.h"

@interface SidebarViewController () 
@property (strong, nonatomic) NSArray *menuItems;
@property (strong, nonatomic) NSArray *menuArray; //Of NSDictionary
@property (strong, nonatomic) NSArray *aditionalMenuItemsArray;
@property (strong, nonatomic) NSArray *searchResults;
@property (strong, nonatomic) NSMutableArray *allObjectsTypeArray;
@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) UILabel *updateLabel;
@property (strong, nonatomic) UIImageView *updateImageView;
@property (strong, nonatomic) UIActivityIndicatorView *spinner;
@property (nonatomic) BOOL isUpdating;
@property (nonatomic) BOOL shouldUpdate;
@property (nonatomic) float offset;
@end

@implementation SidebarViewController

#pragma mark - View lifecycle

-(void)setupPullDownToRefreshView
{
    self.updateImageView = [[UIImageView alloc] initWithFrame:CGRectMake(self.view.frame.size.width/2 - 40.0, -50.0, 20.0, 40.0)];
    self.updateImageView.image = [UIImage imageNamed:@"updateArrow.png"];
    //[self.tableView addSubview:self.updateLabel];
    [self.tableView addSubview:self.updateImageView];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

-(void)viewDidLoad
{
    NSLog(@"me cargué");
    [super viewDidLoad];
    
    [self updateDataFromServer];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(FacebookLoginNotificationReceived:)
                                                 name:@"FacebookLogin"
                                               object:nil];
    
   /* //Store the info for the aditional buttons of the slide menu table view
    if ([self getDictionaryWithName:@"user"][@"_id"])
    {
        BOOL isFacebookTagActive = [[self getDictionaryWithName:@"master"][@"app"][@"facebook_tag_is_active"] boolValue];
        BOOL isInstagramActive = [[self getDictionaryWithName:@"master"][@"app"][@"instagram_tag_is_active"] boolValue];
        BOOL isTwitterTagActive = [[self getDictionaryWithName:@"master"][@"app"][@"twitter_tag_is_active"] boolValue];
        
        if (isFacebookTagActive || isInstagramActive || isTwitterTagActive)
        {
            self.aditionalMenuItemsArray = @[@"Cerrar Sesión", @"Tutorial", @"Actividad en Redes"];
        }
        else
            self.aditionalMenuItemsArray = @[@"Cerrar Sesión", @"Tutorial"];
    }
    else
        self.aditionalMenuItemsArray = @[@"Iniciar Sesión", @"Tutorial"];*/

    
    ///////////////////////////////////////////////////////////////
    //Create the image view
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0,
                                                                           0.0,
                                                                           self.view.frame.size.width,
                                                                           self.view.frame.size.height)];
    imageView.userInteractionEnabled = YES;
    imageView.backgroundColor = [UIColor grayColor];
    imageView.clipsToBounds = YES;
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    imageView.image = [UIImage imageNamed:@"FondoMenu.png"];
  
    [self.view addSubview:imageView];
    [self.view bringSubviewToFront:self.searchDisplayController.searchBar];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapOnLogoImageView)];
    tap.numberOfTapsRequired = 1;
    [imageView addGestureRecognizer:tap];
    
    ///////////////////////////////////////////////////////////////////////////////
    //Add a tableview to our view.
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0,
                                                                           self.searchDisplayController.searchBar.frame.origin.y + self.searchDisplayController.searchBar.frame.size.height,
                                                                           self.view.frame.size.width,
                                                                           self.view.frame.size.height - (self.searchDisplayController.searchBar.frame.origin.y + self.searchDisplayController.searchBar.frame.size.height))];
    
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.rowHeight = 50.0;
    self.tableView.delegate = self;
    self.tableView.dataSource =self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.tableView setAlwaysBounceVertical:YES];
    [self.tableView registerClass:[MenuTableViewCell class] forCellReuseIdentifier:@"menuItemCell"];
    [self.view addSubview:self.tableView];
    
    ////////////////////////////////////////////////////////////////////////////////
    //'Pull down to refresh' views
    [self setupPullDownToRefreshView];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    ////////////////////////////////////////////////////////////////////////////////
    //searchDisplayController configuration.
    [[UISearchBar appearance] setSearchFieldBackgroundImage:[UIImage imageNamed:@"BarraBusqueda.png"] forState:UIControlStateNormal];
    [[UITextField appearanceWhenContainedIn:[UISearchBar class], nil] setTextColor:[UIColor whiteColor]];
    [[UISearchBar appearance] setTintColor:[UIColor whiteColor]];
    self.searchDisplayController.searchResultsTableView.backgroundColor = [UIColor colorWithRed:13.0/255.0 green:36.0/255.0 blue:102.0/255.0 alpha:1.0];
    [self.searchDisplayController.searchResultsTableView registerClass:[MenuTableViewCell class] forCellReuseIdentifier:@"menuItemCell"];
    self.searchDisplayController.searchResultsTableView.rowHeight = 50.0;
    self.searchDisplayController.searchResultsTableView.frame = CGRectMake(0.0,
                                                                           self.searchDisplayController.searchBar.frame.origin.y + self.searchDisplayController.searchBar.frame.size.height,
                                                                           self.view.frame.size.width,
                                                                           self.view.frame.size.height - (self.searchDisplayController.searchBar.frame.origin.y + self.searchDisplayController.searchBar.frame.size.height));
    
    self.searchDisplayController.searchResultsTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
}

-(void)tapOnLogoImageView
{
    SWRevealViewController *revelViewController = [self revealViewController];
    
    DestacadosViewController *destacadosVC = [self.storyboard instantiateViewControllerWithIdentifier:@"Destacados"];
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:destacadosVC];
    [revelViewController setFrontViewController:navigationController animated:YES];
    
    NSLog(@"me tapee");
}

#pragma mark - UITableViewDataSource

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == self.searchDisplayController.searchResultsTableView)
    {
        return [self.searchResults count];
    }
    
    else
        return ([self.menuArray count] + [self.aditionalMenuItemsArray count]);
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MenuTableViewCell *cell = (MenuTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"menuItemCell"
                                                            forIndexPath:indexPath];
    
    //If the user has tap the search bar
    if (tableView == self.searchDisplayController.searchResultsTableView)
    {
        cell.menuItemLabel.text = self.searchResults[indexPath.row][@"name"];
        [cell.menuItemImageView setImageWithURL:self.searchResults[indexPath.row][@"thumb_url"]
                               placeholderImage:[UIImage imageNamed:@"CaracolPrueba3.png"]];
    }
    
    else
    {
        if (indexPath.row < [self.menuArray count])
        {
            /*AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
            [appDelegate incrementNetworkActivity];*/
            
            cell.menuItemLabel.text = self.menuArray[indexPath.row][@"name"];
            if (![self.menuArray[indexPath.row][@"type"] isEqualToString:@"general"])
                [cell.menuItemImageView setImageWithURL:self.menuArray[indexPath.row][@"icon_url"]
                                       placeholderImage:[UIImage imageNamed:@"CaracolPrueba3.png"]];
            else
                cell.menuItemImageView.image = nil;
        }
        
        else
        {
            cell.menuItemLabel.text = self.aditionalMenuItemsArray[indexPath.row-[self.menuArray count]];
            
            BOOL isFacebookTagActive = [[self getDictionaryWithName:@"master"][@"app"][@"facebook_tag_is_active"] boolValue];
            BOOL isInstagramActive = [[self getDictionaryWithName:@"master"][@"app"][@"instagram_tag_is_active"] boolValue];
            BOOL isTwitterTagActive = [[self getDictionaryWithName:@"master"][@"app"][@"twitter_tag_is_active"] boolValue];

            if (isFacebookTagActive || isInstagramActive || isTwitterTagActive) {
                if (indexPath.row - [self.menuArray count] == 3)
                    cell.menuItemImageView.image = [UIImage imageNamed:@"Facebook.png"];
                else
                    cell.menuItemImageView.image = nil;
            } else {
                if (indexPath.row - [self.menuArray count] == 2)
                    cell.menuItemImageView.image = [UIImage imageNamed:@"Facebook.png"];
                else
                    cell.menuItemImageView.image = nil;
            }
            
        }
    }
    return cell;
}

#pragma mark - UITableViewDelegate
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    //If the selected table view was the search bar table view
    if (tableView == self.searchDisplayController.searchResultsTableView)
    {
        if ([self.searchResults[indexPath.row][@"type"] isEqualToString:@"locaciones"])
        {
            DetailsViewController *detailsVC = [self.storyboard instantiateViewControllerWithIdentifier:@"EventDetails"];
            detailsVC.navigationBarTitle = self.searchResults[indexPath.row][@"name"];
            detailsVC.objectInfo = self.searchResults[indexPath.row];
            detailsVC.objectLocation = [self getItemLocation:self.searchResults[indexPath.row]];
            detailsVC.objectTime = [self getFormattedItemDate:self.searchResults[indexPath.row]];
            detailsVC.presentViewControllerFromSearchBar = YES;
            detailsVC.presentLocationObject = YES;
            UINavigationController                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           *navigationController = [[UINavigationController alloc] initWithRootViewController:detailsVC];
            navigationController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
            [self presentViewController:navigationController animated:YES completion:nil];
        }
        
        else if ([self.searchResults[indexPath.row][@"type"] isEqualToString:@"general"])
        {
            GeneralInfoDetailViewController *generalInfoDetailsVC = [self.storyboard instantiateViewControllerWithIdentifier:@"GeneralInfoDetail"];
            generalInfoDetailsVC.mainTitle = self.searchResults[indexPath.row][@"name"];
            generalInfoDetailsVC.detailText = self.searchResults[indexPath.row][@"detail"];
            generalInfoDetailsVC.viewControllerWasPresentedFromASearch = YES;
            generalInfoDetailsVC.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
            UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:generalInfoDetailsVC];
            navigationController.navigationBar.barTintColor = [UIColor colorWithRed:29.0/255.0 green:80.0/255.0 blue:204.0/255.0 alpha:1.0];
            navigationController.navigationBar.tintColor = [UIColor whiteColor];
            [self presentViewController:navigationController animated:YES completion:nil];
        }
        
        else
        {
            DetailsViewController *detailsVC = [self.storyboard instantiateViewControllerWithIdentifier:@"EventDetails"];
            detailsVC.navigationBarTitle = self.searchResults[indexPath.row][@"name"];
            if ([self.searchResults[indexPath.row][@"type"] isEqualToString:@"eventos"])
                detailsVC.objectTime = [self getFormattedItemDate:self.searchResults[indexPath.row]];
            else
                detailsVC.objectTime = self.searchResults[indexPath.row][@"short_detail"];
            
            detailsVC.objectLocation = [self getItemLocation:self.searchResults[indexPath.row]];
            detailsVC.objectInfo = self.searchResults[indexPath.row];
            detailsVC.presentViewControllerFromSearchBar = YES;
            UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:detailsVC];
            navigationController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
            [self presentViewController:navigationController animated:YES completion:nil];
        }
    }
    
    //....If the selected table view was the menu table view
    else
    {
        SWRevealViewController *revealViewController = self.revealViewController;
        
        if (indexPath.row < [self.menuArray count])
        {
            if ([self.menuArray[indexPath.row][@"type"] isEqualToString:@"home"])
            {
                SWRevealViewController *revelViewController = [self revealViewController];
                
                DestacadosViewController *destacadosVC = [self.storyboard instantiateViewControllerWithIdentifier:@"Destacados"];
                UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:destacadosVC];
                [revelViewController setFrontViewController:navigationController animated:YES];
                
                NSLog(@"me tapee");
            }
            
            else if ([self.menuArray[indexPath.row][@"type"] isEqualToString:@"artistas"])
                //Present the list view passing the type of object that was selected and the row
                //that was selected
                [self presentListViewControllerWithObjectsOfType:@"artistas" selectedRow:indexPath.row];
            
            else if ([self.menuArray[indexPath.row][@"type"] isEqualToString:@"eventos"])
                [self presentListViewControllerWithObjectsOfType:@"eventos" selectedRow:indexPath.row];
            
            
            else if ([self.menuArray[indexPath.row][@"type"] isEqualToString:@"noticias"])
                [self presentListViewControllerWithObjectsOfType:@"noticias" selectedRow:indexPath.row];
            
            else if ([self.menuArray[indexPath.row][@"type"] isEqualToString:@"general"])
                [self presentListViewControllerWithObjectsOfType:@"general" selectedRow:indexPath.row];
            
            else if ([self.menuArray[indexPath.row][@"type"] isEqualToString:@"favoritos"])
            {
                if (![self getDictionaryWithName:@"user"][@"_id"])
                {
                    [[[UIAlertView alloc] initWithTitle:nil
                                                message:@"Ops! Debes iniciar sesión con Facebook para poder asignar favoritos."
                                               delegate:self
                                      cancelButtonTitle:@"Ok"
                                      otherButtonTitles:@"Iniciar Sesión", nil] show];
                    return;
                }
                
                FavoriteListViewController *favoriteListViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"FavoriteList"];
                UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:favoriteListViewController];
                [revealViewController setFrontViewController:navigationController animated:YES];
            }
            
            else if ([self.menuArray[indexPath.row][@"type"] isEqualToString:@"locaciones"])
            {
                MapViewController *mapVC = [self.storyboard instantiateViewControllerWithIdentifier:@"Map"];
                mapVC.navigationBarTitle = self.menuArray[indexPath.row][@"name"];
                
                NSArray *tempArray = [self getDictionaryWithName:@"master"][@"locaciones"];
                NSLog(@"Numero de locaciones: %d", [tempArray count]);
                NSMutableArray *tempMutableArray = [[NSMutableArray alloc] init];
                NSString *menuID = self.menuArray[indexPath.row][@"_id"];
                for (int i = 0; i < [tempArray count]; i++)
                {
                    //If yes, add the object to menuItemsArray
                    NSLog(@"%@", tempArray[i][@"name"]);
                    if ([tempArray[i][@"menu_item_id"] isEqualToString:menuID])
                        [tempMutableArray addObject:tempArray[i]];
                }
                mapVC.locationsArray = tempMutableArray;
                mapVC.menuID = menuID;
                mapVC.objectType = @"locaciones";
                UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:mapVC];
                [revealViewController setFrontViewController:navigationController animated:YES];
            }
        }
        
        else
        {
            BOOL isFacebookTagActive = [[self getDictionaryWithName:@"master"][@"app"][@"facebook_tag_is_active"] boolValue];
            BOOL isInstagramActive = [[self getDictionaryWithName:@"master"][@"app"][@"instagram_tag_is_active"] boolValue];
            BOOL isTwitterTagActive = [[self getDictionaryWithName:@"master"][@"app"][@"twitter_tag_is_active"] boolValue];
            
            //Menu Tutorial
            if (indexPath.row - [self.menuArray count] == 0)
            {
                TutorialViewController *tutorialVC = [self.storyboard instantiateViewControllerWithIdentifier:@"Tutorial"];
                [self presentViewController:tutorialVC animated:YES completion:nil];
            }
            
            //Menú Reportar un Problema
            else if (indexPath.row - [self.menuArray count] == 1)
            {
                //Check if the device can send emails
                if ([MFMailComposeViewController canSendMail])
                {
                    //Create a MFMailComposeViewController to open up the email window
                    MFMailComposeViewController *mailComposeVC = [[MFMailComposeViewController alloc] init];
                    mailComposeVC.mailComposeDelegate = self;
                    [mailComposeVC setSubject:@"Reporte de problema App 'EuroCine 2014'"];
                    [mailComposeVC setToRecipients:@[@"diefer_91@hotmail.com"]];
                    [self presentViewController:mailComposeVC animated:YES completion:nil];
                }
                
                //Notify the user that the device can't send emails
                else
                {
                    [[[UIAlertView alloc] initWithTitle:nil
                                                message:@"¡Oops!, tu dispositivo no está configurado para enviar emails."
                                               delegate:self
                                      cancelButtonTitle:@"Ok"
                                      otherButtonTitles:nil] show];
                }
            }
            
            //Menú Actividad en Redes
            else if (indexPath.row - [self.menuArray count] == 2 && (isTwitterTagActive || isFacebookTagActive || isInstagramActive))
            {
                UITabBarController *tabBarController = [[UITabBarController alloc] init];
                tabBarController.delegate = self;
                
                BOOL isFacebookTagActivated = [[self getDictionaryWithName:@"master"][@"app"][@"facebook_tag_is_active"] boolValue];
                BOOL isTwitterTagActivated = [[self getDictionaryWithName:@"master"][@"app"][@"twitter_tag_is_active"] boolValue];
                BOOL isInstagramTagActive = [[self getDictionaryWithName:@"master"][@"app"][@"instagram_tag_is_active"] boolValue];
                
                NSMutableArray *tabBarViewControllersArray = [self createTabBarViewControllersForFacebook:isFacebookTagActivated
                                                                                                  twitter:isTwitterTagActivated
                                                                                                instagram:isInstagramTagActive];
                
                [tabBarController setViewControllers:tabBarViewControllersArray];
                tabBarController.tabBar.barTintColor = [UIColor darkGrayColor];
                tabBarController.tabBar.tintColor = [UIColor whiteColor];
                tabBarController.selectedIndex = 0;
                [revealViewController setFrontViewController:tabBarController animated:YES];
            }
            
            //Menú Login
            else
            {
                if (![self getDictionaryWithName:@"user"][@"_id"])
                {
                    LoginViewController *loginVC = [self.storyboard instantiateViewControllerWithIdentifier:@"Login"];
                    loginVC.loginWasPresentedFromFavoriteButtonAlert = YES;
                    [self presentViewController:loginVC animated:YES completion:nil];
                }
                
                else
                {
                    [[[UIActionSheet alloc] initWithTitle:@"¿Estás seguro que deseas cerrar sesión?, ya no podrás acceder a tus favoritos."
                                                 delegate:self
                                        cancelButtonTitle:@"Cancelar"
                                   destructiveButtonTitle:@"Cerrar Sesión"
                                        otherButtonTitles:nil]showInView:self.view];
                }
            }
        }
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - Custom Methods

-(NSMutableArray *)createTabBarViewControllersForFacebook:(BOOL)facebook twitter:(BOOL)twitter instagram:(BOOL)instagram
{
    //This method create the view controllers for the social activity section.
    //depending on the boolean values passed as parameters.
    
    NSMutableArray *tabBarViewControllers = [[NSMutableArray alloc] init];
    
    if (facebook)
    {
        SocialActivityViewController *facebookVC = [self.storyboard instantiateViewControllerWithIdentifier:@"SocialActivity"];
        NSString *facebookURLString = [self getDictionaryWithName:@"master"][@"app"][@"facebook_url"];
        NSString *hashtag = [self getDictionaryWithName:@"master"][@"app"][@"facebook_tag"];
        facebookURLString = [facebookURLString stringByAppendingString:hashtag];
        facebookVC.hashtagURLString = facebookURLString;
        [facebookVC.tabBarItem initWithTitle:@"Facebook" image:[UIImage imageNamed:@"FacebookTabIcon.png"] tag:1];
        [tabBarViewControllers addObject:facebookVC];
    }
    
    if (twitter)
    {
        SocialActivityViewController *twitterVC = [self.storyboard instantiateViewControllerWithIdentifier:@"SocialActivity"];
        NSString *twitterURLString = [self getDictionaryWithName:@"master"][@"app"][@"twitter_url"];
        NSString *hashtag = [self getDictionaryWithName:@"master"][@"app"][@"twitter_tag"];
        twitterURLString = [twitterURLString stringByAppendingString:hashtag];
        twitterURLString = [twitterURLString stringByReplacingOccurrencesOfString:@"#" withString:@"%23"];
        twitterVC.hashtagURLString = twitterURLString;
        [twitterVC.tabBarItem initWithTitle:@"Twitter" image:[UIImage imageNamed:@"TwitterTabIcon.png"] tag:2];
        [tabBarViewControllers addObject:twitterVC];
    }
    
    if (instagram)
    {
        SocialActivityViewController *instagramVC = [self.storyboard instantiateViewControllerWithIdentifier:@"SocialActivity"];
        NSString *instagramURLString = [self getDictionaryWithName:@"master"][@"app"][@"instagram_url"];
        NSString *hasthtag = [self getDictionaryWithName:@"master"][@"app"][@"instagram_tag"];
        instagramURLString = [instagramURLString stringByAppendingString:hasthtag];
        instagramVC.hashtagURLString = instagramURLString;
        [instagramVC.tabBarItem initWithTitle:@"Instagram" image:[UIImage imageNamed:@"InstagramTabIcon.png"] tag:3];
        [tabBarViewControllers addObject:instagramVC];
    }
    
    return tabBarViewControllers;
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

-(void)facebookLogout
{
    //Erase the user info from the application
    NSDictionary *dic = [[NSDictionary alloc] init];
    [self setDictionary:dic withName:@"user"];
    
    BOOL isFacebookTagActivated = [[self getDictionaryWithName:@"master"][@"app"][@"facebook_tag_is_active"] boolValue];
    BOOL isTwitterTagActivated = [[self getDictionaryWithName:@"master"][@"app"][@"twitter_tag_is_active"] boolValue];
    BOOL isInstagramTagActive = [[self getDictionaryWithName:@"master"][@"app"][@"instagram_tag_is_active"] boolValue];
    
    if (isFacebookTagActivated || isTwitterTagActivated || isInstagramTagActive)
        self.aditionalMenuItemsArray = @[@"Tutorial", @"Reportar un Problema", @"Actividad en Redes", @"Iniciar Sesión"];
    else
        self.aditionalMenuItemsArray = @[@"Tutorial", @"Reportar un Problema", @"Iniciar Sesión"];
    
    [self.tableView reloadData];
    [MBHUDView hudWithBody:nil type:MBAlertViewHUDTypeCheckmark hidesAfter:5 show:YES];
    
    //Go to the main page
    SWRevealViewController *revelViewController = [self revealViewController];
    
    DestacadosViewController *destacadosVC = [self.storyboard instantiateViewControllerWithIdentifier:@"Destacados"];
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:destacadosVC];
    [revelViewController setFrontViewController:navigationController animated:YES];
}

-(void)FacebookLoginNotificationReceived:(NSNotification *)notification
{
    BOOL isFacebookTagActivated = [[self getDictionaryWithName:@"master"][@"app"][@"facebook_tag_is_active"] boolValue];
    BOOL isTwitterTagActivated = [[self getDictionaryWithName:@"master"][@"app"][@"twitter_tag_is_active"] boolValue];
    BOOL isInstagramTagActive = [[self getDictionaryWithName:@"master"][@"app"][@"instagram_tag_is_active"] boolValue];
    
    if (isFacebookTagActivated || isTwitterTagActivated || isInstagramTagActive)
        self.aditionalMenuItemsArray = @[@"Tutorial", @"Reportar un Problema", @"Actividad en Redes", @"Cerrar Sesión"];
    else
        self.aditionalMenuItemsArray = @[@"Tutorial", @"Reportar un Problema", @"Cerrar Sesión"];
    [self.tableView reloadData];
}

-(void)presentListViewControllerWithObjectsOfType:(NSString *)objectType selectedRow:(NSInteger)row
{
    SWRevealViewController *revealViewController = [self revealViewController];
    
    ListViewController *listVC = [self.storyboard instantiateViewControllerWithIdentifier:@"EventsList"];
    NSArray *tempArray = [self getDictionaryWithName:@"master"][objectType];
    NSMutableArray *tempMutableArray = [[NSMutableArray alloc] init];
    NSString *menuID = self.menuArray[row][@"_id"];
    for (int i = 0; i < [tempArray count]; i++)
    {
        //If yes, add the object to menuItemsArray
        if ([tempArray[i][@"menu_item_id"] isEqualToString:menuID])
            [tempMutableArray addObject:tempArray[i]];
    }
    listVC.menuItemsArray = tempMutableArray;
    
    //It's neccesary to pass the menuID string and the objectType (artist, event, news...) to ListViewController
    //Because when the user 'pull down to refresh' the list of objects we need to know what kind of objects
    //are we handling.
    listVC.menuID = menuID;
    listVC.objectType = objectType;
    
    if ([objectType isEqualToString:@"general"]) {
        NSLog(@"Estamos en un listado de tipo general");
        listVC.listWithGeneralTypeObjects = YES;
    }
    
    listVC.navigationBarTitle = self.menuArray[row][@"name"];
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:listVC];
    navigationController.navigationBar.translucent = YES;
    [revealViewController setFrontViewController:navigationController animated:YES];
}

#pragma mark - SearchBar

- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope
{
    NSPredicate *resultPredicate = [NSPredicate predicateWithFormat:@"(name contains[cd] %@)", searchText];
    self.searchResults = [self.allObjectsTypeArray filteredArrayUsingPredicate:resultPredicate];
}

#pragma mark - UISearchDisplayController delegate methods
-(BOOL)searchDisplayController:(UISearchDisplayController *)controller
shouldReloadTableForSearchString:(NSString *)searchString
{
    [self filterContentForSearchText:searchString
                               scope:[[self.searchDisplayController.searchBar scopeButtonTitles]
                                      objectAtIndex:[self.searchDisplayController.searchBar
                                                     selectedScopeButtonIndex]]];
    
    return YES;
}

#pragma mark - MFMailComposeViewControllerDelegate

-(void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    [self dismissViewControllerAnimated:YES completion:nil];
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
    if (self.isUpdating) {
        self.shouldUpdate = NO;
    }
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
    if (self.shouldUpdate) {
        //self.queue = [NSOperationQueue new];
        //NSInvocationOperation *updateOperation = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(updateMethod)  object:nil];
        //[self.queue addOperation:updateOperation];
        [self updateMethod];
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.2];
        self.tableView.contentInset = UIEdgeInsetsMake(60, 0, 0, 0);
        [UIView commitAnimations];
    }
}

#pragma mark - Pull Down To Refresh methods

- (void) updateMethod
{
    //[self performSelectorOnMainThread:@selector(startSpinner) withObject:nil waitUntilDone:NO];
    self.spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    self.spinner.center = self.updateImageView.center;
    self.updateImageView.hidden = YES;
    [self.spinner startAnimating];
    [self.tableView addSubview:self.spinner];
    //self.updateLabel.text = @"Actualizando...";
    self.isUpdating = YES;
    
    id appDelegate = [UIApplication sharedApplication].delegate;
    [appDelegate incrementNetworkActivity];
    
    [self getAllInfoFromServer];
}

-(void) finishUpdateMethod
{
    [self stopSpinner];
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
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

#pragma mark - Server

-(void)updateDataFromServer
{
    BOOL isFacebookTagActive = [[self getDictionaryWithName:@"master"][@"app"][@"facebook_tag_is_active"] boolValue];
    BOOL isInstagramActive = [[self getDictionaryWithName:@"master"][@"app"][@"instagram_tag_is_active"] boolValue];
    BOOL isTwitterTagActive = [[self getDictionaryWithName:@"master"][@"app"][@"twitter_tag_is_active"] boolValue];
    
    //Array that holds all the menu objects to display in the table view(like artists, news, locations, etc)
    //self.menuArray = [self.fileSaver getDictionary:@"master"][@"menu"];
    self.menuArray = [self getDictionaryWithName:@"master"][@"menu"];
    
    //Store the info for the aditional buttons of the slide menu table view
    if ([self getDictionaryWithName:@"user"][@"_id"])
    {
        if (isFacebookTagActive || isInstagramActive || isTwitterTagActive)
        {
            self.aditionalMenuItemsArray = @[@"Tutorial", @"Reportar un Problema",@"Actividad en Redes", @"Cerrar Sesión"];
            NSLog(@"Facebook esta abierto y hay actividad en redes");
        }
        else
        {
            self.aditionalMenuItemsArray = @[@"Tutorial", @"Reportar un Problema", @"Cerrar Sesión"];
            NSLog(@"Facebook está abierto y no hay actividad en redes");
        }
    }
    else if (isFacebookTagActive || isInstagramActive || isTwitterTagActive)
    {
        self.aditionalMenuItemsArray = @[@"Tutorial", @"Reportar un problema", @"Actividad en Redes", @"Iniciar Sesión"];
        NSLog(@"Facebook está cerrado y hay actividad en redes");
    }
    else
    {
        self.aditionalMenuItemsArray = @[@"Tutorial", @"Reportar un Problema", @"Iniciar Sesión"];
        NSLog(@"Facebook está cerrado y no hay actividad en redes");
    }

    
    //Array that holds of the objects of type artist, events, news and locations. we will use this array later when the
    //user make a search in the search bar. the results of that search will be filtered from this array.
    self.allObjectsTypeArray = [self getDictionaryWithName:@"master"][@"artistas"];
    [self.allObjectsTypeArray addObjectsFromArray:[self getDictionaryWithName:@"master"][@"noticias"]];
    [self.allObjectsTypeArray addObjectsFromArray:[self getDictionaryWithName:@"master"][@"eventos"]];
    [self.allObjectsTypeArray addObjectsFromArray:[self getDictionaryWithName:@"master"][@"locaciones"]];
    [self.allObjectsTypeArray addObjectsFromArray:[self getDictionaryWithName:@"master"][@"general"]];
}

-(void)getAllInfoFromServer
{
    ServerCommunicator *server = [[ServerCommunicator alloc]init];
    server.delegate = self;
    
    //Start animating the spinner.
    //[self.spinner startAnimating];
    //FileSaver *file=[[FileSaver alloc]init];
    
    int random = rand()%1000;
    NSString *parameters = [NSString stringWithFormat:@"%@/%d", [self getDictionaryWithName:@"app_id"][@"app_id"], random];
    //Load the info from the server asynchronously
    dispatch_queue_t infoLoader = dispatch_queue_create("InfoLoader", nil);
    dispatch_async(infoLoader, ^(){
        [server callServerWithGETMethod:@"GetAllInfoWithAppID" andParameter:parameters];
    });
}

-(void)receivedDataFromServer:(NSDictionary *)dictionary withMethodName:(NSString *)methodName
{
    id appDelegate = [UIApplication sharedApplication].delegate;
    [appDelegate decrementNetworkActivity];
    
    if ([methodName isEqualToString:@"GetAllInfoWithAppID"]) {
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
    id appDelegate = [UIApplication sharedApplication].delegate;
    [appDelegate decrementNetworkActivity];
    
    NSLog(@"error");
    [self stopSpinner];
    
    [[[UIAlertView alloc] initWithTitle:nil message:@"No hay conexión a internet."
                              delegate:self
                     cancelButtonTitle:@"Ok"
                     otherButtonTitles:nil] show];
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

#pragma mark - UIActionSheetDelegate

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0)
    {
        [self facebookLogout];
    }
}

@end
