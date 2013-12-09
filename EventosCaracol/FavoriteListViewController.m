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
@end

@implementation FavoriteListViewController

#pragma mark - View lifecycle

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
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:144.0/255.0 green:192.0/255.0 blue:58.0/255.0 alpha:1.0];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor whiteColor]};
    
    //////////////////////////////////////////////////////////////////////
    //Create a UITableView to display the favorited items
    self.tableView = [[UITableView alloc] initWithFrame:self.view.frame
                                                          style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.rowHeight = 90.0;
    self.tableView.contentInset = UIEdgeInsetsMake(self.navigationController.navigationBar.frame.origin.y + self.navigationController.navigationBar.frame.size.height, 0.0, 0.0, 0.0);
    [self.view addSubview:self.tableView];
    //Get info from the server
    [self getFavoritesInfoFromServer];
}

#pragma mark - UITableViewDelegate & UITableViewDataSource

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.favoritedItems count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
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
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(10.0, 10.0, 70.0, 70.0)];
    imageView.clipsToBounds = YES;
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    imageView.backgroundColor = [UIColor cyanColor];
    
    //Set the cell's thumb image using the SDWebImage Method -setImageWithURL: (This method saves the image in cache).
    [imageView setImageWithURL:self.favoritedItems[indexPath.row][@"thumb_url"] placeholderImage:[UIImage imageNamed:@"CaracolPrueba4.png"]];
    
    [cell.contentView addSubview:imageView];
    
    UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(100.0, 20.0, 150, 20.0)];
    nameLabel.text = self.favoritedItems[indexPath.row][@"name"];
    nameLabel.font = [UIFont fontWithName:@"Helvetica" size:15.0];
    [cell.contentView addSubview:nameLabel];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"%@", self.favoritedItems[indexPath.row][@"name"]);
}

#pragma mark - Server Communication

-(void)getFavoritesInfoFromServer
{
    ServerCommunicator *serverCommunicator = [[ServerCommunicator alloc] init];
    serverCommunicator.delegate = self;
    NSString *parameters = [NSString stringWithFormat:@"%@/%@", [self getDictionaryWithName:@"master"][@"app"][@"_id"],
                            [self getDictionaryWithName:@"user"][@"_id"]];
    [serverCommunicator callServerWithGETMethod:@"GetFavoritedItemsFromUser" andParameter:parameters];
}

-(void)receivedDataFromServer:(NSDictionary *)dictionary withMethodName:(NSString *)methodName
{
    if ([methodName isEqualToString:@"GetFavoritedItemsFromUser"])
    {
        BOOL status = [dictionary[@"status"] boolValue];
        if (status == YES)
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
        [MBHUDView dismissCurrentHUD];
        BOOL status = [dictionary[@"status"] boolValue];
        if (status == YES)
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

-(void)unFavItemAtIndex:(NSUInteger)index
{
    
    self.rowIndex = index;
    
    //Create a string that contains the parameters to send to the server.
    NSString *params = [NSString stringWithFormat:@"item_id=%@&user_id=%@&type=%@&app_id=%@", self.favoritedItems[index][@"_id"], [self getDictionaryWithName:@"user"][@"_id"], self.favoritedItems[index][@"type"], [self getDictionaryWithName:@"master"][@"app"][@"_id"]];
    ServerCommunicator *serverCommunicator = [[ServerCommunicator alloc] init];
    serverCommunicator.delegate = self;
    
    //Communicate asynchronously with the server
    dispatch_queue_t server = dispatch_queue_create("server", nil);
    dispatch_async(server, ^(){
            [serverCommunicator callServerWithPOSTMethod:@"UnFavItem" andParameter:params httpMethod:@"POST"];
    });
}

@end
