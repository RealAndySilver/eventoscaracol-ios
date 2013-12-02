//
//  SidebarViewController.m
//  EventosCaracol
//
//  Created by Developer on 25/11/13.
//  Copyright (c) 2013 iAmStudio. All rights reserved.
//

#import <SDWebImage/UIImageView+WebCache.h>
#import "SidebarViewController.h"
#import "SWRevealViewController.h"
#import "MenuTableViewCell.h"
#import "FileSaver.h"
#import "ListViewController.h"
#import "FAQViewController.h"
#import "MapViewController.h"
#import "DetailsViewController.h"
#import "DestacadosViewController.h"

@interface SidebarViewController () 
@property (strong, nonatomic) NSArray *menuItems;
@property (strong, nonatomic) FileSaver *fileSaver;
@property (strong, nonatomic) NSArray *menuArray; //Of NSDictionary
@property (strong, nonatomic) NSArray *aditionalMenuItemsArray;
@property (strong, nonatomic) NSArray *searchResults;
@property (strong, nonatomic) NSMutableArray *allObjectsTypeArray;
@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) UILabel *updateLabel;
@property (strong, nonatomic) UIImageView *updateImageView;
@property (strong, nonatomic) NSOperationQueue *queue;
@property (strong, nonatomic) UIActivityIndicatorView *spinner;
@property (nonatomic) BOOL isUpdating;
@property (nonatomic) BOOL shouldUpdate;
@property (nonatomic) float offset;
@end

@implementation SidebarViewController

#pragma mark - View lifecycle

-(void)setupPullDownToRefreshView
{
    /*self.updateLabel = [[UILabel alloc] initWithFrame:CGRectMake(80.0, -40.0, self.view.frame.size.width - 80.0, 20.0)];
    self.updateLabel.text = @"Hala para actualizar";
    self.updateLabel.font = [UIFont fontWithName:@"Helvetica" size:15.0];
    self.updateLabel.textAlignment = NSTextAlignmentLeft;
    self.updateLabel.textColor = [UIColor lightGrayColor];*/
    
    self.updateImageView = [[UIImageView alloc] initWithFrame:CGRectMake(self.view.frame.size.width/2 - 40.0, -50.0, 20.0, 40.0)];
    self.updateImageView.image = [UIImage imageNamed:@"updateArrow.png"];
    //[self.tableView addSubview:self.updateLabel];
    [self.tableView addSubview:self.updateImageView];
}

-(void)viewDidLoad
{
    self.fileSaver = [[FileSaver alloc] init];
    
    //Store the info for the aditional buttons of the slide menu table view
    self.aditionalMenuItemsArray = @[@"Preguntas frecuentes", @"Reportar un problema", @"Términos y condiciones"];
    
    //Array that holds all the menu objects to display in the table view(like artists, news, locations, etc)
    self.menuArray = [self.fileSaver getDictionary:@"master"][@"menu"];
    
    //Array that holds of the objects of type artist, events, news and locations. we will use this array later when the
    //user make a search in the search bar. the results of that search will be filtered from this array.
    self.allObjectsTypeArray = [self.fileSaver getDictionary:@"master"][@"artistas"];
    [self.allObjectsTypeArray addObjectsFromArray:[self.fileSaver getDictionary:@"master"][@"noticias"]];
    [self.allObjectsTypeArray addObjectsFromArray:[self.fileSaver getDictionary:@"master"][@"eventos"]];
    [self.allObjectsTypeArray addObjectsFromArray:[self.fileSaver getDictionary:@"master"][@"locaciones"]];
    ///////////////////////////////////////////////////////////////
    //Create the image view
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0,
                                                                           0.0,
                                                                           self.view.frame.size.width,
                                                                           100.0)];
    imageView.userInteractionEnabled = YES;
    imageView.backgroundColor = [UIColor grayColor];
    imageView.clipsToBounds = YES;
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    NSDictionary *appInfo = [self.fileSaver getDictionary:@"master"][@"app"];
    [imageView setImageWithURL:[NSURL URLWithString:appInfo[@"logo_square_url"]]];
    [self.view addSubview:imageView];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapOnLogoImageView)];
    tap.numberOfTapsRequired = 1;
    [imageView addGestureRecognizer:tap];
    
    ///////////////////////////////////////////////////////////////////////////////
    //Add a tableview to our view.
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0,
                                                                           self.searchDisplayController.searchBar.frame.origin.y + self.searchDisplayController.searchBar.frame.size.height,
                                                                           self.view.frame.size.width,
                                                                           self.view.frame.size.height - (self.searchDisplayController.searchBar.frame.origin.y + self.searchDisplayController.searchBar.frame.size.height))];
    
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
    //return ([self.menuArray count] + [self.aditionalMenuItemsArray count]);
    
    if (tableView == self.searchDisplayController.searchResultsTableView)
    {
        return [self.searchResults count];
    }
    
    else
    {
        return ([self.menuArray count] + [self.aditionalMenuItemsArray count]);
    }
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
            cell.menuItemLabel.text = self.menuArray[indexPath.row][@"name"];
            [cell.menuItemImageView setImageWithURL:self.menuArray[indexPath.row][@"icon_url"]
                                   placeholderImage:[UIImage imageNamed:@"CaracolPrueba3.png"]];
        }
        
        else
        {
            cell.menuItemLabel.text = self.aditionalMenuItemsArray[indexPath.row-6];
            cell.menuItemImageView.image = nil;
        }
    }
    return cell;
}

#pragma mark - UITableViewDelegate
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    SWRevealViewController *revealViewController = self.revealViewController;
    
    //If the selected table view was the search bar table view
    if (tableView == self.searchDisplayController.searchResultsTableView)
    {
        if ([self.searchResults[indexPath.row][@"type"] isEqualToString:@"locaciones"])
        {
            DetailsViewController *detailsVC = [self.storyboard instantiateViewControllerWithIdentifier:@"EventDetails"];
            detailsVC.navigationBarTitle = self.searchResults[indexPath.row][@"name"];
            detailsVC.objectInfo = self.searchResults[indexPath.row];
            detailsVC.presentViewControllerFromSearchBar = YES;
            detailsVC.presentLocationObject = YES;
            UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:detailsVC];
            navigationController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
            [self presentViewController:navigationController animated:YES completion:nil];
        }
        
        else
        {
            DetailsViewController *detailsVC = [self.storyboard instantiateViewControllerWithIdentifier:@"EventDetails"];
            detailsVC.navigationBarTitle = self.searchResults[indexPath.row][@"name"];
            detailsVC.objectInfo = self.searchResults[indexPath.row];
            detailsVC.presentViewControllerFromSearchBar = YES;
            UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:detailsVC];
            navigationController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
            [self presentViewController:navigationController animated:YES completion:nil];
        }
    }
    
    else
    {
        if (indexPath.row < [self.menuArray count])
        {
            if ([self.menuArray[indexPath.row][@"type"] isEqualToString:@"artistas"])
            {
                ListViewController *listVC = [self.storyboard instantiateViewControllerWithIdentifier:@"EventsList"];
                
                NSArray *tempArray = [self.fileSaver getDictionary:@"master"][@"artistas"];
                NSMutableArray *tempMutableArray = [[NSMutableArray alloc] init];
                NSString *menuID = self.menuArray[indexPath.row][@"_id"];
                for (int i = 0; i < [tempArray count]; i++)
                {
                    //If yes, add the object to menuItemsArray
                    if ([tempArray[i][@"menu_item_id"] isEqualToString:menuID])
                        [tempMutableArray addObject:tempArray[i]];
                }
                listVC.menuItemsArray = tempMutableArray;
                listVC.navigationBarTitle = self.menuArray[indexPath.row][@"name"];
                UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:listVC];
                [revealViewController setFrontViewController:navigationController animated:YES];
            }
            
            else if ([self.menuArray[indexPath.row][@"type"] isEqualToString:@"eventos"])
            {
                ListViewController *listVC = [self.storyboard instantiateViewControllerWithIdentifier:@"EventsList"];
                
                NSArray *tempArray = [self.fileSaver getDictionary:@"master"][@"eventos"];
                NSMutableArray *tempMutableArray = [[NSMutableArray alloc] init];
                NSString *menuID = self.menuArray[indexPath.row][@"_id"];
                for (int i = 0; i < [tempArray count]; i++)
                {
                    //If yes, add the object to menuItemsArray
                    if ([tempArray[i][@"menu_item_id"] isEqualToString:menuID])
                        [tempMutableArray addObject:tempArray[i]];
                }
                listVC.menuItemsArray = tempMutableArray;
                listVC.navigationBarTitle = self.menuArray[indexPath.row][@"name"];
                UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:listVC];
                [revealViewController setFrontViewController:navigationController animated:YES];
            }
            
            else if ([self.menuArray[indexPath.row][@"type"] isEqualToString:@"noticias"])
            {
                ListViewController *listVC = [self.storyboard instantiateViewControllerWithIdentifier:@"EventsList"];
                
                NSArray *tempArray = [self.fileSaver getDictionary:@"master"][@"noticias"];
                NSMutableArray *tempMutableArray = [[NSMutableArray alloc] init];
                NSString *menuID = self.menuArray[indexPath.row][@"_id"];
                for (int i = 0; i < [tempArray count]; i++)
                {
                    //If yes, add the object to menuItemsArray
                    if ([tempArray[i][@"menu_item_id"] isEqualToString:menuID])
                        [tempMutableArray addObject:tempArray[i]];
                }
                listVC.menuItemsArray = tempMutableArray;
                listVC.navigationBarTitle = self.menuArray[indexPath.row][@"name"];
                UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:listVC];
                [revealViewController setFrontViewController:navigationController animated:YES];
            }
            
            else if ([self.menuArray[indexPath.row][@"type"] isEqualToString:@"locaciones"])
            {
                MapViewController *mapVC = [self.storyboard instantiateViewControllerWithIdentifier:@"Map"];
                mapVC.navigationBarTitle = self.menuArray[indexPath.row][@"name"];
                
                NSArray *tempArray = [self.fileSaver getDictionary:@"master"][@"locaciones"];
                NSMutableArray *tempMutableArray = [[NSMutableArray alloc] init];
                NSString *menuID = self.menuArray[indexPath.row][@"_id"];
                for (int i = 0; i < [tempArray count]; i++)
                {
                    //If yes, add the object to menuItemsArray
                    if ([tempArray[i][@"menu_item_id"] isEqualToString:menuID])
                        [tempMutableArray addObject:tempArray[i]];
                }
                mapVC.locationsArray = tempMutableArray;
                UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:mapVC];
                [revealViewController setFrontViewController:navigationController animated:YES];
            }
        }
        
        else
        {
            FAQViewController *faqViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"FAQ"];
            UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:faqViewController];
            [revealViewController setFrontViewController:navigationController animated:YES];
        }
    }
}

#pragma mark - Custom Methods

/*-(void)presentListViewControllerWithObjectsOfType:(NSString *)objectType selectedRow:(NSInteger)row
{
    SWRevealViewController *revealViewController = [self revealViewController];
    
    ListViewController *listVC = [self.storyboard instantiateViewControllerWithIdentifier:@"EventsList"];
    NSArray *tempArray = [[self.fileSaver getDictionary:@"master"] objectForKey:objectType];
    NSMutableArray *tempMutableArray = [[NSMutableArray alloc] init];
    NSString *menuID = self.menuArray[row][@"_id"];
    for (int i = 0; i < [tempArray count]; i++)
    {
        //If yes, add the object to menuItemsArray
        if ([tempArray[i][@"menu_item_id"] isEqualToString:menuID])
            [tempMutableArray addObject:tempArray[i]];
    }
    listVC.menuItemsArray = tempMutableArray;
    listVC.navigationBarTitle = self.menuArray[row][@"name"];
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:listVC];
    [revealViewController setFrontViewController:navigationController animated:YES];
}*/

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
        self.queue = [NSOperationQueue new];
        NSInvocationOperation *updateOperation = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(updateMethod)  object:nil];
        [self.queue addOperation:updateOperation];
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.2];
        self.tableView.contentInset = UIEdgeInsetsMake(60, 0, 0, 0);
        [UIView commitAnimations];
    }
}

#pragma mark - Pull Down To Refresh methods

- (void) updateMethod
{
    [self performSelectorOnMainThread:@selector(startSpinner) withObject:nil waitUntilDone:NO];
}

- (void) startSpinner {
    self.spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.spinner.center = self.updateImageView.center;
    self.updateImageView.hidden = YES;
    [self.spinner startAnimating];
    [self.tableView addSubview:self.spinner];
    //self.updateLabel.text = @"Actualizando...";
    self.isUpdating = YES;
    [NSTimer scheduledTimerWithTimeInterval:3.0 target:self selector:@selector(finishUpdateMethod) userInfo:nil repeats:NO];
    //this is the place where you can perform your data updating procedure(data populating from web or your database), for this section i am simply reloading data after 3 seconds of pull down
}

-(void) finishUpdateMethod {
    [self stopSpinner];
    [self.spinner removeFromSuperview];
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
}
- (void) stopSpinner {
    [self.spinner removeFromSuperview];
    self.updateImageView.hidden = NO;
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.2];
    self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
    [UIView commitAnimations];
    self.isUpdating = NO;
}

@end
