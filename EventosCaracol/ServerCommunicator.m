//
//  ServerCommunicator.m
//  WebConsumer
//
//  Created by Andres Abril on 19/04/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ServerCommunicator.h"
#import "IAmCoder.h"
<<<<<<< HEAD
#define ENDPOINT @"http://iccknet-eventoscaracol.jit.su/api_1.0"
//#define ENDPOINT @"http://192.168.1.109:8080"
=======
#define ENDPOINT @"http://192.241.187.135:2000"
//#define ENDPOINT @"http://iccknet-eventoscaracol.jit.su/api_1.0"
>>>>>>> whitelabel
//#define ENDPOINT @"http://10.0.1.6:8080/api_1.0"
//#define ENDPOINT @"http://caracol.aws.af.cm/"
//#define ENDPOINT @"http://10.0.1.9:8080"
//#define ENDPOINT @"http://iamstudio-sweetwater.herokuapp.com/"
//#define ENDPOINT @"http://sweetwater.jit.su"

@implementation ServerCommunicator
@synthesize tag,delegate;
-(id)init {
    self = [super init];
    if (self)
    {
        tag = 0;
    }
    return self;
}
-(void)callServerWithGETMethod:(NSString*)method andParameter:(NSString*)parameter{
    parameter=[parameter stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    parameter=[parameter stringByExpandingTildeInPath];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@/%@",ENDPOINT,method,parameter]];
	NSMutableURLRequest *theRequest = [self getHeaderForUrl:url];
    
    NSURLSessionConfiguration *defaultConfigObject = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *defaultSession = [NSURLSession sessionWithConfiguration:defaultConfigObject
                                                                 delegate:nil
                                                            delegateQueue:[NSOperationQueue mainQueue]];
    
    NSURLSessionDataTask * dataTask = [defaultSession dataTaskWithRequest:theRequest
                                                        completionHandler:^(NSData *data, NSURLResponse *response, NSError *error){
                                                            if(error == nil){
                                                                NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                                                                [self.delegate receivedDataFromServer:dictionary
                                                                                       withMethodName:method];
                                                            }
                                                            else{
                                                                [self.delegate serverError:error];
                                                            }
                                                        }];
    [dataTask resume];
}
-(void)callServerWithPOSTMethod:(NSString *)method andParameter:(NSString *)parameter httpMethod:(NSString *)httpMethod{
    parameter=[parameter stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    parameter=[parameter stringByExpandingTildeInPath];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@",ENDPOINT,method]];
	NSMutableURLRequest *theRequest = [self getHeaderForUrl:url];
    [theRequest setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [theRequest setHTTPMethod:httpMethod];
    NSData *data=[NSData dataWithBytes:[parameter UTF8String] length:[parameter length]];
    [theRequest setHTTPBody: data];
    NSURLSessionConfiguration *defaultConfigObject = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *defaultSession = [NSURLSession sessionWithConfiguration:defaultConfigObject
                                                                 delegate:nil
                                                            delegateQueue:[NSOperationQueue mainQueue]];
    
    NSURLSessionDataTask * dataTask = [defaultSession dataTaskWithRequest:theRequest
                                                    completionHandler:^(NSData *data, NSURLResponse *response, NSError *error){
                                                        if(error == nil){
                                                            NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                                                            [self.delegate receivedDataFromServer:dictionary
                                                                                   withMethodName:method];
                                                        }
                                                        else{
                                                            [self.delegate serverError:error];
                                                        }
                                                    }];
    [dataTask resume];
}
#pragma mark - http header
-(NSMutableURLRequest*)getHeaderForUrl:(NSURL*)url{
    NSString *key=@"lop+2dzuioa/000mojijiaop";
    NSString *time=[IAmCoder dateString];
    NSString *encoded=[NSString stringWithFormat:@"%@",[IAmCoder sha256:[NSString stringWithFormat:@"%@%@",key,time]]];
	NSMutableURLRequest *theRequest = [NSMutableURLRequest requestWithURL:url];
    [theRequest setValue:@"application/json" forHTTPHeaderField:@"accept"];
    [theRequest setValue:[NSString stringWithFormat:@"%@",[IAmCoder base64String:key]] forHTTPHeaderField:@"C99-RSA"];
    [theRequest setValue:[NSString stringWithFormat:@"%@",[IAmCoder base64String:time]] forHTTPHeaderField:@"SSL"];
    [theRequest setValue:encoded forHTTPHeaderField:@"token"];
    NSLog(@"Header %@\nTime %@",theRequest.allHTTPHeaderFields,time);
    return theRequest;
}
@end
