//
//  LoadingViewController.m
//  EventosCaracol
//
//  Created by Developer on 19/11/13.
//  Copyright (c) 2013 iAmStudio. All rights reserved.
//

#import "LoadingViewController.h"
#import "DestacadosViewController.h"
#import "SWRevealViewController.h"
#import "SidebarViewController.h"
#import "LoginViewController.h"
#import "MBHUDView.h"
#import "AppDelegate.h"

@interface LoadingViewController ()
@property (strong, nonatomic) UIActivityIndicatorView *spinner;
@property (strong, nonatomic) UILabel *loadingLabel;
@end

@implementation LoadingViewController

#pragma mark - View Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    /////////////////////////////////////////////////////////////////////////
    //Create the UIImageView for the background
    UIImageView *logoImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0,
                                                                               0.0,
                                                                               self.view.frame.size.width,
                                                                               self.view.frame.size.height)];
    logoImageView.clipsToBounds = YES;
    logoImageView.contentMode = UIViewContentModeScaleAspectFill;
    
    //We have to check if the user is on iPad or iPhone; depending on this,
    //we assign the correct image for the image view.
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        logoImageView.image = [UIImage imageNamed:@"LoadingiPad.png"];
    else
        logoImageView.image = [UIImage imageNamed:@"Loading.png"];
    
    //Finally, add the image view to the view.
    [self.view addSubview:logoImageView];
    
    ////////////////////////////////////////////////////////////////////////
    //Add a 'Loading' label to our view
    self.loadingLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.view.frame.size.width/2 - (self.view.frame.size.width/3)/2,
                                                                      self.view.frame.size.height/1.15,
                                                                      self.view.frame.size.width/3,
                                                                      50.0)];
    self.loadingLabel.text = @"Cargando...";
    self.loadingLabel.numberOfLines = 1;
    self.loadingLabel.textAlignment = NSTextAlignmentCenter;
    self.loadingLabel.textColor = [UIColor whiteColor];
    self.loadingLabel.adjustsFontSizeToFitWidth = YES;
    self.loadingLabel.font = [UIFont fontWithName:@"Helvetica" size:30.0];
    [self.view addSubview:self.loadingLabel];
    
    ///////////////////////////////////////////////////////////////////////
    //Create an activity indicator to our view. this is important because
    //we have to let the user know that the info is downloading
    self.spinner = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(self.view.frame.size.width/2 - 25.0,
                                                                             self.loadingLabel.frame.origin.y - 50,
                                                                             50.0,
                                                                             50.0)];
    self.spinner.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
    [self.view addSubview:self.spinner];
    
    //Start animating the spinner and the network activity indicator.
    [self.spinner startAnimating];
    
    //Because we are accesing the network, we have to display a network activity
    //indicator in the status bar. we done this using the methods created in the
    //app delegate -incrementNetworkActivy and -decrementNetworkActivity
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate incrementNetworkActivity];
    
    //Access the server to obtain the info of the application
    [self getAllInfoFromServer];
    
    //Register as an observer of the notification center.
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(getAllInfoFromServer)
                                                 name:@"foreground"
                                               object:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - server request
-(void)getAllInfoFromServer
{
    //We are going to use ServerCommunicator to access the server, so we have to
    //intanciate it.
    ServerCommunicator *server=[[ServerCommunicator alloc]init];
    server.delegate=self;
    
    //Load the info from the server asynchronously. this is very important because
    //if we don't do it, the application will freeze until the info gets downloaded.
    dispatch_queue_t infoLoader = dispatch_queue_create("InfoLoader", nil);
    dispatch_async(infoLoader, ^(){
        [server callServerWithGETMethod:@"GetAllInfoWithAppID" andParameter:[[self getDictionaryWithName:@"app_id"] objectForKey:@"app_id"]];
    });
}

#pragma mark - Server Response

-(void)receivedDataFromServer:(NSDictionary *)dictionary withMethodName:(NSString *)methodName
{
    //Decrement the network activity indicator count, because we a re no longer
    //accesing the network. Also, stop the spinner.
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate decrementNetworkActivity];
    [self.spinner stopAnimating];
    
    //Check if the method returned from the server is the correct one
    if ([methodName isEqualToString:@"GetAllInfoWithAppID"]) {
        if ([dictionary objectForKey:@"app"])
        {
            //Save the dictionary downloaded from the server locally in our app.
            [self setDictionary:dictionary withName:@"master"];
            NSLog(@"%@", dictionary);
            
            //At this point we have all the neccessary info, so we can go to the
            //next view controller.
            [self goToLogin];
        }
        else
        {
            //no puede pasar
        }
    }
}

-(void)serverError:(NSError *)error
{
    //This delegate method gets called when there was an error connecting with
    //the server.
    
    //Decrement the network activity indicator count, because we a re no longer
    //accesing the network. Also, stop the spinner.
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate decrementNetworkActivity];
    [self.spinner stopAnimating];
    
    //If there was already information stored in the app, the user can go to
    //the next view controller.
    if([self getDictionaryWithName:@"master"])
    {
        NSLog(@"ya está guardada la info");
        [self goToLogin];
    }
    
    //if there wasn't information stored in the app, the user can't pass because
    //there is no information to be displayed. In this case, we display an alert
    //to inform the user about the problem.
    else
    {
        [[[UIAlertView alloc] initWithTitle:nil
                                   message:@"Hubo un error en la conexión. Revisa que estés conectad@ a internet."
                                  delegate:self
                         cancelButtonTitle:@"Ok"
                         otherButtonTitles:nil] show];
        
        self.loadingLabel.text = @"Error de conexión.";
    }
}

#pragma mark - Facebook Login

-(void)goToLogin
{
    //Check if the user has alredy login with Facebook; if so, go to the main page.
    if ([self getDictionaryWithName:@"user"])
    {
        DestacadosViewController *destacadosVC = [self.storyboard instantiateViewControllerWithIdentifier:@"Destacados"];
        SidebarViewController *sidebarVC = [self.storyboard instantiateViewControllerWithIdentifier:@"Sidebar"];
        
        UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:destacadosVC];
        SWRevealViewController *revealViewController = [[SWRevealViewController alloc] initWithRearViewController:sidebarVC
                                                                                              frontViewController:navigationController];
        [self presentViewController:revealViewController animated:YES completion:nil];
    }
    
    //...if not, present the login screen
    else
    {
        LoginViewController *loginVC = [self.storyboard instantiateViewControllerWithIdentifier:@"Login"];
        loginVC.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        [self presentViewController:loginVC animated:YES completion:nil];
    }
}

#pragma mark - File Saver Stuff

-(NSDictionary*)getDictionaryWithName:(NSString*)name{
    FileSaver *file=[[FileSaver alloc]init];
    return [file getDictionary:name];
}
-(void)setDictionary:(NSDictionary*)dictionary withName:(NSString*)name{
    FileSaver *file=[[FileSaver alloc]init];
    [file setDictionary:dictionary withKey:name];
}
@end
