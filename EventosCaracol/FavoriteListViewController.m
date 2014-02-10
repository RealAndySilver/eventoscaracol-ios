//
//  FavoriteListViewController.m
//  EventosCaracol
//
//  Created by Developer on 9/12/13.
//  Copyright (c) 2013 iAmStudio. All rights reserved.
//

#import "FavoriteListViewController.h"
#import "SWRevealViewController.h"

@interface FavoriteListViewController ()
@property (strong, nonatomic) NSMutableArray *favoritedItems;
@property (strong, nonatomic) UITableView *tableView;
@property (nonatomic) NSUInteger rowIndex;
@property (nonatomic) BOOL serverInfoReceived;
@property (strong, nonatomic) NSString *itemLocation;
@property (strong, nonatomic) NSString *itemDate;
@property (strong, nonatomic) UIView *blockTouchesView;
@property (strong, nonatomic) UIButton *sideBarButton;
@end

@implementation FavoriteListViewController

#pragma mark - View lifecycle

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:29.0/255.0 green:80.0/255.0 blue:204.0/255.0 alpha:1.0];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor whiteColor]};
    
    //////////////////////////////////////////////////////
    //Create the back button of the NavigationBar. When pressed, this button
    //display the slide menu.
    self.sideBarButton = [[UIButton alloc] initWithFrame:CGRectMake(5.0, 5.0, 34.0, 34.0)];
    [self.sideBarButton addTarget:self action:@selector(showSideBarMenu:) forControlEvents:UIControlEventTouchUpInside];
    [self.sideBarButton setBackgroundImage:[UIImage imageNamed:@"SidebarIcon.png"] forState:UIControlStateNormal];
    [self.navigationController.navigationBar addSubview:self.sideBarButton];
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.sideBarButton removeFromSuperview];
}

-(void)viewDidLoad
{
    [super viewDidLoad];
    self.revealViewController.delegate = self;
    [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    self.blockTouchesView = [[UIView alloc] initWithFrame:self.view.frame];
    //Add ourselfs as an observer for 'serverUpdateNeeded' notification.
    //Whent this notification is received, it means we have to update the favorite
    //items info from the server.
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(serverUpdateNotificationReceived:)
                                                 name:@"serverUpdateNeededNotification"
                                               object:nil];
    
    SWRevealViewController *revealViewController = [self revealViewController];
    /*UIBarButtonItem *slideMenuBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"SidebarIcon.png"]
                                                                               style:UIBarButtonItemStylePlain
                                                                              target:revealViewController
                                                                              action:@selector(revealToggle:)];
    self.navigationItem.leftBarButtonItem = slideMenuBarButtonItem;*/
    self.navigationItem.title = @"Favoritos";
    
    //////////////////////////////////////////////////////////////////////
    //Create a UITableView to display the favorited items
    self.tableView = [[UITableView alloc] initWithFrame:self.view.frame
                                                          style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
        self.tableView.rowHeight = 95.0;
    else
        self.tableView.rowHeight = 170.0;
    
    self.tableView.contentInset = UIEdgeInsetsMake(self.navigationController.navigationBar.frame.origin.y + self.navigationController.navigationBar.frame.size.height, 0.0, 0.0, 0.0);
    [self.view addSubview:self.tableView];
    
    //Show a HUD indicating that some network activity is going on. dismiss this
    //network activity when we get response from the server.
    [MBHUDView hudWithBody:nil type:MBAlertViewHUDTypeActivityIndicator hidesAfter:1000 show:YES];
    
    //Get info from the server
    [self getFavoritesInfoFromServer];
}

#pragma mark - UITableViewDelegate & UITableViewDataSource

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ([self.favoritedItems count] > 0)
        return [self.favoritedItems count];
    else
        return 1;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.favoritedItems count] > 0)
    {
        SWTableViewCell *cell = (SWTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"FavoriteCell"];
        
        NSMutableArray *rightButton = [[NSMutableArray alloc] init];
        
        UIImage *eraseImage;
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
            eraseImage = [UIImage imageNamed:@"SwipeCellErase.png"];
        else
            eraseImage = [UIImage imageNamed:@"SwipeCellEraseiPad.png"];
        
        [rightButton sw_addUtilityButtonWithColor:[UIColor redColor] icon:eraseImage];
        
        cell = [[SWTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:@"FavoriteCell"
                                  containingTableView:tableView
                                   leftUtilityButtons:nil
                                  rightUtilityButtons:rightButton];
        cell.delegate = self;
        
        /////////////////////////////////////////////////////////////////////
        //Create the subviews that will contain the cell.
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(10.0, 10.0, self.view.frame.size.width/3.2, tableView.rowHeight - 20.0)];
        imageView.clipsToBounds = YES;
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        imageView.backgroundColor = [UIColor clearColor];
        
        //Set the cell's thumb image using the SDWebImage Method -setImageWithURL: (This method saves the image in cache).
        [imageView setImageWithURL:self.favoritedItems[indexPath.row][@"thumb_url"] placeholderImage:[UIImage imageNamed:@"CaracolPrueba4.png"]];
        
        [cell.contentView addSubview:imageView];
        
        UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(imageView.frame.origin.x + imageView.frame.size.width + 10,
                                                                       0.0,
                                                                       self.view.frame.size.width - (imageView.frame.origin.x + imageView.frame.size.width + 10),
                                                                       40.0)];
        nameLabel.textAlignment = NSTextAlignmentLeft;
        nameLabel.numberOfLines = 2;
        nameLabel.text = self.favoritedItems[indexPath.row][@"name"];
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
            nameLabel.font = [UIFont fontWithName:@"Montserrat-Regular" size:15.0];
        else if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
            nameLabel.font = [UIFont fontWithName:@"Montserrat-Regular" size:30.0];
        [cell.contentView addSubview:nameLabel];
        
        ////////////////////////////////////////////////////////////////////
        //Item location label
        UILabel *descriptionLabel;
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
            descriptionLabel = [[UILabel alloc] initWithFrame:CGRectMake(nameLabel.frame.origin.x,
                                                                         40.0,
                                                                         self.view.frame.size.width - nameLabel.frame.origin.x,
                                                                         20.0)];
            descriptionLabel.font = [UIFont fontWithName:@"Montserrat-Regular" size:12.0];
        } else if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            descriptionLabel = [[UILabel alloc] initWithFrame:CGRectMake(nameLabel.frame.origin.x,
                                                                         40.0,
                                                                         self.view.frame.size.width - nameLabel.frame.origin.x,
                                                                         40.0)];
            descriptionLabel.font = [UIFont fontWithName:@"Montserrat-Regular" size:24.0];
            
        }
        self.itemLocation = [self getItemLocation:self.favoritedItems[indexPath.row]];
        descriptionLabel.text = [NSString stringWithFormat:@"📍%@", self.itemLocation];
        descriptionLabel.textColor = [UIColor lightGrayColor];
        [cell.contentView addSubview:descriptionLabel];
        
        ////////////////////////////////////////////////////////////////////
        //item date label
        if (![self.favoritedItems[indexPath.row][@"type"] isEqualToString:@"locaciones"])
        {
            UILabel *eventTimeLabel;
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
                eventTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(descriptionLabel.frame.origin.x,
                                                                           descriptionLabel.frame.origin.y + descriptionLabel.frame.size.height - 5, self.view.frame.size.width - descriptionLabel.frame.origin.x - 10.0,
                                                                           40.0)];
                eventTimeLabel.font = [UIFont fontWithName:@"Montserrat-Regular" size:12.0];
            } else if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
                eventTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(descriptionLabel.frame.origin.x,
                                                                           descriptionLabel.frame.origin.y + descriptionLabel.frame.size.height - 5, self.view.frame.size.width - descriptionLabel.frame.origin.x - 10.0,
                                                                           40.0)];
                eventTimeLabel.font = [UIFont fontWithName:@"Montserrat-Regular" size:24.0];
            }
            eventTimeLabel.numberOfLines = 0;
            
            if ([self.favoritedItems[indexPath.row][@"type"] isEqualToString:@"eventos"])
            {
                self.itemDate = [self getFormattedItemDate:self.favoritedItems[indexPath.row]];
                eventTimeLabel.text = [NSString stringWithFormat:@"🕑 %@", self.itemDate];
            }
            else
            {
                eventTimeLabel.text = [NSString stringWithFormat:@"📝 %@", self.favoritedItems[indexPath.row][@"short_detail"]];
            }
            
            eventTimeLabel.textColor = [UIColor lightGrayColor];
            [cell.contentView addSubview:eventTimeLabel];
        }
        
        return cell;
    }
    
    else
    {
        UITableViewCell *noFavoritesCell = [tableView dequeueReusableCellWithIdentifier:@"noFavoritesCell"];
        noFavoritesCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"noFavoritesCell"];
        
        //If we have already received a response from the server but there are no favorite
        //items, show a message to the user.
        if (self.serverInfoReceived) {
            UILabel *noFavoritesLabel;
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
                noFavoritesLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.view.frame.size.width/2 - 100.0,
                                                                             noFavoritesCell.frame.size.height/2 + 7,
                                                                             200,
                                                                             40)];
                noFavoritesLabel.font = [UIFont fontWithName:@"Montserrat-Regular" size:15.0];
            }
          
            else {
                noFavoritesLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.view.frame.size.width/2 - 200.0,
                                                                             50.0,
                                                                             400.0,
                                                                             80.0)];
                noFavoritesLabel.font = [UIFont fontWithName:@"Montserrat-Regular" size:30.0];
            }
            noFavoritesLabel.text = @"NO TIENES FAVORITOS";
            noFavoritesLabel.textColor = [UIColor lightGrayColor];
            noFavoritesLabel.textAlignment = NSTextAlignmentCenter;
            [noFavoritesCell.contentView addSubview:noFavoritesLabel];
        }
        
        noFavoritesCell.userInteractionEnabled = NO;
        return noFavoritesCell;
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //If the item has an external url, we have to check if the url is going to open inside or
    //outside the application.
    if (self.favoritedItems[indexPath.row][@"external_url"])
    {
        if ([self.favoritedItems[indexPath.row][@"open_inside"] isEqualToString:@"no"])
        {
            DetailsViewController *detailsVC = [self.storyboard instantiateViewControllerWithIdentifier:@"EventDetails"];
            detailsVC.objectInfo = self.favoritedItems[indexPath.row];
            detailsVC.objectLocation = [self getItemLocation:self.favoritedItems[indexPath.row]];
            
            if ([self.favoritedItems[indexPath.row][@"type"] isEqualToString:@"eventos"])
                detailsVC.objectTime = [self getFormattedItemDate:self.favoritedItems[indexPath.row]];
            else
                detailsVC.objectTime = self.favoritedItems[indexPath.row][@"short_detail"];
            
            detailsVC.navigationBarTitle = self.favoritedItems[indexPath.row][@"name"];
            
            if ([self.favoritedItems[indexPath.row][@"type"] isEqualToString:@"locaciones"])
                detailsVC.presentLocationObject = YES;
            
            [self.navigationController pushViewController:detailsVC animated:YES];
        }
        
        else if ([self.favoritedItems[indexPath.row][@"open_inside"] isEqualToString:@"outside"])
        {
            NSURL *url = [NSURL URLWithString:self.favoritedItems[indexPath.row][@"external_url"]];
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
            webViewController.urlString = self.favoritedItems[indexPath.row][@"external_url"];
            [self.navigationController pushViewController:webViewController animated:YES];
        }
    }
    
    //if the item doesn't have an external url, open the detail view.
    else
    {
        DetailsViewController *detailsVC = [self.storyboard instantiateViewControllerWithIdentifier:@"EventDetails"];
        detailsVC.objectInfo = self.favoritedItems[indexPath.row];
        
        if ([self.favoritedItems[indexPath.row][@"type"] isEqualToString:@"eventos"])
            detailsVC.objectTime = [self getFormattedItemDate:self.favoritedItems[indexPath.row]];
        else
            detailsVC.objectTime = self.favoritedItems[indexPath.row][@"short_detail"];

        detailsVC.objectLocation = [self getItemLocation:self.favoritedItems[indexPath.row]];
        detailsVC.navigationBarTitle = self.favoritedItems[indexPath.row][@"name"];
        
        if ([self.favoritedItems[indexPath.row][@"type"] isEqualToString:@"locaciones"])
            detailsVC.presentLocationObject = YES;
        
        [self.navigationController pushViewController:detailsVC animated:YES];
    }
}

#pragma mark - SWRevealViewControllerDelegate

-(void)revealController:(SWRevealViewController *)revealController didMoveToPosition:(FrontViewPosition)position
{
    if (position == FrontViewPositionLeft) {
        NSLog(@"Cerré el menú");
        [self.blockTouchesView removeFromSuperview];
    }
    else if (position == FrontViewPositionRight) {
        NSLog(@"Abrí el menú");
        [self.view addSubview:self.blockTouchesView];
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

#pragma mark - Custom Methods

-(void)showSideBarMenu:(id)sender {
    [self.revealViewController revealToggle:sender];
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

#pragma mark - Notification handlers

-(void)serverUpdateNotificationReceived:(NSNotification *)notification
{
    [self getFavoritesInfoFromServer];
}

#pragma mark - Server Communication

-(void)getFavoritesInfoFromServer
{
    int random = rand()%1000;
    ServerCommunicator *serverCommunicator = [[ServerCommunicator alloc] init];
    serverCommunicator.delegate = self;
    NSString *parameters = [NSString stringWithFormat:@"%@/%@/%d", [self getDictionaryWithName:@"master"][@"app"][@"_id"],
                            [self getDictionaryWithName:@"user"][@"_id"], random];
    [serverCommunicator callServerWithGETMethod:@"GetFavoritedItemsFromUser" andParameter:parameters];
}

-(void)receivedDataFromServer:(NSDictionary *)dictionary withMethodName:(NSString *)methodName
{
    self.serverInfoReceived = YES;
    [MBHUDView dismissCurrentHUD];
    if ([methodName isEqualToString:@"GetFavoritedItemsFromUser"])
    {
        if ([dictionary[@"status"] boolValue])
        {
            NSLog(@"Recibi el diccionario de favoritos");
            NSLog(@"%@", dictionary);
            [self setDictionary:dictionary[@"user"] withName:@"user"];
            self.favoritedItems = [[NSMutableArray alloc] init];
            [self.favoritedItems addObjectsFromArray:dictionary[@"favorited_atoms"]];
            [self.favoritedItems addObjectsFromArray:dictionary[@"favorited_locations"]];
            [self.tableView reloadData];
        }
        
        else
        {
            [[[UIAlertView alloc] initWithTitle:nil
                                       message:@"¡Oops!, debes iniciar sesión con Facebook para poder visualizar tus favoritos"
                                      delegate:self
                             cancelButtonTitle:@"Ok"
                             otherButtonTitles:@"Iniciar Sesión", nil] show];
        }
    }
    
    else if ([methodName isEqualToString:@"UnFavItem"])
    {
        if ([dictionary[@"status"] boolValue])
        {
            NSLog(@"Se pudo borrar el item");
            [self setDictionary:dictionary[@"user"] withName:@"user"];
            [self.favoritedItems removeAllObjects];
            [self.favoritedItems addObjectsFromArray:dictionary[@"favorited_atoms"]];
            [self.favoritedItems addObjectsFromArray:dictionary[@"favorited_locations"]];
            [self.tableView reloadData];
            [PopUpView showPopUpViewOverView:self.view image:[UIImage imageNamed:@"BorrarRojo.png"]];
        }
        
        else
        {
            [[[UIAlertView alloc]initWithTitle:nil
                                      message:@"Hubo un error intentando eliminar tu favorito. Por favor intenta de nuevo. "
                                     delegate:self
                            cancelButtonTitle:@"Ok"
                             otherButtonTitles:nil] show];
        }
        NSLog(@"%@", dictionary);
    }
}

-(void)serverError:(NSError *)error
{
    [MBHUDView dismissCurrentHUD];
    [[[UIAlertView alloc] initWithTitle:nil
                               message:@"No hay conexión a internet. Revisa que tu dispositivo esté conectado a internet."
                              delegate:self
                     cancelButtonTitle:@"Ok"
                     otherButtonTitles:nil] show];
    NSLog(@"error en el server");
}

#pragma mark - FileSaver Stuff

-(NSDictionary*)getDictionaryWithName:(NSString*)name{
    FileSaver *file=[[FileSaver alloc]init];
    return [file getDictionary:name];
}
-(void)setDictionary:(NSDictionary*)dictionary withName:(NSString*)name{
    FileSaver *file=[[FileSaver alloc]init];
    [file setDictionary:dictionary withKey:name];
}

#pragma mark - SWTableViewCellDelegate

-(void)swippableTableViewCell:(SWTableViewCell *)cell didTriggerRightUtilityButtonWithIndex:(NSInteger)index
{
    NSUInteger cellIndex = [self.tableView indexPathForCell:cell].row;
    [MBHUDView hudWithBody:nil type:MBAlertViewHUDTypeActivityIndicator hidesAfter:1000 show:YES];
    [self removeLocalNotificationForItemAtIndex:cellIndex];
    [self unFavItemAtIndex:cellIndex];
}

-(void)swippableTableViewCell:(SWTableViewCell *)cell scrollingToState:(SWCellState)state
{
    NSLog(@"scroooolliiiing");
    static int activeCell = 0;
    if (state == kCellStateRight)
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

#pragma mark - Custom Methods

-(void)removeLocalNotificationForItemAtIndex:(NSUInteger)index
{
    NSArray *localNotifications = [[UIApplication sharedApplication] scheduledLocalNotifications];
    for (int i=0; i<[localNotifications count]; i++)
    {
        UILocalNotification *notification = localNotifications[i];
        NSDictionary *notificationUserInfo = notification.userInfo;
        NSString *notificationName = [NSString stringWithFormat:@"%@", notificationUserInfo[@"name"]];
        if ([notificationName isEqualToString:self.favoritedItems[index][@"_id"]])
        {
            //Cancelling local notification
            [[UIApplication sharedApplication] cancelLocalNotification:notification];
            NSLog(@"encontré la notificación a eliminar, con el id %@",notificationName);
            break;
        }
    }
}

-(void)unFavItemAtIndex:(NSUInteger)index
{
    
    self.rowIndex = index;
    
    //Create a string that contains the parameters to send to the server.
    NSString *params = [NSString stringWithFormat:@"item_id=%@&user_id=%@&type=%@&app_id=%@", self.favoritedItems[index][@"_id"], [self getDictionaryWithName:@"user"][@"_id"], self.favoritedItems[index][@"type"], [self getDictionaryWithName:@"master"][@"app"][@"_id"]];
    ServerCommunicator *serverCommunicator = [[ServerCommunicator alloc] init];
    serverCommunicator.delegate = self;
    [serverCommunicator callServerWithPOSTMethod:@"UnFavItem" andParameter:params httpMethod:@"POST"];
    //Communicate asynchronously with the server
    /*dispatch_queue_t server = dispatch_queue_create("server", nil);
    dispatch_async(server, ^(){
            [serverCommunicator callServerWithPOSTMethod:@"UnFavItem" andParameter:params httpMethod:@"POST"];
    });*/
}

@end
