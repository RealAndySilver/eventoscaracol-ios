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
    
    /*self.view.backgroundColor = [UIColor colorWithRed:17.0/255.0
                                                green:96.0/255.0
                                                 blue:153.0/255.0
                                                alpha:1.0];*/
    
    /////////////////////////////////////////////////////
    UIImageView *logoImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0,
                                                                               0.0,
                                                                               self.view.frame.size.width,
                                                                               self.view.frame.size.height)];
    logoImageView.clipsToBounds = YES;
    logoImageView.contentMode = UIViewContentModeScaleAspectFill;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        logoImageView.image = [UIImage imageNamed:@"LoadingiPad.png"];
    else
    logoImageView.image = [UIImage imageNamed:@"Loading.png"];
    [self.view addSubview:logoImageView];
    
    /////////////////////////////////////////////////////
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
    
    ////////////////////////////////////////////////////
    //Add the spinner to our view
    self.spinner = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(self.view.frame.size.width/2 - 25.0,
                                                                             self.loadingLabel.frame.origin.y - 50,
                                                                             50.0,
                                                                             50.0)];
    self.spinner.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
    [self.view addSubview:self.spinner];
    
    //We access the info from the server as soon as the view loads.
    [self getAllInfoFromServer];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getAllInfoFromServer) name:@"foreground" object:nil];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    //[self.navigationController setNavigationBarHidden:NO];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - server request
-(void)getAllInfoFromServer
{
    ServerCommunicator *server=[[ServerCommunicator alloc]init];
    server.delegate=self;
    
    //Start animating the spinner.
    [self.spinner startAnimating];
    
    //Load the info from the server asynchronously
    dispatch_queue_t infoLoader = dispatch_queue_create("InfoLoader", nil);
    dispatch_async(infoLoader, ^(){
        [server callServerWithGETMethod:@"GetAllInfoWithAppID" andParameter:[[self getDictionaryWithName:@"app_id"] objectForKey:@"app_id"]];
    });
}
#pragma mark - server response
-(void)receivedDataFromServer:(NSDictionary *)dictionary withMethodName:(NSString *)methodName
{
    if ([methodName isEqualToString:@"GetAllInfoWithAppID"]) {
        if ([dictionary objectForKey:@"app"])
        {
            [self setDictionary:dictionary withName:@"master"];
            NSLog(@"%@", dictionary);
            //At this point, we have received the info from the server, so we need to stop the spinner.
            [self.spinner stopAnimating];
            
            [self goToLogin];
        }
        else
        {
            //no puede pasar
        }
    }
}
-(void)serverError:(NSError *)error{
    if([self getDictionaryWithName:@"master"])
    {
        NSLog(@"ya está guardada la info");
        [self goToLogin];
        //ir al siguiente porque ya existe info guardada
    }
    else
    {
        //No se puede pasar
        [[[UIAlertView alloc] initWithTitle:nil
                                   message:@"Hubo un error en la conexión. intenta de nuevo en unos minutos."
                                  delegate:self
                         cancelButtonTitle:@"Ok"
                         otherButtonTitles:nil] show];
        
        self.loadingLabel.text = @"Error de conexión.";
        
        /*[MBHUDView hudWithBody:@"Hubo un error en la conexión. Por favor vuelve a intentar en unos minutos."
                          type:MBAlertViewHUDTypeExclamationMark
                    hidesAfter:5.0
                          show:YES];*/
    }
    [self.spinner stopAnimating];

}
-(void)goToLogin
{
    FileSaver *fileSaver = [[FileSaver alloc] init];
    
    //If the user has already login with facebook, go to the home screen
    if ([fileSaver getDictionary:@"user"])
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


-(NSDictionary*)getDictionaryWithName:(NSString*)name{
    FileSaver *file=[[FileSaver alloc]init];
    return [file getDictionary:name];
}
-(void)setDictionary:(NSDictionary*)dictionary withName:(NSString*)name{
    FileSaver *file=[[FileSaver alloc]init];
    [file setDictionary:dictionary withKey:name];
}
@end
