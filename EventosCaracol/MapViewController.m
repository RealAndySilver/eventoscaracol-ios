//
//  MapViewController.m
//  EventosCaracol
//
//  Created by Developer on 27/11/13.
//  Copyright (c) 2013 iAmStudio. All rights reserved.
//

#import "SWRevealViewController.h"
#import "MapViewController.h"
#import <GoogleMaps/GoogleMaps.h>
#import "ListViewController.h"

@interface MapViewController ()
@property (strong, nonatomic) GMSMapView *mapView;
//@property (strong, nonatomic) NSMutableArray *correctLocationsArray;
@end

@implementation MapViewController

-(void)viewDidLoad
{
    [super viewDidLoad];
    /////////////////////////////////////////////////////////////////////////
    //Create two buttons, one for sorting the places, and other to see the places in a list.
    UIButton *sortPlacesButton = [[UIButton alloc] initWithFrame:CGRectMake(0.0,
                                                                            self.navigationController.navigationBar.frame.origin.y + self.navigationController.navigationBar.frame.size.height,
                                                                            self.view.frame.size.width/2,
                                                                            44.0)];
    [sortPlacesButton setTitle:@"Todos los sitios" forState:UIControlStateNormal];
    sortPlacesButton.backgroundColor = [UIColor cyanColor];
    [self.view addSubview:sortPlacesButton];
    
    UIButton *viewPlacesInListButton = [[UIButton alloc] initWithFrame:CGRectMake(self.view.frame.size.width/2,
                                                                                  self.navigationController.navigationBar.frame.origin.y + self.navigationController.navigationBar.frame.size.height,
                                                                                  self.view.frame.size.width/2,
                                                                                  44.0)];
    [viewPlacesInListButton setTitle:@"Ver Listado" forState:UIControlStateNormal];
    viewPlacesInListButton.backgroundColor = [UIColor cyanColor];
    [viewPlacesInListButton addTarget:self action:@selector(goToListViewController) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:viewPlacesInListButton];

        
    /////////////////////////////////////////////////////////////////////////
    //Slide Menu configuration
    SWRevealViewController *revealViewController = [self revealViewController];
    
    UIBarButtonItem *slideMenuBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Menu"
                                                                               style:UIBarButtonItemStylePlain
                                                                              target:revealViewController
                                                                              action:@selector(revealToggle:)];
    self.navigationItem.leftBarButtonItem = slideMenuBarButtonItem;
    self.navigationItem.title = self.navigationBarTitle;
    
    
    /////////////////////////////////////////////////////////////////////////
    //Google Maps configuration
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:[self.locationsArray[0][@"lat"] doubleValue]
                                                            longitude:[self.locationsArray[0][@"lon"] doubleValue]
                                                                 zoom:12.0];
    
    self.mapView = [GMSMapView mapWithFrame:CGRectMake(0.0,
                                                       sortPlacesButton.frame.origin.y + sortPlacesButton.frame.size.height,
                                                       self.view.frame.size.width,
                                                       self.view.frame.size.height - (sortPlacesButton.frame.origin.y + sortPlacesButton.frame.size.height))
                                     camera:camera];
    
    self.mapView.myLocationEnabled = YES;
    //self.view = self.mapView;
    [self.view addSubview:self.mapView];
    for (int i = 0; i < [self.locationsArray count]; i++)
    {
        double markerLatitute = [self.locationsArray[i][@"lat"] doubleValue];
        double markerLongitude = [self.locationsArray[i][@"lon"] doubleValue];
        GMSMarker *marker = [GMSMarker markerWithPosition:CLLocationCoordinate2DMake(markerLatitute, markerLongitude)];
        marker.title = self.locationsArray[i][@"name"];
        //marker.snippet = @"Australia";
        marker.map = self.mapView;
    }
}

-(void)goToListViewController
{
    ListViewController *listVC = [self.storyboard instantiateViewControllerWithIdentifier:@"EventsList"];
    listVC.menuItemsArray = self.locationsArray;
    NSLog(@"%@", listVC.menuItemsArray);
    listVC.navigationBarTitle = self.navigationBarTitle;
    listVC.locationList = YES;
    //[self presentViewController:listVC animated:YES completion:nil];
    [self.navigationController pushViewController:listVC animated:YES];
}

@end
