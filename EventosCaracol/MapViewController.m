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
#import "FileSaver.h"
#import "ListViewController.h"

@interface MapViewController ()
@property (strong, nonatomic) GMSMapView *mapView;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) UIPickerView *datePickerView;
@property (strong, nonatomic) UIView *containerDatesPickerView;
@property (strong, nonatomic) UIButton *sortPlacesButton;
@property (nonatomic) BOOL isPickerActivated;
@property (strong, nonatomic) NSString *selectedLocationID;
@property (strong, nonatomic) NSMutableArray *markers;
@property (strong, nonatomic) UIView *blockTouchesView;
@end

@implementation MapViewController

-(void)viewDidLoad
{
    [super viewDidLoad];
    self.revealViewController.delegate = self;
    self.blockTouchesView = [[UIView alloc] initWithFrame:self.view.frame];
    self.markers = [[NSMutableArray alloc] init];
    
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:29.0/255.0 green:80.0/255.0 blue:204.0/255.0 alpha:1.0];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor whiteColor]};
    
    [self createMap];
    [self createFilterButtons];
    [self createPickerView];
    
    UIBarButtonItem *slideMenuBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"SidebarIcon.png"]
                                                                               style:UIBarButtonItemStylePlain
                                                                              target:self.revealViewController
                                                                              action:@selector(revealToggle:)];
    self.navigationItem.leftBarButtonItem = slideMenuBarButtonItem;
    self.navigationItem.title = self.navigationBarTitle;
}

-(void)createPickerView
{
    //////////////////////////////////////////////////////////////////
    //Configure container view for the Dates picker.
    self.containerDatesPickerView = [[UIView alloc] initWithFrame:CGRectMake(0.0, self.view.frame.size.height, self.view.frame.size.width, 220.0)];
    self.containerDatesPickerView.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.4];
    
    /////////////////////////////////////////////////////////////////
    //Configure datePickerView
    self.datePickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(0.0,
                                                                         0.0,
                                                                         self.containerDatesPickerView.frame.size.width,
                                                                         self.containerDatesPickerView.frame.size.height)];
    self.datePickerView.tag = 1;
    self.datePickerView.delegate = self;
    self.datePickerView.dataSource = self;
    [self.containerDatesPickerView addSubview:self.datePickerView];
    
    /////////////////////////////////////////////////////////////////
    //Create a button to dismiss the location picker view.
    UIButton *dismissLocationPickerButton = [[UIButton alloc] initWithFrame:CGRectMake(self.containerDatesPickerView.frame.size.width - 40.0, self.containerDatesPickerView.frame.size.height - 40.0, 40.0, 40.0)];
    dismissLocationPickerButton.tag = 1;
    dismissLocationPickerButton.backgroundColor = [UIColor clearColor];
    [dismissLocationPickerButton setImage:[UIImage imageNamed:@"DismissPickerButtonImage.png"] forState:UIControlStateNormal];
    [dismissLocationPickerButton addTarget:self action:@selector(showPickerView:) forControlEvents:UIControlEventTouchUpInside];
    [self.containerDatesPickerView addSubview:dismissLocationPickerButton];
    [self.view addSubview:self.containerDatesPickerView];
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
    float maxDistanceFromUser;
    for (int i = 0; i < [self.locationsArray count]; i++)
    {
        static double lessDistance = 1000000;
        static double maxDistance = 0;
        CLLocationDegrees latitudeDegrees = [self.locationsArray[i][@"lat"] doubleValue];
        CLLocationDegrees longitudeDegrees = [self.locationsArray[i][@"lon"] doubleValue];
        CLLocation *location = [[CLLocation alloc] initWithLatitude:latitudeDegrees longitude:longitudeDegrees];
        CLLocationDistance distance = [self.locationManager.location distanceFromLocation:location]/1000;
        
        if (distance < lessDistance)
        {
            lessDistance = distance;
            nearestLocationFromUserIndex = i;
        }
        
        if (distance > maxDistance)
        {
            maxDistance = distance;
            maxDistanceFromUser = maxDistance;
        }
        
        NSLog(@"Distance: %f", distance);
    }
    NSLog(@"MaxDistanceFromUser: %f", maxDistanceFromUser);
    
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
        marker.snippet = self.locationsArray[i][@"short_detail"];
        marker.map = self.mapView;
        [self.markers addObject:marker];
    }
}

-(void)createFilterButtons
{
    /////////////////////////////
    UIView *grayView = [[UIView alloc] initWithFrame:CGRectMake(0.0,
                                                               self.navigationController.navigationBar.frame.origin.y + self.navigationController.navigationBar.frame.size.height,
                                                               self.view.frame.size.width,
                                                                44.0)];
    grayView.backgroundColor = [UIColor colorWithRed:230.0/255.0 green:230.0/255.0 blue:230.0/255.0 alpha:1.0];
    [self.view addSubview:grayView];
    
    /////////////////////////////////////////////////////////////////////////
    //Create two buttons, one for sorting the places, and other to see the places in a list.
    self.sortPlacesButton = [[UIButton alloc] initWithFrame:CGRectMake(self.view.frame.size.width/4 - 80.0,
                                                                            self.navigationController.navigationBar.frame.origin.y + self.navigationController.navigationBar.frame.size.height,
                                                                            160.0,
                                                                            44.0)];
    
    [self.sortPlacesButton setBackgroundImage:[UIImage imageNamed:@"BotonTodosLosSitios.png"] forState:UIControlStateNormal];
    [self.sortPlacesButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    self.sortPlacesButton.titleLabel.font = [UIFont fontWithName:@"Helvetica" size:14.0];
    [self.sortPlacesButton setTitle:@"Todos los sitios" forState:UIControlStateNormal];
    [self.sortPlacesButton addTarget:self action:@selector(showPickerView:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.sortPlacesButton];
    
    UIButton *viewPlacesInListButton = [[UIButton alloc] initWithFrame:CGRectMake(self.view.frame.size.width/2 + self.view.frame.size.width/4 - 80.0,
                                                                                  self.navigationController.navigationBar.frame.origin.y + self.navigationController.navigationBar.frame.size.height,
                                                                                  160.0,
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

#pragma mark - Custom Methods

-(void)showPickerView:(UIPickerView*)sender
{
    //If pickerIsActivated = NO, create and animation to show the picker on screen.
    if (!self.isPickerActivated)
    {
        //[self.view addSubview:containerView];
        NSLog(@"me oprimi");
        [UIView animateWithDuration:0.3
                              delay:0.0
                            options: UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             
                             //Bring up the corresponding container view.
                             
                             self.containerDatesPickerView.transform = CGAffineTransformMakeTranslation(0.0, -self.containerDatesPickerView.frame.size.height);
                             
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
                             self.containerDatesPickerView.transform = CGAffineTransformMakeTranslation(0.0, self.containerDatesPickerView.frame.size.height);
                             
                         }
                         completion:^(BOOL finished){
                             //[containerView removeFromSuperview];
                         }
         
         ];
        
        self.isPickerActivated = NO;
    }
}

-(void)setNewPlaces
{
    BOOL oneOrMorePlacesFound = NO;
    float finalCameraAnimationLatitude;
    float finalCameraAnimationLongitude;
    for (int i = 0; i < [self.locationsArray count]; i++)
    {
        if ([self.selectedLocationID isEqualToString:@"All"])
        {
            NSLog(@"todos los lugares");
            double markerLatitute = [self.locationsArray[i][@"lat"] doubleValue];
            double markerLongitude = [self.locationsArray[i][@"lon"] doubleValue];
            
            finalCameraAnimationLatitude = markerLatitute;
            finalCameraAnimationLongitude = markerLongitude;
            
            GMSMarker *marker = [GMSMarker markerWithPosition:CLLocationCoordinate2DMake(markerLatitute, markerLongitude)];
            marker.title = self.locationsArray[i][@"name"];
            marker.snippet = self.locationsArray[i][@"short_detail"];
            marker.map = self.mapView;
            
            oneOrMorePlacesFound = YES;
        }
        else if ([self.locationsArray[i][@"category_id"] isEqualToString:self.selectedLocationID])
        {
            NSLog(@"Encontré la categoría del lugar");
            double markerLatitute = [self.locationsArray[i][@"lat"] doubleValue];
            double markerLongitude = [self.locationsArray[i][@"lon"] doubleValue];
            
            finalCameraAnimationLatitude = markerLatitute;
            finalCameraAnimationLongitude = markerLongitude;
            
            GMSMarker *marker = [GMSMarker markerWithPosition:CLLocationCoordinate2DMake(markerLatitute, markerLongitude)];
            marker.title = self.locationsArray[i][@"name"];
            marker.snippet = self.locationsArray[i][@"short_detail"];
            marker.map = self.mapView;
            
            oneOrMorePlacesFound = YES;
        }
    }
    if (oneOrMorePlacesFound)
    {
        [self.mapView animateToLocation:CLLocationCoordinate2DMake(finalCameraAnimationLatitude, finalCameraAnimationLongitude)];
        NSLog(@"encontré lugares");
    }
}

#pragma mark - UIPickerViewDelegate & UIPickerViewDataSource

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    if (row == 0)
    {
        [self.sortPlacesButton setTitle:@"Todos los lugares" forState:UIControlStateNormal];
        self.selectedLocationID = @"All";
    }
    else
    {
        NSString *buttonTitle = [self getDictionaryWithName:@"master"][@"categorias"][row - 1][@"name"];
        [self.sortPlacesButton setTitle:buttonTitle forState:UIControlStateNormal];
        self.selectedLocationID = [self getDictionaryWithName:@"master"][@"categorias"][row - 1][@"_id"];
    }
    
    [self.mapView clear];
    [self setNewPlaces];
}

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return [[self getDictionaryWithName:@"master"][@"categorias"] count] + 1;
}

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    if (row == 0)
        return @"Todos los Lugares";
    else
        return [self getDictionaryWithName:@"master"][@"categorias"][row - 1][@"name"];
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

#pragma mark - FileSaver Stuff

-(NSDictionary*)getDictionaryWithName:(NSString*)name{
    FileSaver *file=[[FileSaver alloc]init];
    return [file getDictionary:name];
}
-(void)setDictionary:(NSDictionary*)dictionary withName:(NSString*)name{
    FileSaver *file=[[FileSaver alloc]init];
    [file setDictionary:dictionary withKey:name];
}

@end
