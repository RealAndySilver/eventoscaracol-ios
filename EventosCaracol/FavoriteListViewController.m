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
@end

@implementation FavoriteListViewController

#pragma mark - View lifecycle

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:29.0/255.0 green:80.0/255.0 blue:204.0/255.0 alpha:1.0];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor whiteColor]};
}

-(void)viewDidLoad
{
    [super viewDidLoad];
    SWRevealViewController *revealViewController = [self revealViewController];
    UIBarButtonItem *slideMenuBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"SidebarIcon.png"]
                                                                               style:UIBarButtonItemStylePlain
                                                                              target:revealViewController
                                                                              action:@selector(revealToggle:)];
    self.navigationItem.leftBarButtonItem = slideMenuBarButtonItem;
    self.navigationItem.title = @"Favoritos";
    
    //////////////////////////////////////////////////////////////////////
    //Create a UITableView to display the favorited items
    self.tableView = [[UITableView alloc] initWithFrame:self.view.frame
                                                          style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.rowHeight = 95.0;
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
        [rightButton sw_addUtilityButtonWithColor:[UIColor redColor] icon:[UIImage imageNamed:@"SwipeCellErase.png"]];
        
        cell = [[SWTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:@"FavoriteCell"
                                  containingTableView:tableView
                                   leftUtilityButtons:nil
                                  rightUtilityButtons:rightButton];
        cell.delegate = self;
        
        /////////////////////////////////////////////////////////////////////
        //Create the subviews that will contain the cell.
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(10.0, 10.0, 100.0, 75.0)];
        imageView.clipsToBounds = YES;
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        imageView.backgroundColor = [UIColor clearColor];
        
        //Set the cell's thumb image using the SDWebImage Method -setImageWithURL: (This method saves the image in cache).
        [imageView setImageWithURL:self.favoritedItems[indexPath.row][@"thumb_url"] placeholderImage:[UIImage imageNamed:@"CaracolPrueba4.png"]];
        
        [cell.contentView addSubview:imageView];
        
        UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(imageView.frame.origin.x + imageView.frame.size.width + 10,
                                                                       0.0,
                                                                       self.view.frame.size.width - (imageView.frame.origin.x + imageView.frame.size.width + 10) - 20,
                                                                       40.0)];
        nameLabel.numberOfLines = 2;
        nameLabel.text = self.favoritedItems[indexPath.row][@"name"];
        nameLabel.font = [UIFont fontWithName:@"Montserrat-Regular" size:15.0];
        [cell.contentView addSubview:nameLabel];
        
        ////////////////////////////////////////////////////////////////////
        //Item location label
        UILabel *descriptionLabel = [[UILabel alloc] initWithFrame:CGRectMake(nameLabel.frame.origin.x,
                                                                              40.0,
                                                                              self.view.frame.size.width - nameLabel.frame.origin.x,
                                                                              20.0)];
        
        self.itemLocation = [self getItemLocation:self.favoritedItems[indexPath.row]];
        descriptionLabel.text = [NSString stringWithFormat:@"📍%@", self.itemLocation];
        descriptionLabel.font = [UIFont fontWithName:@"Montserrat-Regular" size:12.0];
        descriptionLabel.textColor = [UIColor lightGrayColor];
        [cell.contentView addSubview:descriptionLabel];
        
        ////////////////////////////////////////////////////////////////////
        //item date label
        UILabel *eventTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(descriptionLabel.frame.origin.x,
                                                                            descriptionLabel.frame.origin.y + descriptionLabel.frame.size.height, self.view.frame.size.width - descriptionLabel.frame.origin.x,
                                                                            20.0)];
        
        self.itemDate = [self getItemDate:self.favoritedItems[indexPath.row]];
        eventTimeLabel.text = [NSString stringWithFormat:@"🕑 %@", self.itemDate];
        eventTimeLabel.font = [UIFont fontWithName:@"Montserrat-Regular" size:12.0];
        eventTimeLabel.textColor = [UIColor lightGrayColor];
        [cell.contentView addSubview:eventTimeLabel];
        
        return cell;
    }
    
    else
    {
        UITableViewCell *noFavoritesCell = [tableView dequeueReusableCellWithIdentifier:@"noFavoritesCell"];
        noFavoritesCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"noFavoritesCell"];
        
        //If we have already received a response from the server but there are no favorite
        //items, show a message to the user.
        if (self.serverInfoReceived)
        {
            UILabel *noFavoritesLabel = [[UILabel alloc] initWithFrame:CGRectMake(noFavoritesCell.contentView.frame.size.width/2 - 100,
                                                                                  noFavoritesCell.contentView.frame.size.height/2,
                                                                                  200,
                                                                                  40)];
            
            noFavoritesLabel.text = @"NO TIENES FAVORITOS";
            noFavoritesLabel.font = [UIFont fontWithName:@"Helvetica" size:15.0];
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
            detailsVC.objectLocation = self.itemLocation;
            detailsVC.objectTime = self.itemDate;
            detailsVC.navigationBarTitle = self.favoritedItems[indexPath.row][@"name"];
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
        detailsVC.objectTime = self.itemDate;
        detailsVC.objectLocation = self.itemLocation;
        detailsVC.navigationBarTitle = self.favoritedItems[indexPath.row][@"name"];
        [self.navigationController pushViewController:detailsVC animated:YES];
    }
}

#pragma mark - Custom Methods

-(NSString *)getItemDate:(NSDictionary *)item
{
    NSString *date = [[NSString alloc] init];
    
    //Get the date of the event
    NSString *eventTime = item[@"event_time"];
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
    
    date = [[destinationDate description] stringByReplacingOccurrencesOfString:@"+0000" withString:@""];
    
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
                                       message:@"Oops!, debes iniciar sesión con Facebook para poder visualizar tus favoritos"
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
            NSLog(@"Hubo error borrando el item");
        }
        NSLog(@"%@", dictionary);
    }
}

-(void)serverError:(NSError *)error
{
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
