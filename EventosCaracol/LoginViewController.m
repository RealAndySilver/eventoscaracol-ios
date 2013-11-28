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
#import "ServerCommunicator.h"
#import <FacebookSDK/FacebookSDK.h>
#import "FileSaver.h"
#import "ServerCommunicator.h"
#import "DestacadosViewController.h"
#import "SidebarViewController.h"
#import "SWRevealViewController.h"

//#define kRedColor [UIColor colorWithRed:250.0/255 green:88.0/255 blue:88.0/255 alpha:1]
#define kGreenColor [UIColor colorWithRed:64.0/255 green:174.0/255 blue:126.0/255 alpha:1]
#define kRedColor [UIColor colorWithRed:255.0/255 green:0.0/255 blue:0.0/255 alpha:1]
#define kBlueColor [UIColor colorWithRed:59.0/255 green:89.0/255 blue:152.0/255 alpha:1]
#define kColpatria [UIColor colorWithRed:189.0/255.0 green:13.0/255.0 blue:18.0/255.0 alpha:1]
@interface LoginViewController ()<ServerCommunicatorDelegate>{
}

@end

@implementation LoginViewController

- (void)viewDidLoad{
    [super viewDidLoad];
    //[self deleteUserDic];
    if ([self userExists]) {
        [self goToNextVC];
        return;
    }
    //[self callTutorialAnimated:NO];
    
    //[self.view setBackgroundColor:kColpatria];
    
    /*UIView *loginButtonContainer=[[UIView alloc]initWithFrame:CGRectMake(0, 130, self.view.frame.size.width, 60)];
    loginButtonContainer.backgroundColor=kBlueColor;
    loginButtonContainer.center=CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height/2);
    [loginButtonContainer setClipsToBounds:YES];*
    UIImageView *fbConnectImage=[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"fbconnect.png"]];
    fbConnectImage.frame=CGRectMake(self.view.frame.size.width-110, 15, 100, 30);
    [loginButtonContainer addSubview:fbConnectImage];*/
    
    UIButton *loginButton = [[UIButton alloc] initWithFrame:CGRectMake(self.view.bounds.size.width/2, self.view.bounds.size.height/2, 100.0, 50.0)];
    loginButton.backgroundColor = [UIColor blueColor];
    [loginButton setTitle:@"Log In" forState:UIControlStateNormal];
    [self.view addSubview:loginButton];
    [loginButton addTarget:self action:@selector(loginButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    
    /*PullActionButton *loginButton=[[PullActionButton alloc]initWithFrame:CGRectMake(-190,0, 390, 60)];
    loginButton.the_delegate=self;
    loginButton.label.text=@"Desliza para Entrar";
    loginButton.layer.shadowOffset=CGSizeMake(0.0,0.0);
    loginButton.layer.shadowOpacity=0.8;
    loginButton.layer.shadowRadius=3.0;
    loginButton.color=kBlueColor;
    loginButton.hilightColor=kColpatria;
    [loginButtonContainer addSubview:loginButton];
    
    loginButton.icon.image=[UIImage imageNamed:@"grip.png"];
    loginButton.icon.frame=CGRectMake(loginButton.frame.size.width-30, 15, 15, 30);
    loginButton.icon.alpha=0.5;*/
    //[self.view addSubview:loginButtonContainer];
}
-(void)login{
    
    FileSaver *fileSaver = [[FileSaver alloc] init];
    
    if (![self userExists]) {
        //[MBHUDView hudWithBody:@"Conectando" type:MBAlertViewHUDTypeActivityIndicator hidesAfter:1000 show:YES];
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
                                                           [fileSaver setDictionary:dic withKey:@"user"];
                                                           [self sendInfo];
                                                           
                                                           //[dic setObject:[IAmCoder base64String:[user objectForKey:@"id"]] forKey:@"id"];
                                                           //[dic setObject:[IAmCoder base64String:[user objectForKey:@"email"]] forKey:@"email"];
                                                           //[dic setObject:[IAmCoder base64String:[user objectForKey:@"name"]] forKey:@"name"];
                                                           //[self setDictionary:dic withKey:@"user"];
                                                           //[self signUpWithUser:dic];*/
                                                       }
                                                       else{
                                                           if (error.code==5) {
                                                               NSLog(@"No hay conexión %ld",(long)error.code);
                                                               //[MBHUDView dismissCurrentHUD];
                                                               //[MBHUDView hudWithBody:@"Error de conexión" type:MBAlertViewHUDTypeExclamationMark hidesAfter:3 show:YES];
                                                           }
                                                       }
                                                   }];
                                              }
                                          }
                                          else{
                                              NSLog(@"Hubo un error");
                                              if (error.code==5) {
                                                  NSLog(@"No hay conexión %ld",(long)error.code);
                                                  //[MBHUDView dismissCurrentHUD];
                                                  //[MBHUDView hudWithBody:@"Error de conexión" type:MBAlertViewHUDTypeExclamationMark hidesAfter:3 show:YES];
                                              }
                                              else if (error.code==2){
                                                  NSLog(@"no autorizado error %ld",(long)error.code);
                                                  //[MBHUDView dismissCurrentHUD];
                                                  //[MBHUDView hudWithBody:@"Acceso denegado" type:MBAlertViewHUDTypeExclamationMark hidesAfter:3 show:YES];
                                              }
                                          }
                                      }];
    }
    else{
        if ([self userExists]) {
            NSLog(@"El usuario existe");
            //[self signUpWithUser:[self getUserDictionary]];
        }
        //[self goToNextVC];
    }
}
- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
}

-(void)sendInfo
{
    FileSaver *fileSaver = [[FileSaver alloc] init];
    NSString *parameters = [NSString stringWithFormat:@"email=%@&id=%@&name=%@&token=%@&brand=%@&os=%@&device=%@&app_id=%@",
                            [fileSaver getDictionary:@"user"][@"email"],
                            [fileSaver getDictionary:@"user"][@"id"],
                            [fileSaver getDictionary:@"user"][@"name"],
                            [fileSaver getToken],
                            [fileSaver getDictionary:@"DeviceInfo"][@"Brand"],
                            [fileSaver getDictionary:@"DeviceInfo"][@"SystemVersion"],
                            [fileSaver getDictionary:@"DeviceInfo"][@"Model"],
                            [[fileSaver getDictionary:@"app_id"] objectForKey:@"app_id"]];
    
    ServerCommunicator *server = [[ServerCommunicator alloc] init];
    server.delegate=self;
    [server callServerWithPOSTMethod:@"SignUp" andParameter:parameters httpMethod:@"POST"];
    NSLog(@"%@", parameters);
}

#pragma mark - server request
/*-(void)signUpWithUser:(NSDictionary*)user{
    ServerCommunicator *server=[[ServerCommunicator alloc]init];
    
    server.caller=self;
    server.tag=1;
    NSString *params=[NSString stringWithFormat:@"facebookId=%@&name=%@&email=%@&token=%@",[user objectForKey:@"id"],[user objectForKey:@"name"],[user objectForKey:@"email"],[self getUserToken]];
    params=[params stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    params=[params stringByExpandingTildeInPath];
    NSLog(@"Params %@",params);
    [server callServerWithPOSTMethod:@"SignUp" andParameter:params httpMethod:@"POST"];
    [MBHUDView dismissCurrentHUD];
    [MBHUDView hudWithBody:@"Verificando" type:MBAlertViewHUDTypeActivityIndicator hidesAfter:1000 show:YES];
}
-(void)downloadSafeSpots{
    ServerCommunicator *server=[[ServerCommunicator alloc]init];
    server.caller=self;
    server.tag=2;
    [server callServerWithGETMethod:@"GetSafeSpots" andParameter:@"123"];
}*/

#pragma mark - server response
-(void)receivedDataFromServer:(NSDictionary *)dictionary withMethodName:(NSString *)methodName{
    if ([methodName isEqualToString:@"SignUp"]) {
        NSLog(@"Result: %@",dictionary);
        if([[dictionary objectForKey:@"status"] boolValue]){
            [self goToNextVC];
        }
    }
}

#pragma mark - next vc
-(void)goToNextVC
{
    DestacadosViewController *destacadosVC = [self.storyboard instantiateViewControllerWithIdentifier:@"Destacados"];
    SidebarViewController *sidebarVC = [self.storyboard instantiateViewControllerWithIdentifier:@"Sidebar"];
     
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:destacadosVC];
    SWRevealViewController *revealViewController = [[SWRevealViewController alloc] initWithRearViewController:sidebarVC
    frontViewController:navigationController];
    [self presentViewController:revealViewController animated:YES completion:nil];
}
#pragma mark - user exists
-(BOOL)userExists{
    FileSaver *file=[[FileSaver alloc]init];
    NSDictionary *userCopy=[file getDictionary:@"user"];
    if (![userCopy objectForKey:@"id"])
        return NO;
    else
        return YES;
}
-(void)deleteUserDic{
    NSDictionary *dic=[[NSDictionary alloc]initWithObjectsAndKeys:@"n",@"n", nil];
    FileSaver *file=[[FileSaver alloc]init];
    [file setDictionary:dic withKey:@"user"];
}
-(NSDictionary*)getUserDictionary{
    FileSaver *file=[[FileSaver alloc]init];
    return [file getDictionary:@"user"];
}
-(NSString*)getUserToken{
    FileSaver *file=[[FileSaver alloc]init];
    return [file getToken];
}
#pragma mark - set dictionary in file
-(void)setDictionary:(NSDictionary*)dic withKey:(NSString*)key{
    FileSaver *file=[[FileSaver alloc]init];
    [file setDictionary:dic withKey:key];
}
#pragma mark - pull action button delegate
-(void)actionAccepted:(int)tag{
    NSLog(@"Accepted");
    [self login];
}
-(IBAction)infoButton:(id)sender{
    //[self callTutorialAnimated:YES];
}
/*-(void)callTutorialAnimated:(BOOL)animated{
    TutorialViewController *tVC=[[TutorialViewController alloc]init];
    tVC=[self.storyboard instantiateViewControllerWithIdentifier:@"Tutorial"];
    [self presentViewController:tVC animated:animated completion:nil];
}*/

-(void)loginButtonPressed
{
    [self login];
}
@end
