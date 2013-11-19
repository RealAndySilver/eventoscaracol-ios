//
//  ServerCommunicator.h
//  WebConsumer
//
//  Created by Andres Abril on 19/04/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
@protocol ServerCommunicatorDelegate
@optional
-(void)receivedDataFromServer:(NSDictionary*)dictionary withMethodName:(NSString*)methodName;
-(void)serverError:(NSError*)error;

@end
@interface ServerCommunicator : NSObject<UITextFieldDelegate,NSXMLParserDelegate,UIApplicationDelegate>{
}
@property int tag;
@property (nonatomic,retain) id<ServerCommunicatorDelegate> delegate;

-(void)callServerWithGETMethod:(NSString*)method andParameter:(NSString*)parameter;
-(void)callServerWithPOSTMethod:(NSString*)method andParameter:(NSString*)parameter httpMethod:(NSString*)httpMethod;

@end
