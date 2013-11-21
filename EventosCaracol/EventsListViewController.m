//
//  EventsListViewController.m
//  EventosCaracol
//
//  Created by Developer on 20/11/13.
//  Copyright (c) 2013 iAmStudio. All rights reserved.
//

#import <Social/Social.h>
#import <MessageUI/MessageUI.h>
#import "EventsListViewController.h"
#import "EventDetailsViewController.h"
#import "SWTableViewCell.h"
#import "Atom.h"

@interface EventsListViewController () <UITableViewDataSource, UITableViewDelegate, SWTableViewCellDelegate, UIActionSheetDelegate, MFMailComposeViewControllerDelegate, MFMessageComposeViewControllerDelegate, UIPickerViewDataSource, UIPickerViewDelegate>{
}
@property (strong, nonatomic)  UITableView *tableView;
@property (strong, nonatomic) NSArray *eventsNamesTestArray; //Of NSString
@property (strong, nonatomic) NSArray *eventsLocationsTestArray; //Of NSString
@property (strong, nonatomic) NSArray *eventDatesArray; //Of NSString
@property (strong, nonatomic) UIPickerView *locationPickerView;
@property (strong, nonatomic) UIPickerView *datePickerView;
@property (strong, nonatomic) UIView *containerLocationPickerView;
@property (strong, nonatomic) UIView *containerDatesPickerView;
@property (nonatomic) BOOL isPickerActivated;
@end

#define ROW_HEIGHT 90.0

@implementation EventsListViewController

//This Arrays are for test purposes only!!!
//Lazy Instantiation
-(NSArray *)eventDatesArray
{
    if (!_eventDatesArray)
        _eventDatesArray = @[@"Todos los dias", @"Lunes", @"Martes", @"Miercoles", @"Jueves", @"Viernes", @"Sabado", @"Domingo"];
    
    return _eventDatesArray;
}

-(NSArray *)eventsNamesTestArray
{
    if (!_eventsNamesTestArray)
        _eventsNamesTestArray = @[@"Desfile de las flores", @"Desfile de tulipanes", @"desfile de rosas", @"desfile de petunias", @"Fiesta al  parque"];
    
    return _eventsNamesTestArray;
}

-(NSArray *)eventsLocationsTestArray
{
    if (!_eventsLocationsTestArray)
        _eventsLocationsTestArray = @[@"Todos los lugares", @"Lugar1", @"Lugar2", @"Lugar3", @"Lugar4", @"Lugar5"];
    return _eventsLocationsTestArray;
}

#pragma mark - View LifeCycle

-(void)viewDidLoad
{
    [super viewDidLoad];
    
    //Configure the backBarButtonItem that will be displayed in the Navigation Bar when the user moves to EventDetailsViewController
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Volver"
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:self
                                                                            action:nil];
    self.navigationItem.title = @"Programación";
    
    ///////////////////////////////////////////////////////////////////
    //Create two buttons to filter the events list by date and by location
    //Filter by date button
    UIButton *filterByDayButton = [[UIButton alloc]
                                   initWithFrame:CGRectMake(0,
                                                            self.navigationController.navigationBar.frame.origin.y + self.navigationController.navigationBar.frame.size.height,
                                                            self.view.frame.size.width/2,
                                                            44.0)];
    
    //We need to set the button tag of filterByDayButton and filterByLocationButton to show the correct picker
    //when the user touches one of these buttons.
    filterByDayButton.tag = 1;
    
    [filterByDayButton addTarget:self action:@selector(showPickerView:) forControlEvents:UIControlEventTouchUpInside];
    [filterByDayButton setTitle:@"Todos los dias" forState:UIControlStateNormal];
    filterByDayButton.titleLabel.font = [UIFont fontWithName:@"Helvetica" size:14.0];
    filterByDayButton.backgroundColor = [UIColor cyanColor];
    [self.view addSubview:filterByDayButton];
    
    //Filter by location button
    UIButton *filterByLocationButton = [[UIButton alloc]
                                        initWithFrame:CGRectMake(self.view.frame.size.width/2,
                                                                 self.navigationController.navigationBar.frame.origin.y + self.navigationController.navigationBar.frame.size.height,
                                                                 self.view.frame.size.width/2,
                                                                 44.0)];
    filterByLocationButton.tag = 2;
    
    [filterByLocationButton addTarget:self action:@selector(showPickerView:) forControlEvents:UIControlEventTouchUpInside];
    filterByLocationButton.backgroundColor = [UIColor cyanColor];
    filterByLocationButton.titleLabel.font = [UIFont fontWithName:@"Helvetica" size:14.0];
    [filterByLocationButton setTitle:@"Todos los lugares" forState:UIControlStateNormal];
    [self.view addSubview:filterByLocationButton];
    
    ///////////////////////////////////////////////////////////////////
    //Table View initialization and configuration
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, filterByLocationButton.frame.origin.y + filterByLocationButton.frame.size.height, self.view.frame.size.width, self.view.frame.size.height) style:UITableViewStylePlain];
    [self.view addSubview:_tableView];
    
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.rowHeight = ROW_HEIGHT;
    self.tableView.allowsSelection = YES;
    self.tableView.separatorInset = UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0);
    
    ///////////////////////////////////////////////////////////////////
    //Configure locationPickerView
    self.locationPickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(0.0,
                                                                             0.0,
                                                                             self.containerLocationPickerView.frame.size.width,
                                                                             self.containerLocationPickerView.frame.size.height)];
    self.locationPickerView.tag = 2;
    self.locationPickerView.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:1.0];
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
    
    ////////////////////////////////////////////////////////////////////
    //Configure container view for the Location Picker
    self.containerLocationPickerView = [[UIView alloc] initWithFrame:CGRectMake(0.0, self.view.frame.size.height, self.view.frame.size.width, self.view.frame.size.height/2.5)];
    self.containerLocationPickerView.backgroundColor = [UIColor whiteColor];
    [self.containerLocationPickerView addSubview:self.locationPickerView];
    
    //////////////////////////////////////////////////////////////////
    //Configure container view for the Dates picker.
    self.containerDatesPickerView = [[UIView alloc] initWithFrame:CGRectMake(0.0, self.view.frame.size.height, self.view.frame.size.width, self.view.frame.size.height/2.5)];
    self.containerDatesPickerView.backgroundColor = [UIColor whiteColor];
    [self.containerDatesPickerView addSubview:self.datePickerView];

    
    /////////////////////////////////////////////////////////////////
    //Create a button to dismiss the location picker view.
    UIButton *dismissLocationPickerButton = [[UIButton alloc] initWithFrame:CGRectMake(self.containerLocationPickerView.frame.size.width - 40.0, self.containerLocationPickerView.frame.size.height - 40.0, 40.0, 40.0)];
    dismissLocationPickerButton.tag = 2;
    dismissLocationPickerButton.backgroundColor = [UIColor purpleColor];
    [dismissLocationPickerButton addTarget:self action:@selector(showPickerView:) forControlEvents:UIControlEventTouchUpInside];
    [self.containerLocationPickerView addSubview:dismissLocationPickerButton];
    
    /////////////////////////////////////////////////////////////////
    UIButton *dismissDatePickerButton = [[UIButton alloc] initWithFrame:CGRectMake(self.containerDatesPickerView.frame.size.width - 40.0,self.containerDatesPickerView.frame.size.height - 40.0, 40.0, 40.0)];
    dismissDatePickerButton.tag = 1;
    dismissDatePickerButton.backgroundColor = [UIColor purpleColor];
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
}

#pragma mark - UITableViewDelegate & UITableViewDataSource

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 5;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SWTableViewCell *eventCell = (SWTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"EventCell"];
    
    if (!eventCell)
    {
        //Array for storing our left and right buttons, which become visible when the user swipes in the cell.
        NSMutableArray *leftButtons = [[NSMutableArray alloc] init];
        NSMutableArray *rightButtons = [[NSMutableArray alloc] init];
        
        [leftButtons sw_addUtilityButtonWithColor:[UIColor orangeColor] title:@"Fav"];
        [leftButtons sw_addUtilityButtonWithColor:[UIColor cyanColor] title:@"Share"];
        
        [rightButtons sw_addUtilityButtonWithColor:[UIColor redColor] title:@"Borrar"];
        
        eventCell = [[SWTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                           reuseIdentifier:@"EventCell"
                                       containingTableView:tableView
                                        leftUtilityButtons:leftButtons
                                       rightUtilityButtons:rightButtons];
        
        eventCell.delegate = self;
    }
    
    //Create the subviews that will contain the cell.
    UIImageView *eventImage = [[UIImageView alloc] initWithFrame:CGRectMake(10.0, 10.0, 70.0, 70.0)];
    eventImage.backgroundColor = [UIColor cyanColor];
    [eventCell.contentView addSubview:eventImage];
    
    UILabel *eventNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(100.0, 20.0, 150, 20.0)];
    eventNameLabel.text = self.eventsNamesTestArray[indexPath.row];
    eventNameLabel.font = [UIFont fontWithName:@"Helvetica" size:15.0];
    [eventCell.contentView addSubview:eventNameLabel];
    
    UILabel *eventLocationLabel = [[UILabel alloc] initWithFrame:CGRectMake(100.0, 50.0, 100.0, 20.0)];
    eventLocationLabel.text = @"Plaza roja";
    eventLocationLabel.font = [UIFont fontWithName:@"Helvetica" size:12.0];
    [eventCell.contentView addSubview:eventLocationLabel];
    
    UILabel *eventTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(210.0, 50.0, 100.0, 20.0)];
    eventTimeLabel.text = @"10:00AM";
    eventTimeLabel.font = [UIFont fontWithName:@"Helvetica" size:12.0];
    [eventCell.contentView addSubview:eventTimeLabel];
    
    return eventCell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    EventDetailsViewController *eventDetailsVC = [self.storyboard instantiateViewControllerWithIdentifier:@"EventDetails"];
    [self.navigationController pushViewController:eventDetailsVC animated:YES];
}

#pragma mark - SWTableViewDelegate

-(void)swippableTableViewCell:(SWTableViewCell *)cell didTriggerLeftUtilityButtonWithIndex:(NSInteger)index
{
    if (index == 1)
    {
        [[[UIActionSheet alloc] initWithTitle:@""
                                    delegate:self
                           cancelButtonTitle:@"Volver"
                      destructiveButtonTitle:nil
                           otherButtonTitles:@"SMS", @"Facebook", @"Twitter", @"Correo" ,nil] showInView:self.view];
    }
}

#pragma mark - UIActionSheetDelegate

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSLog(@"%d",buttonIndex);

    if(buttonIndex == 0)
    {
        NSLog(@"SMS");
        if (![MFMessageComposeViewController canSendText])
        {
            NSLog(@"No se pueden enviar mensajes");
        }
        
        else
        {
            MFMessageComposeViewController *messageViewController = [[MFMessageComposeViewController alloc] init];
            messageViewController.messageComposeDelegate = self;
            [messageViewController setBody:@"Hola! te recomiendo este evento!"];
            [self presentViewController:messageViewController animated:YES completion:nil];
            NSLog(@"presenté el viewcontroller");
        }
    }
    
    else if (buttonIndex == 1)
    {
        NSLog(@"Facebook");
       
        SLComposeViewController *facebookViewController = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
        [facebookViewController setInitialText:@"Me acabo de inscribir al evento que vamos a ir todos."];
        [self presentViewController:facebookViewController animated:YES completion:nil];
    }
    
    else if (buttonIndex == 2)
    {
        NSLog(@"Twitter");
    
        SLComposeViewController *twitterViewController = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
        [twitterViewController setInitialText:@"Me acbo de inscribir a este genial evento"];
        [self presentViewController:twitterViewController animated:YES completion:nil];
    }
    
    else if (buttonIndex == 3)
    {
        NSLog(@"Mail");
        MFMailComposeViewController *mailComposeViewController = [[MFMailComposeViewController alloc] init];
        [mailComposeViewController setSubject:@"Te recomiendo este evento!"];
        [mailComposeViewController setMessageBody:@"¡Hola!, me acabo de inscribir en la presentación del evento al que todos vamos a ir. " isHTML:NO];
        
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
    
}

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if (pickerView.tag == 1)
        return [self.eventDatesArray count];
    
    else if (pickerView.tag == 2)
        return 5;
    
    else return 0;
}

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    if (pickerView.tag == 1)
        return self.eventDatesArray[row];
    
    else if (pickerView.tag == 2)
        return self.eventsLocationsTestArray[row];
    else
        return nil;
}

#pragma mark - Actions

-(void)showPickerView:(id)sender
{
    UIView *containerView = nil;
    if ([sender tag] == 1)
        containerView = self.containerDatesPickerView;
    
    else if ([sender tag] == 2)
        containerView = self.containerLocationPickerView;
        
    //If pickerIsActivated = NO, create and animation to show the picker on screen.
    if (!self.isPickerActivated)
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

    }
}

@end
