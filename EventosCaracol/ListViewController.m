//
//  EventsListViewController.m
//  EventosCaracol
//
//  Created by Developer on 20/11/13.
//  Copyright (c) 2013 iAmStudio. All rights reserved.
//

#import <Social/Social.h>
#import <MessageUI/MessageUI.h>
#import <SDWebImage/UIImageView+WebCache.h>
#import "ListViewController.h"
#import "SWRevealViewController.h"
#import "DetailsViewController.h"
#import "SWTableViewCell.h"
#import "PopUpView.h"

@interface ListViewController ()
@property (strong, nonatomic)  UITableView *tableView;
@property (strong, nonatomic) UIPickerView *locationPickerView;
@property (strong, nonatomic) UIPickerView *datePickerView;
@property (strong, nonatomic) UIView *containerLocationPickerView;
@property (strong, nonatomic) UIView *containerDatesPickerView;
@property (nonatomic) BOOL isPickerActivated;
@end

#define ROW_HEIGHT 90.0

@implementation ListViewController

#pragma mark - View LifeCycle

-(void)viewDidLoad
{
    [super viewDidLoad];
    
    SWRevealViewController *revealViewController = [self revealViewController];
    
    if (!self.locationList)
    {
        UIBarButtonItem *slideMenuBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Menu"
                                                                                   style:UIBarButtonItemStylePlain
                                                                                  target:revealViewController
                                                                                  action:@selector(revealToggle:)];
        self.navigationItem.leftBarButtonItem = slideMenuBarButtonItem;
        [self.view addGestureRecognizer:revealViewController.panGestureRecognizer];
    }
    
    //Configure the backBarButtonItem that will be displayed in the Navigation Bar when the user moves to EventDetailsViewController
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Volver"
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:self
                                                                            action:nil];
    self.navigationItem.title = self.navigationBarTitle;
    
    ///////////////////////////////////////////////////////////////////
    //Create two buttons to filter the events list by date and by location
    //Filter by date button
    
    if (!self.locationList)
    {
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
        
        self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, filterByLocationButton.frame.origin.y + filterByLocationButton.frame.size.height, self.view.frame.size.width, self.view.frame.size.height) style:UITableViewStylePlain];
        [self.view addSubview:_tableView];
    }
    
    else
    {
        self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0,
                                                                       0.0,
                                                                       self.view.frame.size.width,
                                                                       self.view.frame.size.height)
                                                      style:UITableViewStylePlain];
        self.tableView.contentInset = UIEdgeInsetsMake(64.0, 0.0, 0.0, 0.0);
        [self.view addSubview:_tableView];
    }
    
    ///////////////////////////////////////////////////////////////////
    //Table View initialization and configuration
    
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
    return [self.menuItemsArray count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ///////////////////////////////////////////////////////////////////
    //Dequeue our custom cell SWTableViewCell
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
    
    /////////////////////////////////////////////////////////////////////
    //Create the subviews that will contain the cell.
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(10.0, 10.0, 70.0, 70.0)];
    imageView.clipsToBounds = YES;
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    imageView.backgroundColor = [UIColor cyanColor];
    
    //Set the cell's thumb image using the SDWebImage Method -setImageWithURL: (This method saves the image in cache).
    [imageView setImageWithURL:self.menuItemsArray[indexPath.row][@"thumb_url"] placeholderImage:[UIImage imageNamed:@"CaracolPrueba4.png"]];
    //[imageView setImageWithURL:self.menuItemsArray[indexPath.row][@"thumb_url"]];
    
    [eventCell.contentView addSubview:imageView];
    
    UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(100.0, 20.0, 150, 20.0)];
    nameLabel.text = self.menuItemsArray[indexPath.row][@"name"];
    nameLabel.font = [UIFont fontWithName:@"Helvetica" size:15.0];
    [eventCell.contentView addSubview:nameLabel];
    
    /*UILabel *descriptionLabel = [[UILabel alloc] initWithFrame:CGRectMake(100.0, 50.0, 100.0, 20.0)];
    descriptionLabel.text = @"Plaza roja";
    descriptionLabel.font = [UIFont fontWithName:@"Helvetica" size:12.0];
    [eventCell.contentView addSubview:descriptionLabel];
    
    UILabel *eventTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(210.0, 50.0, 100.0, 20.0)];
    eventTimeLabel.text = @"10:00AM";
    eventTimeLabel.font = [UIFont fontWithName:@"Helvetica" size:12.0];
    [eventCell.contentView addSubview:eventTimeLabel];*/
    
    return eventCell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    DetailsViewController *detailsVC = [self.storyboard instantiateViewControllerWithIdentifier:@"EventDetails"];
    detailsVC.objectInfo = self.menuItemsArray[indexPath.row];
    
    //We have to check if the cell that the user touched contained a location type object. If so, the next view controller
    //will display a map on screen.
    if (self.locationList)
        detailsVC.presentLocationObject = YES;
    
    detailsVC.navigationBarTitle = self.menuItemsArray[indexPath.row][@"name"];
    [self.navigationController pushViewController:detailsVC animated:YES];
}

#pragma mark - SWTableViewDelegate

-(void)swippableTableViewCell:(SWTableViewCell *)cell didTriggerLeftUtilityButtonWithIndex:(NSInteger)index
{
    //If the user touches the favorite button of the cell.
    if (index == 0)
    {
        //Use our custom UIView to display a favorite image on screen
        [PopUpView showPopUpViewOverView:self.view image:[UIImage imageNamed:nil]];
    }
    
    //if the user touches the share button of the cell.
    else if (index == 1)
    {
        [[[UIActionSheet alloc] initWithTitle:@""
                                    delegate:self
                           cancelButtonTitle:@"Volver"
                      destructiveButtonTitle:nil
                           otherButtonTitles:@"SMS", @"Facebook", @"Twitter", @"Correo" ,nil] showInView:self.view];
    }
}

-(void)swippableTableViewCell:(SWTableViewCell *)cell didTriggerRightUtilityButtonWithIndex:(NSInteger)index
{
    [PopUpView showPopUpViewOverView:self.view image:[UIImage imageNamed:@"BorrarPrueba.png"]];
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
    
    //Facebook button
    else if (buttonIndex == 1)
    {
        NSLog(@"Facebook");
       
        SLComposeViewController *facebookViewController = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
        [facebookViewController setInitialText:@"Me acabo de inscribir al evento que vamos a ir todos."];
        [self presentViewController:facebookViewController animated:YES completion:nil];
    }
    
    //Twitter button
    else if (buttonIndex == 2)
    {
        NSLog(@"Twitter");
    
        SLComposeViewController *twitterViewController = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
        [twitterViewController setInitialText:@"Me acbo de inscribir a este genial evento"];
        [self presentViewController:twitterViewController animated:YES completion:nil];
    }
    
    //Email button
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
    return 1;
}

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return @"hola";
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
