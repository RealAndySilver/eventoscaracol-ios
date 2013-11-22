//
//  LoadingViewController.m
//  EventosCaracol
//
//  Created by Developer on 19/11/13.
//  Copyright (c) 2013 iAmStudio. All rights reserved.
//

#import "LoadingViewController.h"

@interface LoadingViewController ()

@end

@implementation LoadingViewController

- (void)viewDidLoad{
    [super viewDidLoad];
    [self getAllInfoFromServer];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getAllInfoFromServer) name:@"foreground" object:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - server request
-(void)getAllInfoFromServer{
    ServerCommunicator *server=[[ServerCommunicator alloc]init];
    server.delegate=self;
    [server callServerWithGETMethod:@"GetAllInfoWithAppID" andParameter:@"528c1c396e9f990000000001"];
    //Inicia el preloader
}
#pragma mark - server response
-(void)receivedDataFromServer:(NSDictionary *)dictionary withMethodName:(NSString *)methodName{
    if ([methodName isEqualToString:@"GetAllInfoWithAppID"]) {
        if ([dictionary objectForKey:@"app"]) {
            [self setDictionary:dictionary withName:@"master"];
        }
        else{
            //no puede pasar
        }
    }
    //Finaliza preloader
}
-(void)serverError:(NSError *)error{
    if([self getDictionaryWithName:@"master"]){
        //ir al siguiente porque ya existe info guardada
    }
    else{
        //No se puede pasar
    }
    //Finaliza preloader
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
