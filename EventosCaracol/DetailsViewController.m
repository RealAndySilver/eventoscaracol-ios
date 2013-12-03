//
//  EventDetailsViewController.m
//  EventosCaracol
//
//  Created by Developer on 20/11/13.
//  Copyright (c) 2013 iAmStudio. All rights reserved.
//

#import "DetailsViewController.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import <MessageUI/MessageUI.h>
#import "PopUpView.h"
#import <Social/Social.h>
#import <GoogleMaps/GoogleMaps.h>

@interface DetailsViewController () <UIActionSheetDelegate, MFMailComposeViewControllerDelegate, MFMessageComposeViewControllerDelegate, UIScrollViewDelegate>
@property (strong, nonatomic) UIScrollView *scrollView;
@end

@implementation DetailsViewController

-(void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.title = self.navigationBarTitle;
    
    //Create the UIBarButtonItem to share the event.
    UIBarButtonItem *shareBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose
                                                                                        target:self
                                                                                        action:@selector(shareEvent)];
    
    self.navigationItem.rightBarButtonItem = shareBarButtonItem;
    
    //If this controller was presented from a search bar table view selection, create a UIBarButtomItem to dismiss it.
    if (self.presentViewControllerFromSearchBar)
    {
        UIBarButtonItem *dismissBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Dismiss"
                                                                                 style:UIBarButtonItemStylePlain
                                                                                target:self
                                                                                action:@selector(dismiss)];
        self.navigationItem.leftBarButtonItem = dismissBarButtonItem;
    }
    
    //UIImageVIew that will display the object's image (artist, news, event).
    UIImageView *mainImageView;
    
    //If we are in the detail view of a location object
    if (self.presentLocationObject)
    {
        GMSCameraPosition *cameraPosition = [GMSCameraPosition cameraWithLatitude:[self.objectInfo[@"lat"] doubleValue]
                                                                        longitude:[self.objectInfo[@"lon"] doubleValue]
                                                                             zoom:12.0];
        
        GMSMapView *mapView = [GMSMapView mapWithFrame:CGRectMake(0.0,
                                                                  self.navigationController.navigationBar.frame.origin.y + self.navigationController.navigationBar.frame.size.height + 0.0,
                                                                  self.view.frame.size.width ,
                                                                  (self.view.frame.size.height/2 - 20) -(self.navigationController.navigationBar.frame.origin.y + self.navigationController.navigationBar.frame.size.height + 20.0))
                                                camera:cameraPosition];
        
        mapView.myLocationEnabled = YES;
        mapView.userInteractionEnabled = NO;
        double markerLatitude = [self.objectInfo[@"lat"] doubleValue];
        double markerLongitude = [self.objectInfo[@"lon"] doubleValue];
        GMSMarker *marker = [GMSMarker markerWithPosition:CLLocationCoordinate2DMake(markerLatitude, markerLongitude)];
        marker.title = self.objectInfo[@"name"];
        marker.map = mapView;
        [self.view addSubview:mapView];
        
        //////////////////////////////////////////////////////////////////////
        //Create the scroll view to make all the content scrollable. The scroll view will be below the map view.
        //The mapview is always static, it's not in the scroll view.
        self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0.0,
                                                                                  mapView.frame.origin.y + mapView.frame.size.height,
                                                                                  self.view.frame.size.width,
                                                                                  self.view.frame.size.height - (mapView.frame.origin.y + mapView.frame.size.height))];
        
        
        
        mainImageView = [[UIImageView alloc] initWithFrame:CGRectMake(20.0,
                                                                      20.0,
                                                                      self.view.frame.size.width - 40.0,
                                                                      self.view.frame.size.height/2 - 20.0)];
        
    }

    else
    {
        //Create the scroll view of the entire screen, because there is not map view.
        self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0.0,
                                                                         0.0,
                                                                         self.view.frame.size.width,
                                                                         self.view.frame.size.height)];
        
        mainImageView = [[UIImageView alloc]
                         initWithFrame:CGRectMake(20.0,
                                                  self.navigationController.navigationBar.frame.origin.y + self.navigationController.navigationBar.frame.size.height + 20.0,
                                                  self.view.frame.size.width - 40.0,
                                                  (self.view.frame.size.height/2 - 20) -(self.navigationController.navigationBar.frame.origin.y + self.navigationController.navigationBar.frame.size.height + 20.0))];
    }
    
    mainImageView.backgroundColor = [UIColor cyanColor];
    mainImageView.clipsToBounds = YES;
    mainImageView.contentMode = UIViewContentModeScaleAspectFill;
    [mainImageView setImageWithURL:[NSURL URLWithString:self.objectInfo[@"image_url"][0]]
                  placeholderImage:[UIImage imageNamed:@"CaracolPrueba4.png"]];
    
    self.scrollView.delegate = self;
    self.scrollView.alwaysBounceVertical = YES;
    [self.scrollView addSubview:mainImageView];
    [self.view addSubview:self.scrollView];
    
    UIButton *favoriteButton = [[UIButton alloc] initWithFrame:CGRectMake(20.0,
                                                                          mainImageView.frame.origin.y + mainImageView.frame.size.height + 20.0,
                                                                          40.0,
                                                                          40.0)];
    [favoriteButton setTitle:@"Fav" forState:UIControlStateNormal];
    [favoriteButton addTarget:self action:@selector(showFavoriteAnimation) forControlEvents:UIControlEventTouchUpInside];
    [favoriteButton setBackgroundColor:[UIColor purpleColor]];
    [self.scrollView addSubview:favoriteButton];
    
    UILabel *objectName = [[UILabel alloc] initWithFrame:CGRectMake(20.0 + favoriteButton.frame.size.width + 20,
                                                                   favoriteButton.frame.origin.y,
                                                                   self.view.frame.size.width - (20.0 + favoriteButton.frame.size.width + 20) - 20,
                                                                   44.0)];
    objectName.numberOfLines = 0;
    objectName.text = self.objectInfo[@"name"];
    objectName.font = [UIFont fontWithName:@"@Helvetica" size:15.0];
    [self.scrollView addSubview:objectName];
    
    UILabel *eventLocationLabel = [[UILabel alloc] initWithFrame:CGRectMake(20.0 + favoriteButton.frame.size.width + 20,
                                                                            objectName.frame.origin.y + objectName.frame.size.height,
                                                                            self.view.frame.size.width - (20.0 + favoriteButton.frame.size.width + 20) - 20,
                                                                            20.0)];
    eventLocationLabel.text = @"Plaza Cervantes";
    eventLocationLabel.font = [UIFont fontWithName:@"Helvetica" size:12.0];
    [self.scrollView addSubview:eventLocationLabel];
    
    UILabel *eventTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(20.0 + favoriteButton.frame.size.width + 20,
                                                                        eventLocationLabel.frame.origin.y + eventLocationLabel.frame.size.height,
                                                                        self.view.frame.size.width - (20.0 + favoriteButton.frame.size.width + 20) - 20,
                                                                        20.0)];
    eventTimeLabel.text = @"11:30AM";
    eventTimeLabel.font = [UIFont fontWithName:@"Helvetica" size:12.0];
    [self.scrollView addSubview:eventTimeLabel];
    
    UITextView *description = [[UITextView alloc]
                                    initWithFrame:CGRectMake(20.0,
                                                             eventTimeLabel.frame.origin.y + eventTimeLabel.frame.size.height + 10,
                                                             self.view.frame.size.width - 40.0,
                                                             150.0)];
    description.text = self.objectInfo[@"detail"];
    /*description.text = @"Lorem ipsum dolor sit amet, consectetuer adipiscing elit, sed diam nonummy nibh euismod tincidunt ut laoreet dolore magna aliquam erat volutpat. Ut wisi enim ad minim veniam, quis nostrud exerci tation ullamcorper suscipit lobortis nisl ut aliquip ex ea commodo consequat. Duis autem vel eum iriure dolor in hendrerit in vulputate velit esse molestie consequat, vel illum dolore eu feugiat nulla facilisis at vero eros et accumsan et iusto odio dignissim qui blandit praesent luptatum zzril delenit augue duis dolore te feugait nulla facilisi. Nam liber tempor cum soluta nobis eleifend option congue nihil imperdiet doming id quod mazim placerat facer possim assum. Typi non haben";*/
    description.font = [UIFont fontWithName:@"Helvetica" size:14.0];
    description.selectable = YES;
    description.editable = NO;
    [self.scrollView addSubview:description];
    self.scrollView.contentSize = CGSizeMake(self.view.frame.size.width, description.frame.origin.y + description.frame.size.height + 20);
}

#pragma mark - Actions

-(void)dismiss
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)showFavoriteAnimation
{
    [PopUpView showPopUpViewOverView:self.view image:nil];
}

-(void)shareEvent
{
    [[[UIActionSheet alloc] initWithTitle:nil
                                delegate:self
                       cancelButtonTitle:@"Volver"
                  destructiveButtonTitle:nil
                       otherButtonTitles:@"SMS", @"Facebook", @"Twitter", @"Correo", nil] showInView:self.view];
}

#pragma mark - UIActionSheetDelegate

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == 0)
    {
        NSLog(@"SMS");
        if (![MFMessageComposeViewController canSendText])
        {
            [[[UIAlertView alloc] initWithTitle:@"Error"
                                       message:@"No se pueden enviar mensajes desde este dispositivo"
                                      delegate:self
                             cancelButtonTitle:@"Ok"
                             otherButtonTitles:nil] show];
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

#pragma mark - MFMailComposeViewControllerDelegate

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
