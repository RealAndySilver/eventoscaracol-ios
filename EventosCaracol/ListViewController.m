//
//  EventsListViewController.m
//  EventosCaracol
//
//  Created by Developer on 20/11/13.
//  Copyright (c) 2013 iAmStudio. All rights reserved.
//

#import "ListViewController.h"

@interface ListViewController ()
@property (strong, nonatomic)  UITableView *tableView;
@property (strong, nonatomic) UIPickerView *locationPickerView;
@property (strong, nonatomic) UIPickerView *datePickerView;
@property (strong, nonatomic) UIView *containerLocationPickerView;
@property (strong, nonatomic) UIView *containerDatesPickerView;
@property (strong, nonatomic) UIImageView *updateImageView;
@property (strong, nonatomic) UILabel *updateLabel;
@property (nonatomic) NSUInteger rowIndex; //Used for detecting which row we have to update
                                            //when the user favorites an item.
@property (nonatomic) BOOL isPickerActivated;
@property (nonatomic) BOOL isPicker2Activated;
@property (nonatomic) float offset;
@property (nonatomic) BOOL isUpdating;
@property (nonatomic) BOOL shouldUpdate;
@property (strong, nonatomic) UIActivityIndicatorView *spinner;
@property (strong, nonatomic) NSMutableArray *isFavoritedArray;
@property (nonatomic) NSUInteger favoriteIndex;
@property (strong, nonatomic) NSString *itemLocationName;
@property (strong, nonatomic) NSString *finalEventTime;
@property (strong, nonatomic) NSMutableArray *tempMenuArray;

/*------Filter Buttons-----------*/
@property (strong, nonatomic) UIButton *filterByDayButton;
@property (strong, nonatomic) UIButton *filterByLocationButton;

/*------text to share with the share button---------*/
@property (strong, nonatomic) NSString *textToShare;

/*---View to Block the touches when the side menu is open-----*/
@property (strong, nonatomic) UIView *blockTouchesView;

@property (strong, nonatomic) UIButton *sideBarButton;

/*------items to display in the pickers----------------------*/
@property (strong, nonatomic) NSMutableArray *itemsOfPicker1Arrray;
@property (strong, nonatomic) NSMutableArray *itemsOfPicker2Array;

@end

#define ROW_HEIGHT 95.0

@implementation ListViewController

#pragma mark - Lazy Instantiation 

-(NSMutableArray *)itemsOfPicker1Arrray {
    if (!_itemsOfPicker1Arrray) {
        _itemsOfPicker1Arrray = [[NSMutableArray alloc] init];
        
        if ([self.filter1ID isEqualToString:@"1"]) {
            _itemsOfPicker1Arrray = [self getDictionaryWithName:@"master"][@"locaciones"];
        } else {
            NSArray *categoriasHijoArray = [self getDictionaryWithName:@"master"][@"categorias_hijo"];
            for (int i = 0; i < [categoriasHijoArray count]; i++) {
                if ([categoriasHijoArray[i][@"categoryfather_id"] isEqualToString:self.filter1ID]) {
                    [_itemsOfPicker1Arrray addObject:categoriasHijoArray[i]];
                }
            }
        }
    }
    return _itemsOfPicker1Arrray;
}

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

#pragma mark - View LifeCycle

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    
    //We need to set this properties every time the view appears, because
    //there are more view controllers that change this properties.
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:249.0/255.0 green:170.0/255.0 blue:0.0 alpha:1.0];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor whiteColor]};
    
    //////////////////////////////////////////////////////
    //Create the back button of the NavigationBar. When pressed, this button
    //display the slide menu.
    if (!self.locationList) {
        self.sideBarButton = [[UIButton alloc] initWithFrame:CGRectMake(5.0, 9.0, 30.0, 30.0)];
        [self.sideBarButton addTarget:self action:@selector(showSideBarMenu:) forControlEvents:UIControlEventTouchUpInside];
        [self.sideBarButton setBackgroundImage:[UIImage imageNamed:@"SidebarIcon.png"] forState:UIControlStateNormal];
        [self.navigationController.navigationBar addSubview:self.sideBarButton];
    }
}

-(void)viewDidLoad
{
    [super viewDidLoad];
    self.revealViewController.delegate = self;
    self.blockTouchesView = [[UIView alloc] initWithFrame:self.view.frame];
    self.tempMenuArray = [NSMutableArray arrayWithArray:self.menuItemsArray];
    
    //Add this view controller as an observer of the notification center. it will
    //observe for a notification that is post when the user favorites an item in
    //the item detail view.
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateFavItemsWithNotification:)
                                                 name:@"FavItemNotification"
                                               object:nil];
    
    //Set an array for storing the favorite state of the items. if an item is not
    //favorite, it will store 0, otherwise it will store 1. We need to know this
    //state for displaying the correct heart image when the user swipes left in a cell.
    self.isFavoritedArray = [[NSMutableArray alloc] initWithCapacity:[self.tempMenuArray count]];
    
    if (!self.locationList)
    {
        /*UIBarButtonItem *slideMenuBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"SidebarIcon.png"]
                                                                                   style:UIBarButtonItemStylePlain
                                                                                  target:self.revealViewController
                                                                                  action:@selector(revealToggle:)];
        self.navigationItem.leftBarButtonItem = slideMenuBarButtonItem;*/
        [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    }
    
    //////////////////////////////////////////////////////////////////////////////////////////////
    //Configure the backBarButtonItem that will be displayed in the Navigation Bar when the user moves to EventDetailsViewController
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Atrás"
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:self
                                                                            action:nil];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0,
                                                                    0.0,
                                                                    150.0,
                                                                    44.0)];
    titleLabel.text = self.navigationBarTitle;
    titleLabel.font = [UIFont fontWithName:@"Montserrat-Regular" size:17.0];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.textColor = [UIColor colorWithRed:133.0/255.0 green:101.0/255.0 blue:0.0 alpha:1.0];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    self.navigationItem.titleView = titleLabel;
    //self.navigationItem.title = self.navigationBarTitle;
    
    ///////////////////////////////////////////////////////////////////
    //Create two buttons to filter the events list by date and by location
    //this buttons will not be displayed when the user is on the locations list.
    if (self.listWithGeneralTypeObjects)
        NSLog(@"YES");
    else
        NSLog(@"NO");
    NSLog(@"numero de filtros en la listaaaaa: %d", self.filtersNumber);
    if (!self.locationList && !self.listWithGeneralTypeObjects && self.filtersNumber != 0)
    {
        UIView *grayRectangle = [[UIView alloc] initWithFrame:CGRectMake(0.0,
                                                                         self.navigationController.navigationBar.frame.origin.y + self.navigationController.navigationBar.frame.size.height,
                                                                         self.view.frame.size.width,
                                                                         44.0)];
        grayRectangle.backgroundColor = [UIColor colorWithRed:230.0/255.0 green:230.0/255.0 blue:230.0/255.0 alpha:1.0];
        [self.view addSubview:grayRectangle];
        
        NSLog(@"Si creé los botones de filtrado");
        if (self.filter1Name) {
            self.filterByDayButton = [[UIButton alloc]
                                      initWithFrame:CGRectMake(self.view.frame.size.width/4 - 80.0,
                                                               self.navigationController.navigationBar.frame.origin.y + self.navigationController.navigationBar.frame.size.height,
                                                               160,
                                                               44.0)];
            
            //We need to set the button tag of filterByDayButton and filterByLocationButton to show the correct picker
            //when the user touches one of these buttons.
            self.filterByDayButton.tag = 1;
            
            [self.filterByDayButton addTarget:self action:@selector(showPickerView:) forControlEvents:UIControlEventTouchUpInside];
            [self.filterByDayButton setBackgroundImage:[UIImage imageNamed:@"BotonTodosLosSitios.png"] forState:UIControlStateNormal];
            [self.filterByDayButton setTitle:self.filter1Name forState:UIControlStateNormal];
            self.filterByDayButton.titleLabel.font = [UIFont fontWithName:@"Helvetica" size:14.0];
            [self.filterByDayButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
            [self.view addSubview:self.filterByDayButton];
        }
        
        if (self.filter2Name) {
            //Filter by location button
            self.filterByLocationButton = [[UIButton alloc]
                                           initWithFrame:CGRectMake(self.view.frame.size.width/2 + self.view.frame.size.width/4 - 80.0,
                                                                    self.navigationController.navigationBar.frame.origin.y + self.navigationController.navigationBar.frame.size.height,
                                                                    160,
                                                                    44.0)];
            self.filterByLocationButton.tag = 2;
            
            [self.filterByLocationButton addTarget:self action:@selector(showPickerView:) forControlEvents:UIControlEventTouchUpInside];
            [self.filterByLocationButton setBackgroundImage:[UIImage imageNamed:@"BotonTodosLosSitios.png"] forState:UIControlStateNormal];
            self.filterByLocationButton.titleLabel.font = [UIFont fontWithName:@"Helvetica" size:14.0];
            [self.filterByLocationButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
            [self.filterByLocationButton setTitle:self.filter2Name forState:UIControlStateNormal];
            [self.view addSubview:self.filterByLocationButton];
        }
        
        self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 108, self.view.frame.size.width, self.view.frame.size.height - 108.0) style:UITableViewStylePlain];
        [self.view addSubview:self.tableView];
    }
    
    else
    {
        NSLog(@"No creé los botones de filtrado");
        self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0,
                                                                       self.navigationController.navigationBar.frame.origin.y + self.navigationController.navigationBar.frame.size.height,
                                                                       self.view.frame.size.width,
                                                                       self.view.frame.size.height - ( self.navigationController.navigationBar.frame.origin.y + self.navigationController.navigationBar.frame.size.height))
                                                      style:UITableViewStylePlain];
        //self.tableView.contentInset = UIEdgeInsetsMake(64.0, 0.0, 0.0, 0.0);
        [self.view addSubview:self.tableView];
    }
    
    ///////////////////////////////////////////////////////////////////
    //Table View initialization and configuration
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
        if (!self.listWithGeneralTypeObjects) {
            self.tableView.rowHeight = ROW_HEIGHT;
        } else {
            self.tableView.rowHeight = 60.0;
        }
    else if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        self.tableView.rowHeight = 170.0;
    
    self.tableView.allowsSelection = YES;
    //self.tableView.separatorInset = UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0);
    [self setupPullDownToRefreshView];
    
    ////////////////////////////////////////////////////////////////////
    //Configure container view for the Location Picker
    self.containerLocationPickerView = [[UIView alloc] initWithFrame:CGRectMake(0.0, self.view.frame.size.height, self.view.frame.size.width, 220)];
    self.containerLocationPickerView.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.9];
    
    //////////////////////////////////////////////////////////////////
    //Configure container view for the Dates picker.
    self.containerDatesPickerView = [[UIView alloc] initWithFrame:CGRectMake(0.0, self.view.frame.size.height, self.view.frame.size.width, 220)];
    self.containerDatesPickerView.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.9];
    
    ///////////////////////////////////////////////////////////////////
    //Configure locationPickerView
    self.locationPickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(0.0,
                                                                             0.0,
                                                                             self.containerLocationPickerView.frame.size.width,
                                                                             self.containerLocationPickerView.frame.size.height)];
    self.locationPickerView.tag = 2;
    self.locationPickerView.backgroundColor = [UIColor clearColor];
    self.locationPickerView.delegate = self;
    self.locationPickerView.dataSource = self;
    
    /////////////////////////////////////////////////////////////////
    //Configure datePickerView
    self.datePickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(0.0,
                                                                         0.0,
                                                                         self.containerLocationPickerView.frame.size.width,
                                                                         self.containerLocationPickerView.frame.size.height)];
    self.datePickerView.tag = 1;
    self.datePickerView.delegate = self;
    self.datePickerView.dataSource = self;
    
    ////////////////////////////////////////////////////////////////
    [self.containerLocationPickerView addSubview:self.locationPickerView];
    [self.containerDatesPickerView addSubview:self.datePickerView];
    
    //BLue bar in top of the picker view
    UIView *blueBar = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.containerDatesPickerView.frame.size.width, 44.0)];
    blueBar.backgroundColor = [[UIColor colorWithRed:249.0/255.0 green:170.0/255.0 blue:0.0 alpha:1.0] colorWithAlphaComponent:0.8];
    [self.containerDatesPickerView addSubview:blueBar];
    
    UIView *blueBar2 = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.containerLocationPickerView.frame.size.width, 44.0)];
    blueBar2.backgroundColor = [[UIColor colorWithRed:249.0/255.0 green:170.0/255.0 blue:0.0 alpha:1.0] colorWithAlphaComponent:0.8];
    [self.containerLocationPickerView addSubview:blueBar2];
    
    /////////////////////////////////////////////////////////////////
    //Create a button to dismiss the location picker view.
    UIButton *dismissLocationPickerButton = [[UIButton alloc] initWithFrame:CGRectMake(self.containerLocationPickerView.frame.size.width - 40.0, 0.0, 44.0, 44.0)];
    dismissLocationPickerButton.tag = 2;
    dismissLocationPickerButton.backgroundColor = [UIColor clearColor];
    //[dismissLocationPickerButton setImage:[UIImage imageNamed:@"DismissPickerButtonImage.png"] forState:UIControlStateNormal];
    [dismissLocationPickerButton setTitle:@"OK" forState:UIControlStateNormal];
    dismissLocationPickerButton.titleLabel.font = [UIFont fontWithName:@"Montserrat-Regular" size:12.0];
    [dismissLocationPickerButton addTarget:self action:@selector(showPickerView:) forControlEvents:UIControlEventTouchUpInside];
    [self.containerLocationPickerView addSubview:dismissLocationPickerButton];
    
    /////////////////////////////////////////////////////////////////
    UIButton *dismissDatePickerButton = [[UIButton alloc] initWithFrame:CGRectMake(self.containerDatesPickerView.frame.size.width - 40.0, 0.0, 44.0, 44.0)];
    dismissDatePickerButton.tag = 1;
    //[dismissDatePickerButton setImage:[UIImage imageNamed:@"DismissPickerButtonImage.png"] forState:UIControlStateNormal];
    [dismissDatePickerButton setTitle:@"OK" forState:UIControlStateNormal];
    dismissDatePickerButton.titleLabel.font = [UIFont fontWithName:@"Montserrat-Regular" size:12.0];
    dismissDatePickerButton.backgroundColor = [UIColor clearColor];
    [dismissDatePickerButton addTarget:self action:@selector(showPickerView:) forControlEvents:UIControlEventTouchUpInside];
    [self.containerDatesPickerView addSubview:dismissDatePickerButton];
}

-(void)viewWillDisappear:(BOOL)animated
{
    //If any of the picker containers views is on view, remove it.
    if ([self.containerLocationPickerView isDescendantOfView:self.view])
    {
        NSLog(@"ContainerLocationPickerView estaba en self.view");
        [self.containerLocationPickerView removeFromSuperview];
    }
    
    if ([self.containerDatesPickerView isDescendantOfView:self.view])
    {
        NSLog(@"ContainerDatesPickerView estaba en self.view ");
        [self.containerDatesPickerView removeFromSuperview];
    }
    
    //We have to set isPickerActivated to NO, so when the user come back to this view and press any of the buttons to
    //show the picker, it will animate.
    self.isPickerActivated = NO;
    
    //Remove the slie menu button from the navigation bar
    [self.sideBarButton removeFromSuperview];
}

#pragma mark - UITableViewDelegate & UITableViewDataSource

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.tempMenuArray count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ///////////////////////////////////////////////////////////////////
    //Dequeue our custom cell SWTableViewCell
    static NSString *cellIdentifier=@"EventCell";
    SWTableViewCell *eventCell = (SWTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    //Array for storing our left and right buttons, which become visible when the user swipes in the cell.
    NSMutableArray *leftButtons = [[NSMutableArray alloc] init];
    
    //////////////////////////////////////////////////////////////////////////
    //Check if the cell's item is favorite or not.
    NSArray *favoriteItemsArray;
    if (self.locationList)
        favoriteItemsArray = [self getDictionaryWithName:@"user"][@"favorited_locations"];
    else
        favoriteItemsArray = [self getDictionaryWithName:@"user"][@"favorited_atoms"];
    
    UIImage *favoritedImage;
    UIImage *shareImage;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
        shareImage = [UIImage imageNamed:@"SwipCellShare.png"];
    else
        shareImage = [UIImage imageNamed:@"SwipCellShareiPad.png"];
    
    if ([favoriteItemsArray containsObject:self.tempMenuArray[indexPath.row][@"_id"]])
    {
        [self.isFavoritedArray addObject:@1];
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
            favoritedImage = [UIImage imageNamed:@"SwipCellFavoriteActive.png"];
        }
        else {
            favoritedImage = [UIImage imageNamed:@"SwipCellFavoriteActiveiPad.png"];
        }
    }
    
    else
    {
        [self.isFavoritedArray addObject:@0];
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
            favoritedImage = [UIImage imageNamed:@"SwipCellFavorite.png"];
        else
            favoritedImage = [UIImage imageNamed:@"SwipeCellFavoriteiPad.png"];
    }
    
    NSLog(@"%@", self.isFavoritedArray[indexPath.row]);
    
    if (![self.tempMenuArray[indexPath.row][@"type"] isEqualToString:@"general"])
    {
        [leftButtons sw_addUtilityButtonWithColor:[UIColor clearColor] icon:favoritedImage];
        [leftButtons sw_addUtilityButtonWithColor:[UIColor clearColor] icon:shareImage];
        
        eventCell = [[SWTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                           reuseIdentifier:cellIdentifier
                                       containingTableView:tableView
                                        leftUtilityButtons:leftButtons
                                       rightUtilityButtons:nil];
    }
    
    else
        eventCell = [[SWTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                           reuseIdentifier:cellIdentifier
                                       containingTableView:tableView
                                        leftUtilityButtons:nil
                                       rightUtilityButtons:nil];

    eventCell.delegate = self;
    
    if (!self.listWithGeneralTypeObjects)
    {
        /////////////////////////////////////////////////////////////////////
        //Create the subviews that will contain the cell.
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(10.0, 10.0, self.view.frame.size.width/3.2, tableView.rowHeight -  20.0)];
        imageView.clipsToBounds = YES;
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        imageView.backgroundColor = [UIColor clearColor];
        
        
        [imageView setImageWithURL:self.tempMenuArray[indexPath.row][@"thumb_url"] placeholderImage:[UIImage imageNamed:@"CaracolPrueba4.png"]];
        
        [eventCell.contentView addSubview:imageView];
        
        UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(imageView.frame.origin.x + imageView.frame.size.width + 10,
                                                                       0.0,
                                                                       self.view.frame.size.width - (imageView.frame.origin.x + imageView.frame.size.width + 10),
                                                                       40.0)];
        nameLabel.textAlignment = NSTextAlignmentLeft;
        nameLabel.numberOfLines = 2;
        nameLabel.text = self.tempMenuArray[indexPath.row][@"name"];
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
            nameLabel.font = [UIFont fontWithName:@"Montserrat-Regular" size:15.0];
        else if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
            nameLabel.font = [UIFont fontWithName:@"Montserrat-Regular" size:30.0];
        [eventCell.contentView addSubview:nameLabel];
        
        ///////////////////////////////////////////////////////////////////////////////
        //Get the item location name
        self.itemLocationName = [[NSString alloc] init];
        //First check if we are in a list of locations items. if not, search for the
        //location_id of the item to display it's location in the cell
        if (!self.locationList)
        {
            //First we see if the item has a location associated.
            if ([self.tempMenuArray[indexPath.row][@"location_id"] length] > 0)
            {
                //Location id exist.
                NSArray *locationsArray = [self getDictionaryWithName:@"master"][@"locaciones"];
                for (int i = 0; i < [locationsArray count]; i++)
                {
                    if ([self.tempMenuArray[indexPath.row][@"location_id"] isEqualToString:locationsArray[i][@"_id"]])
                    {
                        self.itemLocationName = locationsArray[i][@"name"];
                        break;
                    }
                }
            }
            
            else
            {
                self.itemLocationName = @"No hay locación asignada";
            }
        }
        
        //if we are in a list of location items, search for the short detail description
        //of the item to display it in the cell.
        else
        {
            self.itemLocationName = self.tempMenuArray[indexPath.row][@"short_detail"];
        }
        
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
        
        
        descriptionLabel.text = [NSString stringWithFormat:@"📍%@", self.itemLocationName];
        NSLog(@"locacion del item: %@", descriptionLabel.text);
        descriptionLabel.textColor = [UIColor lightGrayColor];
        [eventCell.contentView addSubview:descriptionLabel];
        
        /////////////////////////////////////////////////////////////////////////////////////
        //If we are not in the localist list view, display a label with the time of the event.
        //the location list view don't contain a label for this.
        //Esto hay que modificarlo para que solo me muestre el label de la fecha del evento cuando
        //el item es de tipo evento.!!!!!!!!!!!
        if (!self.locationList)
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
            if ([self.tempMenuArray[indexPath.row][@"type"] isEqualToString:@"eventos"])
            {
                self.finalEventTime = [self getFormattedItemDate:self.tempMenuArray[indexPath.row]];
                eventTimeLabel.text = [NSString stringWithFormat:@"🕑 %@", self.finalEventTime];
            }
            else
            {
                eventTimeLabel.text = [NSString stringWithFormat:@"📝 %@", self.tempMenuArray[indexPath.row][@"short_detail"]];
            }
            eventTimeLabel.textColor = [UIColor lightGrayColor];
            [eventCell.contentView addSubview:eventTimeLabel];
            
        }
    }
    
    else
    {
        CGFloat labelPositionY;
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
            labelPositionY = 0.0;
        else labelPositionY = 40.0;
        
        UILabel *generalTypeObjectLabel = [[UILabel alloc] initWithFrame:CGRectMake(30.0,
                                                                                    labelPositionY,
                                                                                    self.view.frame.size.width - 40.0,
                                                                                    60.0)];
        generalTypeObjectLabel.numberOfLines = 2;
        generalTypeObjectLabel.text = self.tempMenuArray[indexPath.row][@"name"];
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
            generalTypeObjectLabel.font = [UIFont fontWithName:@"Montserrat-Regular" size:15.0];
        else
            generalTypeObjectLabel.font = [UIFont fontWithName:@"Montserrat-Regular" size:30.0];
        
        eventCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        [eventCell.contentView addSubview:generalTypeObjectLabel];
    }
    
    return eventCell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"me tocaron");
    
    //If the item has an external url, we have to check if the url is going to open inside or
    //outside the application.
    if (self.tempMenuArray[indexPath.row][@"external_url"])
    {
        if ([self.tempMenuArray[indexPath.row][@"open_inside"] isEqualToString:@"no"])
        {
            if ([self.tempMenuArray[indexPath.row][@"type"] isEqualToString:@"general"])
            {
                GeneralInfoDetailViewController *generalInfoDetailVC = [self.storyboard instantiateViewControllerWithIdentifier:@"GeneralInfoDetail"];
                generalInfoDetailVC.mainTitle = self.tempMenuArray[indexPath.row][@"name"];
                generalInfoDetailVC.detailText = self.tempMenuArray[indexPath.row][@"detail"];
                [self.navigationController pushViewController:generalInfoDetailVC animated:YES];
                return;
            }
            
            DetailsViewController *detailsVC = [self.storyboard instantiateViewControllerWithIdentifier:@"EventDetails"];
            detailsVC.objectInfo = self.tempMenuArray[indexPath.row];
            detailsVC.objectLocation = [self getItemLocationName:self.tempMenuArray[indexPath.row]];
            if ([self.tempMenuArray[indexPath.row][@"type"]  isEqualToString:@"eventos"])
                detailsVC.objectTime = [self getFormattedItemDate:self.tempMenuArray[indexPath.row]];
            else
                detailsVC.objectTime = self.tempMenuArray[indexPath.row][@"short_detail"];
            //We have to check if the cell that the user touched contained a location type object. If so, the next view controller
            //will display a map on screen.
            if (self.locationList)
                detailsVC.presentLocationObject = YES;
            
            detailsVC.navigationBarTitle = self.tempMenuArray[indexPath.row][@"name"];
            [self.navigationController pushViewController:detailsVC animated:YES];
        }
        
        else if ([self.tempMenuArray[indexPath.row][@"open_inside"] isEqualToString:@"outside"])
        {
            NSURL *url = [NSURL URLWithString:self.tempMenuArray[indexPath.row][@"external_url"]];
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
            webViewController.urlString = self.tempMenuArray[indexPath.row][@"external_url"];
            [self.navigationController pushViewController:webViewController animated:YES];
        }
    }
    
    //if the item doesn't have an external url, open the detail view.
    else
    {
        DetailsViewController *detailsVC = [self.storyboard instantiateViewControllerWithIdentifier:@"EventDetails"];
        detailsVC.objectInfo = self.tempMenuArray[indexPath.row];
        detailsVC.objectLocation = [self getItemLocationName:self.tempMenuArray[indexPath.row]];
        
        if ([self.tempMenuArray[indexPath.row][@"type"]  isEqualToString:@"eventos"])
            detailsVC.objectTime = [self getFormattedItemDate:self.tempMenuArray[indexPath.row]];
        else
            detailsVC.objectTime = self.tempMenuArray[indexPath.row][@"short_detail"];        //We have to check if the cell that the user touched contained a location type object. If so, the next view controller
        //will display a map on screen.
        if (self.locationList)
            detailsVC.presentLocationObject = YES;
        
        detailsVC.navigationBarTitle = self.tempMenuArray[indexPath.row][@"name"];
        [self.navigationController pushViewController:detailsVC animated:YES];
    }
}

#pragma mark - Custom methods

-(void)showSideBarMenu:(id)sender {
    NSLog(@"me oprimiste vé");
    [self.revealViewController revealToggle:sender];
}

-(NSString *)getItemLocationName:(NSDictionary *)item
{
    NSString *itemLocationName = [[NSString alloc] init];
    //First we see if the item has a location associated.
    if (![item[@"type"] isEqualToString:@"locaciones"])
    {
        if ([item[@"location_id"] length] > 0)
        {
            //Location id exist.
            NSArray *locationsArray = [self getDictionaryWithName:@"master"][@"locaciones"];
            for (int i = 0; i < [locationsArray count]; i++)
            {
                if ([item[@"location_id"] isEqualToString:locationsArray[i][@"_id"]])
                {
                    itemLocationName = locationsArray[i][@"name"];
                    break;
                }
            }
        }
        
        else
        {
            itemLocationName = @"No hay locación asignada";
        }
        
        return itemLocationName;
    }
    
    else
        return item[@"short_detail"];
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

-(void)setupPullDownToRefreshView
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        self.updateImageView = [[UIImageView alloc] initWithFrame:CGRectMake(30.0, -40.0, 10.0, 20.0)];
        self.updateLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.view.frame.size.width/2 - 100.0, -45.0, 200.0, 30.0)];
        self.updateLabel.textColor = [UIColor lightGrayColor];
        self.updateLabel.font = [UIFont boldSystemFontOfSize:12.0];
    } else {
        self.updateImageView = [[UIImageView alloc] initWithFrame:CGRectMake(250.0, -40.0, 10.0, 20.0)];
        self.updateLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.view.frame.size.width/2 - 100.0, -45.0, 200.0, 30.0)];
        self.updateLabel.textColor = [UIColor lightGrayColor];
        self.updateLabel.font = [UIFont boldSystemFontOfSize:12.0];
    }
    self.updateImageView.image = [UIImage imageNamed:@"updateArrow.png"];
    [self.tableView addSubview:self.updateLabel];
    [self.tableView addSubview:self.updateImageView];
}

-(void)postLocalNotificationForItemAtIndex:(NSUInteger)index
{
    id appDelegate = [UIApplication sharedApplication].delegate;
    
    NSString *eventTime = self.tempMenuArray[index][@"event_time"];
    NSString *newString = [eventTime stringByReplacingOccurrencesOfString:@"T" withString:@" "];
    NSString *formattedEventTimeString = [newString stringByReplacingOccurrencesOfString:@".000Z" withString:@""];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    [dateFormatter setLocale:[NSLocale localeWithLocaleIdentifier:@"en_US"]];
    [dateFormatter setTimeZone:[NSTimeZone localTimeZone]];
    
    if (![dateFormatter dateFromString:formattedEventTimeString])
        NSLog(@"no lo formatée");
    else
    {
        ///////////////////////////////////////////////////////////////////////////
        NSDate *sourceDate = [dateFormatter dateFromString:formattedEventTimeString];

        NSTimeZone  *sourceTimeZone = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
        NSTimeZone  *destinationTimeZone = [NSTimeZone systemTimeZone];
            
        NSInteger sourceGMTOffset = [sourceTimeZone secondsFromGMTForDate:sourceDate];
        NSInteger destinationGMTOffset = [destinationTimeZone secondsFromGMTForDate:sourceDate];
        NSTimeInterval interval = destinationGMTOffset - sourceGMTOffset;
            
        NSDate *destinationDate = [[NSDate alloc] initWithTimeInterval:interval sinceDate:sourceDate];
            
        //We have to substract one hour from the event time because we want the reminder notification
        //to be post one hour earlier.
        NSDate *oneHourEarlierDate = [destinationDate dateByAddingTimeInterval:-(60*60)];
        NSLog(@"si pude formatear y cambiar al time zone adecuado: %@", [destinationDate descriptionWithLocale:[NSLocale currentLocale]]);
        NSLog(@"recordaré del evento a las : %@", [oneHourEarlierDate descriptionWithLocale:[NSLocale currentLocale]]);
        NSLog(@"Hour: %@", oneHourEarlierDate);
        NSLog(@"Actual hour: %@", [NSDate date]);
        
        if ([oneHourEarlierDate compare:[NSDate date]] == NSOrderedDescending)
        {
            UILocalNotification *localNotification = [[UILocalNotification alloc] init];
            localNotification.soundName = UILocalNotificationDefaultSoundName;
            localNotification.userInfo = @{@"name": self.tempMenuArray[index][@"_id"]};
            localNotification.alertBody = [NSString stringWithFormat:@"El evento '%@' es dentro de una hora, no te lo pierdas!", self.tempMenuArray[index][@"name"]];
            localNotification.fireDate = oneHourEarlierDate;
            NSLog(@"Fire Date: %@", [localNotification.fireDate descriptionWithLocale:[NSLocale currentLocale]]);
            localNotification.alertAction = @"Ver el evento";
            localNotification.timeZone = [NSTimeZone systemTimeZone];
            [appDelegate incrementBadgeNumberCounter];
            localNotification.applicationIconBadgeNumber = ((AppDelegate *)appDelegate).badgeNumberCounter;
            [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
            NSLog(@"postée la notificación");
            NSLog(@"BadgeNumber: %d", localNotification.applicationIconBadgeNumber);
        }
        
        else
        {
            NSLog(@"No posteé la notificación porque el evento ya pasó");
        }
    }
}

-(void)updateFavItemsWithNotification:(NSNotification *)notification
{
    [self.tableView reloadData];
}

-(void)makeFavoriteWithIndex:(NSUInteger)index
{
    self.favoriteIndex = index;
    
    //If the dictionary 'user' doesn't exist, we don't allow the user to favorite the items.
    //it's neccesary to log in facebook to fav items.
    if (![self getDictionaryWithName:@"user"][@"_id"])
    {
        [[[UIAlertView alloc] initWithTitle:nil
                                    message:@"¡Oops! Debes iniciar sesión con Facebook para poder asignar favoritos."
                                   delegate:self
                          cancelButtonTitle:@"Ok"
                          otherButtonTitles:@"Iniciar Sesión", nil] show];
        return;
    }
    self.rowIndex = index;
    
    //Create a string that contains the parameters to send to the server.
    NSString *params = [NSString stringWithFormat:@"item_id=%@&user_id=%@&type=%@&app_id=%@", self.tempMenuArray[index][@"_id"], [self getDictionaryWithName:@"user"][@"_id"], self.tempMenuArray[index][@"type"], [self getDictionaryWithName:@"master"][@"app"][@"_id"]];
    ServerCommunicator *serverCommunicator = [[ServerCommunicator alloc] init];
    serverCommunicator.delegate = self;
    
    if ([self.isFavoritedArray[index] intValue] == 0)
    {
        [self postLocalNotificationForItemAtIndex:index];
        [MBHUDView hudWithBody:nil type:MBAlertViewHUDTypeActivityIndicator hidesAfter:1000 show:YES];
        [serverCommunicator callServerWithPOSTMethod:@"FavItem" andParameter:params httpMethod:@"POST"];
    }
    
    /*[MBHUDView hudWithBody:nil type:MBAlertViewHUDTypeActivityIndicator hidesAfter:1000 show:YES];
    
    //Communicate asynchronously with the server
    dispatch_queue_t server = dispatch_queue_create("server", nil);
    dispatch_async(server, ^(){
        if ([self.isFavoritedArray[index] intValue] == 1)
        {
            [serverCommunicator callServerWithPOSTMethod:@"UnFavItem" andParameter:params httpMethod:@"POST"];
            self.isFavoritedArray[index] = @0;
            NSLog(@"me tengo que desfavoritear");
        }
        else
        {
            [serverCommunicator callServerWithPOSTMethod:@"FavItem" andParameter:params httpMethod:@"POST"];
            //self.isFavoritedArray[index] = @1;
            NSLog(@"me tengo que favoritear");
        }
    });*/
     
    NSLog(@"%@", params);
}

-(void)showFavoriteAnimationWithImage:(UIImage *)image
{
    [PopUpView showPopUpViewOverView:self.view image:image];
}

#pragma mark - SWTableViewDelegate

-(void)swippableTableViewCell:(SWTableViewCell *)cell scrollingToState:(SWCellState)state
{
    static int activeCell = 0;
    if (state == kCellStateRight || state == kCellStateLeft)
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

-(void)swippableTableViewCell:(SWTableViewCell *)cell didTriggerLeftUtilityButtonWithIndex:(NSInteger)index
{
    //If the user touches the favorite button of the cell.
    if (index == 0)
    {
        NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
        NSUInteger rowIndex = indexPath.row;
        [self makeFavoriteWithIndex:rowIndex];
    }
    
    //if the user touches the share button of the cell.
    else if (index == 1)
    {
        NSUInteger objectRow = [self.tableView indexPathForCell:cell].row;
        self.textToShare = self.tempMenuArray[objectRow][@"social_message"];
        /*self.textToShare = [self.tempMenuArray[objectRow][@"name"] stringByAppendingString:@" : "];
        self.textToShare = [self.textToShare stringByAppendingString:self.tempMenuArray[objectRow][@"short_detail"]];
        self.textToShare = [self.textToShare stringByAppendingString:@"\n Enviado desde la aplicación 'EuroCine 2014'"];*/
        [[[UIActionSheet alloc] initWithTitle:nil
                                    delegate:self
                           cancelButtonTitle:@"Volver"
                      destructiveButtonTitle:nil
                           otherButtonTitles:@"SMS", @"Facebook", @"Twitter", @"Correo" ,nil] showInView:self.view];
    }
}

-(void)swippableTableViewCell:(SWTableViewCell *)cell didTriggerRightUtilityButtonWithIndex:(NSInteger)index
{
    [PopUpView showPopUpViewOverView:self.view image:[UIImage imageNamed:@"BorrarRojo.png"]];
}

#pragma mark - UIActionSheetDelegate

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    //SMS button
    if(buttonIndex == 0)
    {
        NSLog(@"SMS");
        if (![MFMessageComposeViewController canSendText])
        {
            [[[UIAlertView alloc] initWithTitle:@"No se puede enviar SMS"
                                       message:@"Tu dispositivo no está configurado para enviar mensajes."
                                      delegate:self
                             cancelButtonTitle:@"Ok"
                              otherButtonTitles:nil] show];
        }
        
        else
        {
            MFMessageComposeViewController *messageViewController = [[MFMessageComposeViewController alloc] init];
            messageViewController.messageComposeDelegate = self;
            [messageViewController setBody:self.textToShare];
            [self presentViewController:messageViewController animated:YES completion:nil];
            NSLog(@"presenté el viewcontroller");
        }
    }
    
    //Facebook button
    else if (buttonIndex == 1)
    {
        NSLog(@"Facebook");
       
        SLComposeViewController *facebookViewController = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
        [facebookViewController setInitialText:self.textToShare];
        [self presentViewController:facebookViewController animated:YES completion:nil];
    }
    
    //Twitter button
    else if (buttonIndex == 2)
    {
        NSLog(@"Twitter");
    
        SLComposeViewController *twitterViewController = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
        [twitterViewController setInitialText:self.textToShare];
        [self presentViewController:twitterViewController animated:YES completion:nil];
    }
    
    //Email button
    else if (buttonIndex == 3)
    {
        NSLog(@"Mail");
        MFMailComposeViewController *mailComposeViewController = [[MFMailComposeViewController alloc] init];
        [mailComposeViewController setSubject:@"¡EuroCine 2014!"];
        [mailComposeViewController setMessageBody:self.textToShare isHTML:NO];
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
            mailComposeViewController.modalPresentationStyle = UIModalPresentationFormSheet;
        mailComposeViewController.mailComposeDelegate = self;
        [self presentViewController:mailComposeViewController animated:YES completion:nil];
    }
}

#pragma mark - MFMailComposeDelegate

-(void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - MFMessageComposeViewControllerDelegate

-(void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UIPickerViewDelegate & UIPickerViewDataSource

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    if (pickerView.tag == 1)
    {
        if (row == 0)
        {
            self.tempMenuArray = self.menuItemsArray;
            [self.filterByDayButton setTitle:self.filter1Name forState:UIControlStateNormal];
            [self.tableView reloadData];
        }
        
        else
        {
            /*NSDictionary *selectedCategory = [self getDictionaryWithName:@"master"][@"categorias"][row - 1];
            NSString *categoryID = selectedCategory[@"_id"];
            [self.filterByDayButton setTitle:selectedCategory[@"name"] forState:UIControlStateNormal];
            NSLog(@"Category id: %@", categoryID);
            NSMutableArray *tempArray = [[NSMutableArray alloc] init];
            for (int i = 0; i < [self.menuItemsArray count]; i++)
            {
                if ([self.menuItemsArray[i][@"category_id"] isEqualToString:categoryID])
                    [tempArray addObject:self.menuItemsArray[i]];
            }
            //[self.menuItemsArray removeAllObjects];
            self.tempMenuArray = tempArray;
            NSLog(@"number of items: %d", [self.tempMenuArray count]);
            
            [self.tableView reloadData];*/
            NSDictionary *selectedSonCategoryDic = self.itemsOfPicker1Arrray[row - 1];
            NSString *sonCategoryID = selectedSonCategoryDic[@"_id"];
            NSLog(@"id del son category: %@", sonCategoryID);
            NSMutableArray *tempArray = [[NSMutableArray alloc] init];
            for (int i = 0; i < [self.menuItemsArray count]; i++) {
                NSDictionary *item = [NSDictionary dictionaryWithDictionary:self.menuItemsArray[i]];
                
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
            self.tempMenuArray = tempArray;
            [self.tableView reloadData];
        }
    }
    
    if (pickerView.tag == 2)
    {
        if (row == 0)
        {
            self.tempMenuArray = self.menuItemsArray;
            [self.filterByLocationButton setTitle:self.filter2Name forState:UIControlStateNormal];
            [self.tableView reloadData];
        }
        
        else
        {
            /*NSDictionary *selectedLocation = [self getDictionaryWithName:@"master"][@"locaciones"][row - 1];
            NSString *locationID = selectedLocation[@"_id"];
            [self.filterByLocationButton setTitle:selectedLocation[@"name"] forState:UIControlStateNormal];
            NSLog(@"location id: %@", locationID);
            NSMutableArray *tempArray = [[NSMutableArray alloc] init];
            for (int i = 0; i < [self.menuItemsArray count]; i++)
            {
                if ([self.menuItemsArray[i][@"location_id"] isEqualToString:locationID])
                    [tempArray addObject:self.menuItemsArray[i]];
            }
            //[self.menuItemsArray removeAllObjects];
            self.tempMenuArray = tempArray;
            NSLog(@"number of items: %d", [self.tempMenuArray count]);
            
            [self.tableView reloadData];*/
            
            NSDictionary *selectedSonCategoryDic = self.itemsOfPicker2Array[row - 1];
            NSString *sonCategoryID = selectedSonCategoryDic[@"_id"];
            NSLog(@"id del item: %@", sonCategoryID);
            NSMutableArray *tempArray = [[NSMutableArray alloc] init];
            for (int i = 0; i < [self.menuItemsArray count]; i++) {
                NSDictionary *item = self.menuItemsArray[i];
                
                if ([self.filter2ID isEqualToString:@"1"]) {
                    if ([item[@"location_id"] isEqualToString:sonCategoryID]) {
                        [tempArray addObject:item];
                    }
                    
                } else {
                    NSArray *categoriesOfItemArray = item[@"category_list"];
                    if (categoriesOfItemArray) {
                        for (int i = 0; i < [categoriesOfItemArray count]; i++) {
                            if ([categoriesOfItemArray[i][@"categoryson_id"] isEqualToString:sonCategoryID]) {
                                [tempArray addObject:item];
                            }
                        }
                    }
                }
            }
            self.tempMenuArray = tempArray;
            [self.tableView reloadData];
        }
    }
}

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if (pickerView.tag == 1)
    {
        return [self.itemsOfPicker1Arrray count] + 1;
    }
    
    else if (pickerView.tag == 2)
    {
        return [self.itemsOfPicker2Array count] + 1;
    }
    
    else return 0;
}

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    if (pickerView.tag == 1)
    {
        if (row == 0)
            return @"Todos";
        else {
            return self.itemsOfPicker1Arrray[row - 1][@"name"];
        }
    }
    
    else if (pickerView.tag == 2)
    {
        if (row == 0)
            return @"Todos";
        else {
            return self.itemsOfPicker2Array[row - 1][@"name"];
        }
    }
    
    else
        return nil;
}

#pragma mark - Actions

-(void)showPickerView:(UIPickerView*)sender
{
    /*UIView *containerView = nil;
    if (sender.tag == 1)
        containerView = self.containerDatesPickerView;
    
    else if (sender.tag == 2)
        containerView = self.containerLocationPickerView;*/
    UIView *containerView = self.containerDatesPickerView;
    UIView *containerView2 = self.containerLocationPickerView;
    BOOL picker1;
    BOOL picker2;
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

#pragma mark - UIScrollViewDelegate

-(void)scrollViewDidScroll:(UIScrollView *)sender {
    
    self.offset = self.tableView.contentOffset.y;
    self.offset *= -1;
    if (self.offset > 0 && self.offset < 60) {
         if(!self.isUpdating)
         self.updateLabel.text = @"Desliza hacia abajo para actualizar...";
        
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationBeginsFromCurrentState:YES];
        [UIView setAnimationDuration:0.2];
        self.updateImageView.transform = CGAffineTransformMakeRotation(0);
        [UIView commitAnimations];
        self.shouldUpdate = NO;
    }
    if (self.offset >= 60) {
         if(!self.isUpdating)
         self.updateLabel.text = @"Suelta para actualizar...";
        
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationBeginsFromCurrentState:YES];
        [UIView setAnimationDuration:0.2];
        self.updateImageView.transform = CGAffineTransformMakeRotation(M_PI);
        [UIView commitAnimations];
        self.shouldUpdate = YES;
    }
    if (self.isUpdating)
    {
        self.shouldUpdate = NO;
    }
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
{
    if (self.shouldUpdate)
    {
        [self updateMethod];
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.2];
        self.tableView.contentInset = UIEdgeInsetsMake(60, 0, 0, 0);
        [UIView commitAnimations];
    }
}

#pragma mark - UIAlertViewDelegate

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1)
    {
        LoginViewController *loginVC = [self.storyboard instantiateViewControllerWithIdentifier:@"Login"];
        loginVC.loginWasPresentedFromFavoriteButtonAlert = YES;
        [self presentViewController:loginVC animated:YES completion:nil];
    }
}

#pragma mark - Pull Down To Refresh methods

- (void) updateMethod
{
    self.spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.spinner.center = self.updateImageView.center;
    self.updateImageView.hidden = YES;
    [self.spinner startAnimating];
    [self.tableView addSubview:self.spinner];
    self.updateLabel.text = @"Actualizando...";
    self.isUpdating = YES;
    
    id appDelegate = [UIApplication sharedApplication].delegate;
    [appDelegate incrementNetworkActivity];
    
    [self getAllInfoFromServer];
}

-(void) finishUpdateMethod
{
    [self stopSpinner];
    [self.tableView reloadData];
    //[self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationBottom];
}

- (void) stopSpinner
{
    [self.spinner stopAnimating];
    [self.spinner removeFromSuperview];
    self.updateImageView.hidden = NO;
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.2];
    self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
    [UIView commitAnimations];
    self.isUpdating = NO;
}

-(void)updateDataFromServer
{
    NSArray *tempArray = [self getDictionaryWithName:@"master"][self.objectType];
    NSMutableArray *tempMutableArray = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < [tempArray count]; i++)
    {
        if ([tempArray[i][@"menu_item_id"] isEqualToString:self.menuID])
            [tempMutableArray addObject:tempArray[i]];
    }
    
    self.tempMenuArray = tempMutableArray;
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

#pragma mark - Server

-(void)getAllInfoFromServer
{
    ServerCommunicator *server = [[ServerCommunicator alloc]init];
    server.delegate = self;
    [server callServerWithGETMethod:@"GetAllInfoWithAppID" andParameter:[[self getDictionaryWithName:@"app_id"] objectForKey:@"app_id"]];
    /*//Load the info from the server asynchronously
    dispatch_queue_t infoLoader = dispatch_queue_create("InfoLoader", nil);
    dispatch_async(infoLoader, ^(){
    });*/
}

-(void)receivedDataFromServer:(NSDictionary *)dictionary withMethodName:(NSString *)methodName
{
    id appDelegate = [UIApplication sharedApplication].delegate;
    [appDelegate decrementNetworkActivity];
    [MBHUDView dismissCurrentHUD];
    
    if ([methodName isEqualToString:@"FavItem"] || [methodName isEqualToString:@"UnFavItem"])
    {
        if ([dictionary[@"status"] boolValue])
        {
            NSLog(@"%@", dictionary);
            NSLog(@"Llego la informacion de los favoritos");
            [self setDictionary:dictionary[@"user"] withName:@"user"];
            
            if ([methodName isEqualToString:@"UnFavItem"])
                self.isFavoritedArray[self.favoriteIndex] = @0;
            else
                self.isFavoritedArray[self.favoriteIndex] = @1;
            
            [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:self.rowIndex inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
            [self.isFavoritedArray[self.favoriteIndex] intValue] ==  1 ? [self showFavoriteAnimationWithImage:nil] : [self showFavoriteAnimationWithImage:[UIImage imageNamed:@"BorrarRojo.png"]];
            NSLog(@"se pudo favoritear correctamente desde el listado");
        }
    }
    
    else if ([methodName isEqualToString:@"GetAllInfoWithAppID"])
    {
        NSLog(@"llego información del servidor");
        if ([dictionary objectForKey:@"app"])
        {
            [self setDictionary:dictionary withName:@"master"];
            [self updateDataFromServer];
            [self finishUpdateMethod];
            NSLog(@"Me actualizé");
        }
            
        else
        {
            //no puede pasar
        }
    }
}

-(void)serverError:(NSError *)error
{
    id appDelegate = [UIApplication sharedApplication].delegate;
    [appDelegate decrementNetworkActivity];
    [self stopSpinner];
    [MBHUDView dismissCurrentHUD];
    
    [[[UIAlertView alloc] initWithTitle:nil
                               message:@"No hay conexión a internet. Por favor revisa que tu dispositivo esté conectado a internet."
                              delegate:self
                     cancelButtonTitle:@"Ok"
                     otherButtonTitles:nil] show];
}

-(NSDictionary*)getDictionaryWithName:(NSString*)name{
    FileSaver *file=[[FileSaver alloc]init];
    return [file getDictionary:name];
}
-(void)setDictionary:(NSDictionary*)dictionary withName:(NSString*)name{
    FileSaver *file=[[FileSaver alloc]init];
    [file setDictionary:dictionary withKey:name];
}

@end
