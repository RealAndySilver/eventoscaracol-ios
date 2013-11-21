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

@interface EventsListViewController () <UITableViewDataSource, UITableViewDelegate, SWTableViewCellDelegate, UIActionSheetDelegate, MFMailComposeViewControllerDelegate, MFMessageComposeViewControllerDelegate>{
}
@property (strong, nonatomic)  UITableView *tableView;
@property (strong, nonatomic) NSArray *eventsNamesTestArray; //Of NSString
@property (strong, nonatomic) NSArray *eventsLocationTestArray; //Of NSString

@end

#define ROW_HEIGHT 90.0

@implementation EventsListViewController

//Lazy Instantiation
-(NSArray *)eventsNamesTestArray
{
    if (!_eventsNamesTestArray)
        _eventsNamesTestArray = @[@"Desfile de las flores", @"Desfile de tulipanes", @"desfile de rosas", @"desfile de petunias", @"Fiesta al  parque"];
    
    return _eventsNamesTestArray;
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
    
    self.tableView=[[UITableView alloc]initWithFrame:CGRectMake(0, self.navigationController.navigationBar.frame.origin.y+self.navigationController.navigationBar.frame.size.height, self.view.frame.size.width, self.view.frame.size.height) style:UITableViewStylePlain];
    
    [self.view addSubview:_tableView];
    
    //Table View Config
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.rowHeight = ROW_HEIGHT;
    self.tableView.allowsSelection = YES;
    self.tableView.separatorInset = UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0);
    
    self.navigationItem.title = @"Programación";
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

@end
