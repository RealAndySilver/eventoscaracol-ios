//
//  ViewController.m
//  Muevete
//
//  Created by Andres Abril on 19/08/13.
//  Copyright (c) 2013 iAmStudio. All rights reserved.
//

//Errores
//Código 2 es no autorizado
//Código 5 es sin conexión


#import "LoginViewController.h"

//#define kRedColor [UIColor colorWithRed:250.0/255 green:88.0/255 blue:88.0/255 alpha:1]
#define kGreenColor [UIColor colorWithRed:64.0/255 green:174.0/255 blue:126.0/255 alpha:1]
#define kRedColor [UIColor colorWithRed:255.0/255 green:0.0/255 blue:0.0/255 alpha:1]
#define kBlueColor [UIColor colorWithRed:59.0/255 green:89.0/255 blue:152.0/255 alpha:1]
#define kColpatria [UIColor colorWithRed:189.0/255.0 green:13.0/255.0 blue:18.0/255.0 alpha:1]
@interface LoginViewController ()

@end

@implementation LoginViewController

#pragma mark - View Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    /////////////////////////////////////////////////////////////////////////////////////
    //Create an ImageView to set the background image
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0,
                                                                           0.0,
                                                                           self.view.frame.size.width,
                                                                           self.view.frame.size.height)];
    
    //Check if the user is on iPad or iPhone; dependin on this, assign the correct
    //image to the ImageView
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        imageView.image = [UIImage imageNamed:@"LoadingiPad.png"];
    else
    imageView.image = [UIImage imageNamed:@"Loading.png"];
    imageView.clipsToBounds = YES;
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    [self.view addSubview:imageView];
    
    //////////////////////////////////////////////////////////////////////////////////////
    //Create the login button
    UIButton *loginButton = [[UIButton alloc] initWithFrame:CGRectMake(self.view.bounds.size.width/2 - 125.0,
                                                                       self.view.bounds.size.height/1.4,
                                                                       250.0,
                                                                       50.0)];
    loginButton.backgroundColor = [UIColor colorWithRed:74.0/255.0 green:179.0/255.0 blue:1.0 alpha:1.0];
    [loginButton setTitle:@"Iniciar sesión con Facebook" forState:UIControlStateNormal];
    [self.view addSubview:loginButton];
    [loginButton addTarget:self action:@selector(loginButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    
    /////////////////////////////////////////////////////////////////////////////////////
    //Creathe the 'continue without login' button
    UIButton *continueWithoutLoginButton = [[UIButton alloc] initWithFrame:CGRectMake(self.view.frame.size.width/2 - 125.0,
                                                                                      loginButton.frame.origin.y + loginButton.frame.size.height + 20,
                                                                                      250.0,
                                                                                      50.0)];
    
    continueWithoutLoginButton.backgroundColor = [UIColor colorWithRed:74.0/255.0 green:179.0/255.0 blue:1.0 alpha:1.0];
    [continueWithoutLoginButton setTitle:@"Continuar sin iniciar sesión" forState:UIControlStateNormal];
    [continueWithoutLoginButton addTarget:self action:@selector(goToNextVC) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:continueWithoutLoginButton];
}

-(void)login
{
    FileSaver *fileSaver = [[FileSaver alloc] init];
    
    //Check if the user has already login
    if (![self userExists])
    {
        //Display the network activity indicator because we are accesing
        //the network.
        AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
        [appDelegate incrementNetworkActivity];
        [MBHUDView hudWithBody:@"Conectando" type:MBAlertViewHUDTypeActivityIndicator hidesAfter:1000 show:YES];
        
        NSArray *permissions =
        [NSArray arrayWithObjects:@"email", nil];
        [FBSession openActiveSessionWithReadPermissions:permissions
                                           allowLoginUI:YES
                                      completionHandler:^(FBSession *session, FBSessionState status, NSError *error) {
                                          if(!error){
                                              NSLog(@"No hay error");
                                              if (FBSession.activeSession.isOpen)
                                              {
                                                  NSLog(@"La sesion está abierta");
                                                  [[FBRequest requestForMe] startWithCompletionHandler:
                                                   ^(FBRequestConnection *connection, NSDictionary<FBGraphUser> *user, NSError *error) {
                                                       if (!error) {
                                                           
                                                           NSLog(@"Se pudo conectar");
                                                           NSLog(@"%@", user);
                                                           NSMutableDictionary *dic=[[NSMutableDictionary alloc]init];
                                                           [dic setObject:user[@"id"] forKey:@"id"];
                                                           [dic setObject:user[@"email"] forKey:@"email"];
                                                           [dic setObject:user[@"name"] forKey:@"name"];
                                                           [fileSaver setDictionary:dic withKey:@"facebookUser"];
                                                           [self sendInfo];
                                                       }
                                                       else{
                                                           if (error.code==5) {
                                                               NSLog(@"No hay conexión %ld",(long)error.code);
                                                               [MBHUDView dismissCurrentHUD];
                                                               [MBHUDView hudWithBody:@"Error de conexión" type:MBAlertViewHUDTypeExclamationMark hidesAfter:3 show:YES];
                                                           }
                                                       }
                                                   }];
                                              }
                                          }
                                          else{
                                              NSLog(@"Hubo un error");
                                              if (error.code==5) {
                                                  NSLog(@"No hay conexión %ld",(long)error.code);
                                                  [MBHUDView dismissCurrentHUD];
                                                  [MBHUDView hudWithBody:@"Error de conexión" type:MBAlertViewHUDTypeExclamationMark hidesAfter:3 show:YES];
                                              }
                                              else if (error.code==2){
                                                  NSLog(@"no autorizado error %ld",(long)error.code);
                                                  [MBHUDView dismissCurrentHUD];
                                                  [MBHUDView hudWithBody:@"No se inició sesión" type:MBAlertViewHUDTypeExclamationMark hidesAfter:3 show:YES];
                                              }
                                          }
                                      }];
    }
    else{
        /*if ([self userExists]) {
            NSLog(@"El usuario existe");
            //[self signUpWithUser:[self getUserDictionary]];
        }*/
        [self goToNextVC];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Send Info

-(void)sendInfo
{
    FileSaver *fileSaver = [[FileSaver alloc] init];
    
    //Construct the string to be send as a parameter to the server.
    NSString *parameters = [NSString stringWithFormat:@"email=%@&facebook_id=%@&name=%@&token=%@&brand=%@&os=%@&device=%@&app_id=%@",
                            [fileSaver getDictionary:@"facebookUser"][@"email"],
                            [fileSaver getDictionary:@"facebookUser"][@"id"],
                            [fileSaver getDictionary:@"facebookUser"][@"name"],
                            [fileSaver getToken],
                            [fileSaver getDictionary:@"DeviceInfo"][@"Brand"],
                            [fileSaver getDictionary:@"DeviceInfo"][@"SystemVersion"],
                            [fileSaver getDictionary:@"DeviceInfo"][@"Model"],
                            [[fileSaver getDictionary:@"app_id"] objectForKey:@"app_id"]];
    
    ServerCommunicator *server = [[ServerCommunicator alloc] init];
    server.delegate=self;
    [server callServerWithPOSTMethod:@"SignUp" andParameter:parameters httpMethod:@"POST"];
    //[MBHUDView dismissCurrentHUD];
    //[MBHUDView hudWithBody:@"Verificando" type:MBAlertViewHUDTypeActivityIndicator hidesAfter:1000 show:YES];
    NSLog(@"%@", parameters);
}

#pragma mark - Server Response

-(void)receivedDataFromServer:(NSDictionary *)dictionary withMethodName:(NSString *)methodName
{
    //At this point we are no longer connecting with the network, so we
    //have to decrement the netoworj activity indicator count.
    AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    [appDelegate decrementNetworkActivity];
    [MBHUDView dismissCurrentHUD];
    
    //Check if the method returned by the server is the correct one.
    if ([methodName isEqualToString:@"SignUp"])
    {
        NSLog(@"Result: %@",dictionary);
        
        //Check if the status returned by the server is 1 (this means that everything
        //was correct). if it is 1, we store the user info locally in the app and pass
        //to the next view controller.
        if([[dictionary objectForKey:@"status"] boolValue])
        {
            [self setDictionary:dictionary[@"user"] withKey:@"user"];
            [self goToNextVC];
        }
        
        //if the status returned is cero, the Facebook registration failed, so we tell
        //the user about the problem using an alert.
        else
        {
            //Error creando el usuario
            [MBHUDView hudWithBody:@"Error registrando su usuario, por favor vuelva a intentarlo."
                              type:MBAlertViewHUDTypeExclamationMark
                        hidesAfter:2.0
                              show:YES];
        }
    }
}

-(void)serverError:(NSError *)error
{
    //At this point we are no longer connecting with the network, so we
    //have to decrement the netoworj activity indicator count.
    AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    [appDelegate decrementNetworkActivity];
    [MBHUDView dismissCurrentHUD];
    
    NSLog(@"Error oís!!!");
    //Display a HUD to show the user that there was an error connecting with
    //the server.
    [MBHUDView hudWithBody:@"No hay conexión. Vuelve a intentarlo."
                      type:MBAlertViewHUDTypeExclamationMark
                hidesAfter:2.0
                      show:YES];
}

#pragma mark - Go To Next ViewController

-(void)goToNextVC
{
    [MBHUDView dismissCurrentHUD];
    
    //Check if this view controller was presented when the user tried to favorite an item.
    //is so, we dismiss it.
    if (self.loginWasPresentedFromFavoriteButtonAlert)
    {
        [self dismissViewControllerAnimated:YES completion:nil];
        return;
    }
    
    //...If not, we pass to the main page.
    DestacadosViewController *destacadosVC = [self.storyboard instantiateViewControllerWithIdentifier:@"Destacados"];
    SidebarViewController *sidebarVC = [self.storyboard instantiateViewControllerWithIdentifier:@"Sidebar"];
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:destacadosVC];
    SWRevealViewController *revealViewController = [[SWRevealViewController alloc] initWithRearViewController:sidebarVC
    frontViewController:navigationController];
    [self presentViewController:revealViewController animated:YES completion:nil];
}

#pragma mark - user exists

-(BOOL)userExists
{
    FileSaver *file=[[FileSaver alloc]init];
    NSDictionary *userCopy=[file getDictionary:@"user"];
    if (![userCopy objectForKey:@"id"])
        return NO;
    else
        return YES;
}

-(void)deleteUserDic
{
    NSDictionary *dic=[[NSDictionary alloc]initWithObjectsAndKeys:@"n",@"n", nil];
    FileSaver *file=[[FileSaver alloc]init];
    [file setDictionary:dic withKey:@"user"];
}

-(NSDictionary*)getUserDictionary
{
    FileSaver *file=[[FileSaver alloc]init];
    return [file getDictionary:@"user"];
}

-(NSString*)getUserToken
{
    FileSaver *file=[[FileSaver alloc]init];
    return [file getToken];
}

#pragma mark - set dictionary in file

-(void)setDictionary:(NSDictionary*)dic withKey:(NSString*)key
{
    FileSaver *file=[[FileSaver alloc]init];
    [file setDictionary:dic withKey:key];
}

-(void)loginButtonPressed
{
    [self login];
}
@end
