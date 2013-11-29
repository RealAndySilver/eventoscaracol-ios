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

@interface LoadingViewController ()
@property (strong, nonatomic) UIActivityIndicatorView *spinner;
@end

@implementation LoadingViewController

#pragma mark - View Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    /////////////////////////////////////////////////////
    UIImageView *logoImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0,
                                                                               0.0,
                                                                               self.view.frame.size.width,
                                                                               self.view.frame.size.width)];
    logoImageView.image = [UIImage imageNamed:@"CaracolPrueba3.png"];
    [self.view addSubview:logoImageView];
    
    /////////////////////////////////////////////////////
    //Add a 'Loading' label to our view
    UILabel *loadingLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.view.frame.size.width/2 - 50.0,
                                                                      self.view.frame.size.height/1.15,
                                                                      100.0,
                                                                      44.0)];
    loadingLabel.text = @"Cargando...";
    loadingLabel.textAlignment = NSTextAlignmentCenter;
    loadingLabel.textColor = [UIColor whiteColor];
    loadingLabel.font = [UIFont fontWithName:@"Helvetica" size:17.0];
    [self.view addSubview:loadingLabel];
    
    ////////////////////////////////////////////////////
    //Add the spinner to our view
    self.spinner = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(self.view.frame.size.width/2 - 25.0,
                                                                             self.view.frame.size.height/1.3,
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
    FileSaver *file=[[FileSaver alloc]init];
    
    //Load the info from the server asynchronously
    dispatch_queue_t infoLoader = dispatch_queue_create("InfoLoader", nil);
    dispatch_async(infoLoader, ^(){
        [server callServerWithGETMethod:@"GetAllInfoWithAppID" andParameter:[[file getDictionary:@"app_id"] objectForKey:@"app_id"]];
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

-(void)goToLogin
{
    //Use SWRevealViewController to present the home screen of the app
    DestacadosViewController *destacadosVC = [self.storyboard instantiateViewControllerWithIdentifier:@"Destacados"];
    SidebarViewController *sidebarVC = [self.storyboard instantiateViewControllerWithIdentifier:@"Sidebar"];
    
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:destacadosVC];
    SWRevealViewController *revealViewController = [[SWRevealViewController alloc] initWithRearViewController:sidebarVC
                                                                                          frontViewController:navigationController];
    [self presentViewController:revealViewController animated:YES completion:nil];
    
    /*LoginViewController *loginVC = [self.storyboard instantiateViewControllerWithIdentifier:@"Login"];
    [self presentViewController:loginVC animated:YES completion:nil];*/
}

-(void)serverError:(NSError *)error{
    if([self getDictionaryWithName:@"master"])
    {
        NSLog(@"ya está guardada la info");
        //ir al siguiente porque ya existe info guardada
    }
    else
    {
        //No se puede pasar
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
