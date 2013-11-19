//
//  ServerCommunicator.m
//  WebConsumer
//
//  Created by Andres Abril on 19/04/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ServerCommunicator.h"
#define ENDPOINT @"http://10.0.1.7:4000"
//#define ENDPOINT @"http://iamstudio-sweetwater.herokuapp.com/"
//#define ENDPOINT @"http://sweetwater.jit.su"

@implementation ServerCommunicator
@synthesize tag,delegate;
-(id)init {
    self = [super init];
    if (self) {
        tag = 0;
    }
    return self;
}
-(void)callServerWithGETMethod:(NSString*)method andParameter:(NSString*)parameter{
    parameter=[parameter stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    parameter=[parameter stringByExpandingTildeInPath];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@/%@",ENDPOINT,method,parameter]];
	NSMutableURLRequest *theRequest = [NSMutableURLRequest requestWithURL:url];
    [theRequest setValue:@"application/json" forHTTPHeaderField:@"accept"];
    
    NSURLSessionConfiguration *defaultConfigObject = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *defaultSession = [NSURLSession sessionWithConfiguration:defaultConfigObject
                                                                 delegate:nil
                                                            delegateQueue:[NSOperationQueue mainQueue]];
    
    NSURLSessionDataTask * dataTask = [defaultSession dataTaskWithURL:url
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
	NSMutableURLRequest *theRequest = [NSMutableURLRequest requestWithURL:url];
    [theRequest setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [theRequest setValue:@"application/json" forHTTPHeaderField:@"accept"];
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
@end
