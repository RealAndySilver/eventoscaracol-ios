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
#import "MyUtilities.h"
#import "UIImageView+WebCache.h"

@interface MapViewController ()
@property (strong, nonatomic) GMSMapView *mapView;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) UIPickerView *datePickerView;
@property (strong, nonatomic) UIPickerView *datePickerView2;
@property (strong, nonatomic) UIView *containerDatesPickerView;
@property (strong, nonatomic) UIView *containerDatesPickerView2;
@property (strong, nonatomic) UIButton *sortPlacesButton;
@property (strong, nonatomic) UIButton *sortPlacesButton2;
@property (nonatomic) BOOL isPickerActivated;
@property (nonatomic) BOOL isPicker2Activated;
@property (strong, nonatomic) NSString *selectedLocationID;
@property (strong, nonatomic) NSMutableArray *markers;
@property (strong, nonatomic) UIView *blockTouchesView;
@property (strong, nonatomic) UIButton *sideBarButton;

@property (strong, nonatomic) NSMutableArray *itemsOfPicker1Array;
@property (strong, nonatomic) NSMutableArray *itemsOfPicker2Array;
@property (strong, nonatomic) NSMutableArray *tempArray;



@end

@implementation MapViewController

#pragma mark - Lazy Instantiation 

-(NSMutableArray *)itemsOfPicker2Array {
    if (!_itemsOfPicker2Array) {
        _itemsOfPicker2Array = [[NSMutableArray alloc] init];
        if ([self.filter2ID isEqualToString:@"1"]) {
            _itemsOfPicker2Array = [self getDictionaryWithName:@"master"][@"locaciones"];
        } else {
            NSArray *categoriasHijoArray = [self getDictionaryWithName:@"master"][@"categorias_hijo"];
            for (int i = 0; i < [categoriasHijoArray count]; i++) {
                if ([categoriasHijoArray[i][@"categoryfather_id"] isEqualToString:self.filter2ID]) {
                    [_itemsOfPicker2Array addObject:categoriasHijoArray[i]];
                }
            }
        }
    }
    return _itemsOfPicker2Array;
}

-(NSMutableArray *)itemsOfPicker1Array {
    if (!_itemsOfPicker1Array) {
        _itemsOfPicker1Array = [[NSMutableArray alloc] init];
        if ([self.filter1ID isEqualToString:@"1"]) {
            _itemsOfPicker1Array = [self getDictionaryWithName:@"master"][@"locaciones"];
        } else {
            NSArray *categoriasHijoArray = [self getDictionaryWithName:@"master"][@"categorias_hijo"];
            for (int i = 0; i < [categoriasHijoArray count]; i++) {
                if ([categoriasHijoArray[i][@"categoryfather_id"] isEqualToString:self.filter1ID]) {
                    [_itemsOfPicker1Array addObject:categoriasHijoArray[i]];
                }
            }
        }
    }
    return _itemsOfPicker1Array;
}

#pragma mark - View Lifecycle

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.sideBarButton removeFromSuperview];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    //////////////////////////////////////////////////////
    //Create the back button of the NavigationBar. When pressed, this button
    //display the slide menu.
    self.sideBarButton = [[UIButton alloc] initWithFrame:CGRectMake(5.0, 9.0, 30.0, 30.0)];
    [self.sideBarButton addTarget:self action:@selector(showSideBarMenu:) forControlEvents:UIControlEventTouchUpInside];
    [self.sideBarButton setBackgroundImage:[UIImage imageNamed:@"SidebarIcon.png"] forState:UIControlStateNormal];
    [self.navigationController.navigationBar addSubview:self.sideBarButton];

}

-(void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tempArray = [self.locationsArray mutableCopy];
    
    self.revealViewController.delegate = self;
    self.blockTouchesView = [[UIView alloc] initWithFrame:self.view.frame];
    self.markers = [[NSMutableArray alloc] init];
    
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:39.0/255.0 green:178.0/255.0 blue:229.0/255.0 alpha:1.0];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor whiteColor]};
    
    [self createMap];
    [self createFilterButtons];
    [self createPickerView1];
    [self createPickerView2];
    
    /*UIBarButtonItem *slideMenuBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"SidebarIcon.png"]
                                                                               style:UIBarButtonItemStylePlain
                                                                              target:self.revealViewController
                                                                              action:@selector(revealToggle:)];
    self.navigationItem.leftBarButtonItem = slideMenuBarButtonItem;*/
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0,
                                                                    0.0,
                                                                    150.0,
                                                                    44.0)];
    titleLabel.text = self.navigationBarTitle;
    titleLabel.font = [UIFont fontWithName:@"Montserrat-Regular" size:17.0];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    self.navigationItem.titleView = titleLabel;
    //self.navigationItem.title = self.navigationBarTitle;
}

-(void)createPickerView1
{
    ////////////////////////////////////////////////////////////////////
    //Configure container view for the Dates picker.
    self.containerDatesPickerView = [[UIView alloc] initWithFrame:CGRectMake(0.0, self.view.frame.size.height, self.view.frame.size.width, 220.0)];
    self.containerDatesPickerView.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.6];
    
    /////////////////////////////////////////////////////////////////////
    //Configure datePickerView
    self.datePickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(0.0,
                                                                         0.0,
                                                                         self.containerDatesPickerView.frame.size.width,
                                                                         self.containerDatesPickerView.frame.size.height)];
    self.datePickerView.tag = 1;
    self.datePickerView.delegate = self;
    self.datePickerView.dataSource = self;
    [self.containerDatesPickerView addSubview:self.datePickerView];
    
    UIView *blueBarView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.containerDatesPickerView.frame.size.width, 44.0)];
    blueBarView.backgroundColor = [UIColor colorWithRed:249.0/255.0 green:170.0/255.0 blue:0.0 alpha:0.8];
    [self.containerDatesPickerView addSubview:blueBarView];
    
    ////////////////////////////////////////////////////////////////////////
    //Create a button to dismiss the location picker view.
    UIButton *dismissLocationPickerButton = [[UIButton alloc] initWithFrame:CGRectMake(self.containerDatesPickerView.frame.size.width - 44.0, 0.0, 44.0, 44.0)];
    dismissLocationPickerButton.tag = 1;
    dismissLocationPickerButton.backgroundColor = [UIColor clearColor];
    [dismissLocationPickerButton setTitle:@"OK" forState:UIControlStateNormal];
    dismissLocationPickerButton.titleLabel.font = [UIFont boldSystemFontOfSize:12.0];
    [dismissLocationPickerButton addTarget:self action:@selector(showPickerView:) forControlEvents:UIControlEventTouchUpInside];
    [self.containerDatesPickerView addSubview:dismissLocationPickerButton];
    [self.view addSubview:self.containerDatesPickerView];
}

-(void)createPickerView2
{
    ////////////////////////////////////////////////////////////////////
    //Configure container view for the Dates picker.
    self.containerDatesPickerView2 = [[UIView alloc] initWithFrame:CGRectMake(0.0, self.view.frame.size.height, self.view.frame.size.width, 220.0)];
    self.containerDatesPickerView2.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.6];
    
    /////////////////////////////////////////////////////////////////////
    //Configure datePickerView
    self.datePickerView2 = [[UIPickerView alloc] initWithFrame:CGRectMake(0.0,
                                                                         0.0,
                                                                         self.containerDatesPickerView2.frame.size.width,
                                                                         self.containerDatesPickerView2.frame.size.height)];
    self.datePickerView2.tag = 2;
    self.datePickerView2.delegate = self;
    self.datePickerView2.dataSource = self;
    [self.containerDatesPickerView2 addSubview:self.datePickerView2];
    
    UIView *blueBarView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.containerDatesPickerView2.frame.size.width, 44.0)];
    blueBarView.backgroundColor = [UIColor colorWithRed:249.0/255.0 green:170.0/255.0 blue:0.0 alpha:0.8];
    [self.containerDatesPickerView2 addSubview:blueBarView];
    
    ////////////////////////////////////////////////////////////////////////
    //Create a button to dismiss the location picker view.
    UIButton *dismissLocationPickerButton = [[UIButton alloc] initWithFrame:CGRectMake(self.containerDatesPickerView.frame.size.width - 44.0, 0.0, 44.0, 44.0)];
    dismissLocationPickerButton.tag = 2;
    dismissLocationPickerButton.backgroundColor = [UIColor clearColor];
    [dismissLocationPickerButton setTitle:@"OK" forState:UIControlStateNormal];
    dismissLocationPickerButton.titleLabel.font = [UIFont boldSystemFontOfSize:12.0];
    [dismissLocationPickerButton addTarget:self action:@selector(showPickerView:) forControlEvents:UIControlEventTouchUpInside];
    [self.containerDatesPickerView2 addSubview:dismissLocationPickerButton];
    [self.view addSubview:self.containerDatesPickerView2];
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
    
    GMSCameraPosition *camera = nil;
    if ([self.locationsArray count] > 0) {
        camera = [GMSCameraPosition cameraWithLatitude:[self.locationsArray[nearestLocationFromUserIndex][@"lat"] doubleValue]
                                    longitude:[self.locationsArray[nearestLocationFromUserIndex][@"lon"] doubleValue]
                                         zoom:12.0];

    }
    self.mapView = [GMSMapView mapWithFrame:CGRectMake(0.0,
                                                       0.0,
                                                       self.view.frame.size.width,
                                                       self.view.frame.size.height)
                                     camera:camera];
    //self.mapView.myLocationEnabled = YES;
    [self.view addSubview:self.mapView];
    [self createMarkers];
}
-(void)createMarkers{
    for (int i = 0; i < [self.locationsArray count]; i++)
    {
        NSLog(@"Entré a poner los marcadoresssss");
        double markerLatitute = [self.locationsArray[i][@"lat"] doubleValue];
        double markerLongitude = [self.locationsArray[i][@"lon"] doubleValue];
        GMSMarker *marker = [GMSMarker markerWithPosition:CLLocationCoordinate2DMake(markerLatitute, markerLongitude)];
        marker.title = self.locationsArray[i][@"name"];
        marker.snippet = self.locationsArray[i][@"short_detail"];
        marker.map = self.mapView;
        UIImageView *imageView = [[UIImageView alloc] init];
        NSLog(@"thumb url: %@", self.locationsArray[i][@"thumb_url"]);
        [imageView setImageWithURL:[NSURL URLWithString:self.locationsArray[i][@"thumb_url"]] completed:^(UIImage *image, NSError *error, SDImageCacheType imageChache){
            
            if (image) {
                dispatch_async(dispatch_get_main_queue(), ^(){
                    marker.icon = [MyUtilities imageWithName:image ScaleToSize:CGSizeMake(30.0, 30.0)];
                    //[self.markers addObject:marker];
                });
                
            } else {
                NSLog(@"no descargué ninguna imagen");
            }
        }];
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
    
    self.sortPlacesButton.tag = 1;
    [self.sortPlacesButton setBackgroundImage:[UIImage imageNamed:@"BotonTodosLosSitios.png"] forState:UIControlStateNormal];
    [self.sortPlacesButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    self.sortPlacesButton.titleLabel.font = [UIFont fontWithName:@"Helvetica" size:14.0];
    [self.sortPlacesButton setTitle:self.filter1Name forState:UIControlStateNormal];
    if ([self.filter1ID isEqualToString:@"2"]) {
        [self.sortPlacesButton addTarget:self action:@selector(goToListViewController) forControlEvents:UIControlEventTouchUpInside];
    } else {
        [self.sortPlacesButton addTarget:self action:@selector(showPickerView:) forControlEvents:UIControlEventTouchUpInside];
    }
    [self.view addSubview:self.sortPlacesButton];
    
    //button 2
    self.sortPlacesButton2 = [[UIButton alloc] initWithFrame:CGRectMake(self.view.frame.size.width/2 + self.view.frame.size.width/4 - 80.0,
                                                                        self.navigationController.navigationBar.frame.origin.y + self.navigationController.navigationBar.frame.size.height,
                                                                        160.0,
                                                                        44.0)];
    
    self.sortPlacesButton2.tag = 2;
    [self.sortPlacesButton2 setBackgroundImage:[UIImage imageNamed:@"BotonTodosLosSitios.png"] forState:UIControlStateNormal];
    [self.sortPlacesButton2 setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    self.sortPlacesButton2.titleLabel.font = [UIFont fontWithName:@"Helvetica" size:14.0];
    [self.sortPlacesButton2 setTitle:self.filter2Name forState:UIControlStateNormal];
    if ([self.filter2ID isEqualToString:@"2"]) {
        [self.sortPlacesButton2 addTarget:self action:@selector(goToListViewController) forControlEvents:UIControlEventTouchUpInside];
    } else {
        [self.sortPlacesButton2 addTarget:self action:@selector(showPickerView:) forControlEvents:UIControlEventTouchUpInside];
    }
    [self.view addSubview:self.sortPlacesButton2];

    
    /*UIButton *viewPlacesInListButton = [[UIButton alloc] initWithFrame:CGRectMake(self.view.frame.size.width/2 + self.view.frame.size.width/4 - 80.0,
                                                                                  self.navigationController.navigationBar.frame.origin.y + self.navigationController.navigationBar.frame.size.height,
                                                                                  160.0,
                                                                                  44.0)];
    [viewPlacesInListButton setBackgroundImage:[UIImage imageNamed:@"BotonTodosLosSitios.png"] forState:UIControlStateNormal];
    viewPlacesInListButton.titleLabel.font = [UIFont fontWithName:@"Helvetica" size:14.0];
    [viewPlacesInListButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    [viewPlacesInListButton setTitle:self.filter2Name forState:UIControlStateNormal];
    [viewPlacesInListButton addTarget:self action:@selector(goToListViewController) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:viewPlacesInListButton];*/
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

-(void)showSideBarMenu:(id)sender {
    [self.revealViewController revealToggle:sender];
}

-(void)showPickerView:(UIPickerView*)sender
{
    /*UIView *containerView = nil;
     if (sender.tag == 1)
     containerView = self.containerDatesPickerView;
     
     else if (sender.tag == 2)
     containerView = self.containerLocationPickerView;*/
    UIView *containerView = self.containerDatesPickerView;
    UIView *containerView2 = self.containerDatesPickerView2;
    BOOL picker1 = NO;
    BOOL picker2 = NO;
    if (sender.tag == 1)
        picker1 = YES;
    else if (sender.tag == 2)
        picker2 = YES;
    
    if (picker1 == YES) {
        if (!self.isPickerActivated) {
            [self.view addSubview:containerView];
            NSLog(@"me oprimi");
            [UIView animateWithDuration:0.3
                                  delay:0.0
                                options: UIViewAnimationOptionCurveEaseInOut
                             animations:^{
                                 
                                 //Bring up the corresponding container view.
                                 
                                 containerView.transform = CGAffineTransformMakeTranslation(0.0, -containerView.frame.size.height);
                                 
                             }
                             completion:^(BOOL finished){
                             }
             ];
            
            self.isPickerActivated = YES;
            
            if (self.isPicker2Activated)
            {
                [self.view addSubview:containerView2];
                NSLog(@"me oprimi");
                [UIView animateWithDuration:0.3
                                      delay:0.0
                                    options: UIViewAnimationOptionCurveEaseInOut
                                 animations:^{
                                     
                                     //Bring up the corresponding container view.
                                     
                                     containerView2.transform = CGAffineTransformMakeTranslation(0.0, containerView2.frame.size.height);
                                     
                                 }
                                 completion:^(BOOL finished){
                                 }
                 ];
                
                self.isPicker2Activated = NO;
            }
        }
        
        else {
            [self.view addSubview:containerView];
            NSLog(@"me oprimi");
            [UIView animateWithDuration:0.3
                                  delay:0.0
                                options: UIViewAnimationOptionCurveEaseInOut
                             animations:^{
                                 
                                 //Bring up the corresponding container view.
                                 
                                 containerView.transform = CGAffineTransformMakeTranslation(0.0, containerView.frame.size.height);
                                 
                             }
                             completion:^(BOOL finished){
                             }
             ];
            
            self.isPickerActivated = NO;
        }
    }
    
    else if (picker2 == YES) {
        if (!self.isPicker2Activated) {
            [self.view addSubview:containerView2];
            NSLog(@"me oprimi");
            [UIView animateWithDuration:0.3
                                  delay:0.0
                                options: UIViewAnimationOptionCurveEaseInOut
                             animations:^{
                                 
                                 //Bring up the corresponding container view.
                                 
                                 containerView2.transform = CGAffineTransformMakeTranslation(0.0, -containerView2.frame.size.height);
                                 
                             }
                             completion:^(BOOL finished){
                             }
             ];
            
            self.isPicker2Activated = YES;
            
            if (self.isPickerActivated) {
                [self.view addSubview:containerView];
                NSLog(@"me oprimi");
                [UIView animateWithDuration:0.3
                                      delay:0.0
                                    options: UIViewAnimationOptionCurveEaseInOut
                                 animations:^{
                                     
                                     //Bring up the corresponding container view.
                                     
                                     containerView.transform = CGAffineTransformMakeTranslation(0.0, containerView.frame.size.height);
                                     
                                 }
                                 completion:^(BOOL finished){
                                 }
                 ];
                
                self.isPickerActivated = NO;
            }
        }
        
        else {
            [self.view addSubview:containerView2];
            NSLog(@"me oprimi");
            [UIView animateWithDuration:0.3
                                  delay:0.0
                                options: UIViewAnimationOptionCurveEaseInOut
                             animations:^{
                                 
                                 //Bring up the corresponding container view.
                                 
                                 containerView2.transform = CGAffineTransformMakeTranslation(0.0, containerView2.frame.size.height);
                                 
                             }
                             completion:^(BOOL finished){
                             }
             ];
            
            self.isPicker2Activated = NO;
        }
    }
    /* //If pickerIsActivated = NO, create and animation to show the picker on screen.
     if (!self.isPickerActivated && !self.isPicker2Activated);
     {
     [self.view addSubview:containerView];
     NSLog(@"me oprimi");
     [UIView animateWithDuration:0.3
     delay:0.0
     options: UIViewAnimationOptionCurveEaseInOut
     animations:^{
     
     //Bring up the corresponding container view.
     
     containerView.transform = CGAffineTransformMakeTranslation(0.0, -containerView.frame.size.height);
     
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
     containerView.transform = CGAffineTransformMakeTranslation(0.0, containerView.frame.size.height);
     
     }
     completion:^(BOOL finished){
     [containerView removeFromSuperview];
     }
     
     ];
     
     self.isPickerActivated = NO;
     }*/
}

/*-(void)showPickerView:(UIPickerView*)sender
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
}*/

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
-(void)setNewPlacesUsingArray:(NSArray *)placesArray {
    //float finalCameraAnimationLatitude;
    //float finalCameraAnimationLongitude;
    
    [self.mapView clear];
    for (int i = 0; i < [placesArray count]; i++)
    {
        double markerLatitute = [placesArray[i][@"lat"] doubleValue];
        double markerLongitude = [placesArray[i][@"lon"] doubleValue];
        GMSMarker *marker = [GMSMarker markerWithPosition:CLLocationCoordinate2DMake(markerLatitute, markerLongitude)];
        marker.title = placesArray[i][@"name"];
        marker.snippet = placesArray[i][@"short_detail"];
        marker.map = self.mapView;
        
        UIImageView *imageView = [[UIImageView alloc] init];
        NSLog(@"thumb url: %@", placesArray[i][@"thumb_url"]);
        [imageView setImageWithURL:[NSURL URLWithString:placesArray[i][@"thumb_url"]] completed:^(UIImage *image, NSError *error, SDImageCacheType imageChache){
            if (image) {
                NSLog(@"si descargué la imagen");
                dispatch_async(dispatch_get_main_queue(), ^(){
                    marker.icon = [MyUtilities imageWithName:image ScaleToSize:CGSizeMake(30.0, 30.0)];
                    //[self.markers addObject:marker];
                });
                
            } else {
                NSLog(@"no descargué ninguna imagen");
            }
        }];
    }

}

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    /*if (row == 0)
    {
        [self.sortPlacesButton setTitle:self.filter1Name forState:UIControlStateNormal];
        self.selectedLocationID = @"All";
    }
    else
    {
        NSString *buttonTitle = [self getDictionaryWithName:@"master"][@"categorias"][row - 1][@"name"];
        [self.sortPlacesButton setTitle:buttonTitle forState:UIControlStateNormal];
        self.selectedLocationID = [self getDictionaryWithName:@"master"][@"categorias"][row - 1][@"_id"];
    }
    
    [self.mapView clear];
    [self setNewPlaces];*/
    if (pickerView.tag == 1) {
        if (row == 0) {
            [self setNewPlacesUsingArray:self.locationsArray];
        } else {
            NSDictionary *selectedSonCategoryDic = self.itemsOfPicker1Array[row - 1];
            NSString *sonCategoryID = selectedSonCategoryDic[@"_id"];
            NSLog(@"id del son category: %@", sonCategoryID);
            NSMutableArray *tempArray = [[NSMutableArray alloc] init];
            for (int i = 0; i < [self.locationsArray count]; i++) {
                NSDictionary *item = [NSDictionary dictionaryWithDictionary:self.locationsArray[i]];
                
                if ([self.filter1ID isEqualToString:@"1"]) {
                    if ([item[@"location_id"] isEqualToString:sonCategoryID]) {
                        [tempArray addObject:item];
                    }
                    
                } else {
                    NSArray *categoriesOfItemArray = [NSArray arrayWithArray:item[@"category_list"]];
                    for (int i = 0; i < [categoriesOfItemArray count]; i++) {
                        if ([categoriesOfItemArray[i][@"categoryson_id"] isEqualToString:sonCategoryID]) {
                            [tempArray addObject:item];
                        }
                    }
                }
            }
            self.tempArray = tempArray;
            [self setNewPlacesUsingArray:self.tempArray];
            //[self.tableView reloadData];
        }
    } else if (pickerView.tag == 2) {
        if (row == 0) {
            [self setNewPlacesUsingArray:self.locationsArray];
        } else {
            NSDictionary *selectedSonCategoryDic = self.itemsOfPicker2Array[row - 1];
            NSString *sonCategoryID = selectedSonCategoryDic[@"_id"];
            NSLog(@"id del son category: %@", sonCategoryID);
            NSMutableArray *tempArray = [[NSMutableArray alloc] init];
            for (int i = 0; i < [self.locationsArray count]; i++) {
                NSDictionary *item = [NSDictionary dictionaryWithDictionary:self.locationsArray[i]];
            
                if ([self.filter2ID isEqualToString:@"1"]) {
                    if ([item[@"location_id"] isEqualToString:sonCategoryID]) {
                        [tempArray addObject:item];
                    }
                    
                } else {
                    NSArray *categoriesOfItemArray = [NSArray arrayWithArray:item[@"category_list"]];
                    for (int i = 0; i < [categoriesOfItemArray count]; i++) {
                        if ([categoriesOfItemArray[i][@"categoryson_id"] isEqualToString:sonCategoryID]) {
                            [tempArray addObject:item];
                        }
                    }
                }
            }
            self.tempArray = tempArray;
            [self setNewPlacesUsingArray:self.tempArray];
            //[self.tableView reloadData];
        }
    }
}
-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    //return [[self getDictionaryWithName:@"master"][@"categorias"] count] + 1;
    if (pickerView.tag == 1) {
        return [self.itemsOfPicker1Array count] + 1;
    } else {
        return [self.itemsOfPicker2Array count] + 1;
    }
}

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    if (pickerView.tag == 1) {
        if (row == 0)
            return @"Todos";
        else {
            //return [self getDictionaryWithName:@"master"][@"categorias"][row - 1][@"name"];
            return self.itemsOfPicker1Array[row - 1][@"name"];
        }
    } else {
        if (row == 0) {
            return @"Todos";
        } else {
            return self.itemsOfPicker2Array[row -1][@"name"];
        }
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
