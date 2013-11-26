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
#import "EventsListViewController.h"

@interface SidebarViewController () <UITableViewDataSource, UITableViewDelegate>
@property (strong, nonatomic) NSArray *menuItems;
@property (strong, nonatomic) NSArray *menuArray; //Of NSDictionary
@end

@implementation SidebarViewController

-(void)viewDidLoad
{
    FileSaver *fileSaver = [[FileSaver alloc] init];
    
    self.menuArray = [fileSaver getDictionary:@"master"][@"menu"];
    
    //Add a tableview to our view.
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0,
                                                                           100.0,
                                                                           self.view.frame.size.width,
                                                                           350.0)];
    tableView.rowHeight = 50.0;
    tableView.delegate = self;
    tableView.dataSource =self;
    [tableView setAlwaysBounceVertical:YES];
    [tableView registerClass:[MenuTableViewCell class] forCellReuseIdentifier:@"menuItemCell"];
    [self.view addSubview:tableView];
    
    self.view.backgroundColor = [UIColor cyanColor];
    
    //Initialize our menuItems Array
    //self.menuItems = @[@"Destacados", @"programacion", @"mapa", @"favoritos", @"actividad", @"informacion", @"configuracion"];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.menuArray count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MenuTableViewCell *cell = (MenuTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"menuItemCell"
                                                            forIndexPath:indexPath];
    cell.menuItemLabel.text = self.menuArray[indexPath.row][@"name"];
    cell.menuItemImageView.image = [UIImage imageNamed:@"CorazonPrueba.png"];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    /*SWRevealViewController *revealViewController = self.revealViewController;
    
    UINavigationController *frontNavigationController = (id)revealViewController.frontViewController;
    
    if ([self.menuArray[indexPath.row][@"type"] isEqualToString:@"artistas"])
    {
        if (![frontNavigationController isKindOfClass:[EventsListViewController class]])
        {
            EventsListViewController *listVC = [self.storyboard instantiateViewControllerWithIdentifier:@"EventsList"];
            UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:listVC];
            [revealViewController setFrontViewController:navigationController animated:YES];
        }
        else
        {
            [revealViewController revealToggle:self];
        }
    }*/
}

@end
