//
//  FileSaver.h
//  DroidSecure
//
//  Created by Andres Abril on 4/11/12.
//  Copyright (c) 2012 Andres Abril. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FileSaver : NSObject{
    NSDictionary *datos;
    NSDictionary *datosFriendList;
    
}
-(NSDictionary*)getDictionary:(NSString*)key;
-(void)setDictionary:(NSDictionary*)dictionary withKey:(NSString*)key;
-(NSString*)getToken;
-(void)setToken:(NSString*)token;

@end
