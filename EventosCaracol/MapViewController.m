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
@property (strong, nonatomic) CLLocationManager *locationManager;
@end

@implementation MapViewController

-(void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:29.0/255.0 green:80.0/255.0 blue:204.0/255.0 alpha:1.0];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor whiteColor]};
    
    [self createMap];
    [self createFilterButtons];
    
    UIBarButtonItem *slideMenuBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"SidebarIcon.png"]
                                                                               style:UIBarButtonItemStylePlain
                                                                              target:self.revealViewController
                                                                              action:@selector(revealToggle:)];
    self.navigationItem.leftBarButtonItem = slideMenuBarButtonItem;
    self.navigationItem.title = self.navigationBarTitle;
    
}

-(void)createMap
{
    /////////////////////////////////////////////////////////////////////////
    //Google Maps configuration
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.distanceFilter = kCLDistanceFilterNone;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
    [self.locationManager startUpdatingLocation];
    
    int nearestLocationFromUserIndex = 0;
    for (int i = 0; i < [self.locationsArray count]; i++)
    {
        static double lessDistance = 1000000;
        CLLocationDegrees latitudeDegrees = [self.locationsArray[i][@"lat"] doubleValue];
        CLLocationDegrees longitudeDegrees = [self.locationsArray[i][@"lon"] doubleValue];
        CLLocation *location = [[CLLocation alloc] initWithLatitude:latitudeDegrees longitude:longitudeDegrees];
        CLLocationDistance distance = [self.locationManager.location distanceFromLocation:location]/1000;
        
        if (distance < lessDistance)
        {
            lessDistance = distance;
            nearestLocationFromUserIndex = i;
        }
        NSLog(@"Distance: %f", distance);
    }
    
    NSLog(@"El lugar mas cercano está en la posicion %d", nearestLocationFromUserIndex);
    
    [self.locationManager stopUpdatingLocation];
    self.locationManager = nil;
    
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:[self.locationsArray[nearestLocationFromUserIndex][@"lat"] doubleValue]
                                                            longitude:[self.locationsArray[nearestLocationFromUserIndex][@"lon"] doubleValue]
                                                                 zoom:12.0];
    
    self.mapView = [GMSMapView mapWithFrame:CGRectMake(0.0,
                                                       0.0,
                                                       self.view.frame.size.width,
                                                       self.view.frame.size.height)
                                     camera:camera];
    //self.mapView.myLocationEnabled = YES;
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

-(void)createFilterButtons
{
    /////////////////////////////////////////////////////////////////////////
    //Create two buttons, one for sorting the places, and other to see the places in a list.
    UIButton *sortPlacesButton = [[UIButton alloc] initWithFrame:CGRectMake(0.0,
                                                                            self.navigationController.navigationBar.frame.origin.y + self.navigationController.navigationBar.frame.size.height,
                                                                            self.view.frame.size.width/2,
                                                                            44.0)];
    
    [sortPlacesButton setBackgroundImage:[UIImage imageNamed:@"BotonTodosLosSitios.png"] forState:UIControlStateNormal];
    [sortPlacesButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    sortPlacesButton.titleLabel.font = [UIFont fontWithName:@"Helvetica" size:14.0];
    [sortPlacesButton setTitle:@"Todos los sitios" forState:UIControlStateNormal];
    [self.view addSubview:sortPlacesButton];
    
    UIButton *viewPlacesInListButton = [[UIButton alloc] initWithFrame:CGRectMake(self.view.frame.size.width/2,
                                                                                  self.navigationController.navigationBar.frame.origin.y + self.navigationController.navigationBar.frame.size.height,
                                                                                  self.view.frame.size.width/2,
                                                                                  44.0)];
    [viewPlacesInListButton setBackgroundImage:[UIImage imageNamed:@"BotonTodosLosSitios.png"] forState:UIControlStateNormal];
    viewPlacesInListButton.titleLabel.font = [UIFont fontWithName:@"Helvetica" size:14.0];
    [viewPlacesInListButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    [viewPlacesInListButton setTitle:@"Ver Listado" forState:UIControlStateNormal];
    [viewPlacesInListButton addTarget:self action:@selector(goToListViewController) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:viewPlacesInListButton];

}

-(void)goToListViewController
{
    ListViewController *listVC = [self.storyboard instantiateViewControllerWithIdentifier:@"EventsList"];
    listVC.menuItemsArray = [self.locationsArray copy];
    listVC.menuID = self.menuID;
    listVC.objectType = self.objectType;
    listVC.navigationBarTitle = @"Listado Locaciones";
    listVC.locationList = YES;
    [self.navigationController pushViewController:listVC animated:YES];
}

@end
