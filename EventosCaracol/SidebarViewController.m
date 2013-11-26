//
//  SidebarViewController.m
//  EventosCaracol
//
//  Created by Developer on 25/11/13.
//  Copyright (c) 2013 iAmStudio. All rights reserved.
//

#import "SidebarViewController.h"
#import "SWRevealViewController.h"
#import "MenuTableViewCell.h"
#import "FileSaver.h"
#import "ListViewController.h"

@interface SidebarViewController () <UITableViewDataSource, UITableViewDelegate>
@property (strong, nonatomic) NSArray *menuItems;
@property (strong, nonatomic) FileSaver *fileSaver;
@property (strong, nonatomic) NSArray *menuArray; //Of NSDictionary
@property (strong, nonatomic) NSArray *aditionalMenuItemsArray;
@end

@implementation SidebarViewController

-(void)viewDidLoad
{
    self.fileSaver = [[FileSaver alloc] init];
    
    self.aditionalMenuItemsArray = @[@"Preguntas frecuentes", @"Reportar un problema", @"Términos y condiciones"];
    
    //Array that holds all the menu objects (like artists, news, locations, etc)
    self.menuArray = [self.fileSaver getDictionary:@"master"][@"menu"];
    
    ///////////////////////////////////////////////////////
    //Create the top bar of the view
    UIView *topView = [[UIView alloc] initWithFrame:CGRectMake(0.0,
                                                               0.0,
                                                               self.view.frame.size.width,
                                                               64.0)];
    topView.backgroundColor = [UIColor grayColor];
    [self.view addSubview:topView];
    
    UILabel *topViewLabel = [[UILabel alloc] initWithFrame:CGRectMake(20.0,
                                                                      topView.frame.size.height/2,
                                                                      100.0,
                                                                      20.0)];
    topViewLabel.text = @"Menu";
    [topView addSubview:topViewLabel];
    
    ///////////////////////////////////////////////////////
    //Create the image view
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(10.0,
                                                                           topView.frame.origin.y + topView.frame.size.height + 10.0,
                                                                           238.0,
                                                                           50.0)];
    imageView.backgroundColor = [UIColor grayColor];
    [self.view addSubview:imageView];
    
    /////////////////////////////////////////////////////
    //Create the search bar
    UISearchBar *searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0.0,
                                                                           imageView.frame.origin.y + imageView.frame.size.height + 10.0,
                                                                           260.0,
                                                                           50.0)];
    [self.view addSubview:searchBar];
    
    ///////////////////////////////////////////////////////
    //Add a tableview to our view.
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0,
                                                                           searchBar.frame.origin.y + searchBar.frame.size.height,
                                                                           self.view.frame.size.width,
                                                                           self.view.frame.size.height - (searchBar.frame.origin.y + searchBar.frame.size.height))];
    tableView.rowHeight = 50.0;
    tableView.delegate = self;
    tableView.dataSource =self;
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [tableView setAlwaysBounceVertical:YES];
    [tableView registerClass:[MenuTableViewCell class] forCellReuseIdentifier:@"menuItemCell"];
    [self.view addSubview:tableView];
    
    self.view.backgroundColor = [UIColor cyanColor];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return ([self.menuArray count] + [self.aditionalMenuItemsArray count]);
    //NSLog(@"%d", [self.menuArray count] + [self.aditionalMenuItemsArray count]);
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MenuTableViewCell *cell = (MenuTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"menuItemCell"
                                                            forIndexPath:indexPath];
    if (indexPath.row < [self.menuArray count])
    {
        cell.menuItemLabel.text = self.menuArray[indexPath.row][@"name"];
        cell.menuItemImageView.image = [UIImage imageNamed:@"CorazonPrueba.png"];
    }
    
    else
    {
        cell.menuItemLabel.text = self.aditionalMenuItemsArray[indexPath.row-6];
    }
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    SWRevealViewController *revealViewController = self.revealViewController;
    
    //UINavigationController *frontNavigationController = (id)revealViewController.frontViewController;
    
    if (indexPath.row < [self.menuArray count])
    {
        if ([self.menuArray[indexPath.row][@"type"] isEqualToString:@"artistas"])
        {
            ListViewController *listVC = [self.storyboard instantiateViewControllerWithIdentifier:@"EventsList"];
            listVC.listArray = [self.fileSaver getDictionary:@"master"][@"artistas"];
            listVC.menuID = self.menuArray[indexPath.row][@"_id"];
            listVC.navigationBarTitle = self.menuArray[indexPath.row][@"name"];
            UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:listVC];
            [revealViewController setFrontViewController:navigationController animated:YES];
        }
        
        else if ([self.menuArray[indexPath.row][@"type"] isEqualToString:@"eventos"])
        {
            ListViewController *listVC = [self.storyboard instantiateViewControllerWithIdentifier:@"EventsList"];
            listVC.listArray = [self.fileSaver getDictionary:@"master"][@"eventos"];
            listVC.menuID = self.menuArray[indexPath.row][@"_id"];
            listVC.navigationBarTitle = self.menuArray[indexPath.row][@"name"];
            UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:listVC];
            [revealViewController setFrontViewController:navigationController animated:YES];
        }
        
        else if ([self.menuArray[indexPath.row][@"type"] isEqualToString:@"noticias"])
        {
            ListViewController *listVC = [self.storyboard instantiateViewControllerWithIdentifier:@"EventsList"];
            listVC.listArray = [self.fileSaver getDictionary:@"master"][@"noticias"];
            listVC.menuID = self.menuArray[indexPath.row][@"_id"];
            listVC.navigationBarTitle = self.menuArray[indexPath.row][@"name"];
            UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:listVC];
            [revealViewController setFrontViewController:navigationController animated:YES];
        }
    }
}

@end
