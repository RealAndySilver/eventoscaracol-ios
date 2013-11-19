//
//  FileSaver.m
//  DroidSecure
//
//  Created by Andres Abril on 4/11/12.
//  Copyright (c) 2012 Andres Abril. All rights reserved.
//

#import "FileSaver.h"
#define DATAFILENAME @"settings.plist"

@implementation FileSaver
-(id) init{
	if ((self = [super init])) {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
		NSString *Path = [paths objectAtIndex:0];
		//NSString *Path = [[NSBundle mainBundle] bundlePath];
		NSString *DataPath = [Path stringByAppendingPathComponent:DATAFILENAME];
		NSDictionary *tempDict = [[NSDictionary alloc] initWithContentsOfFile:DataPath];
		
        if (!tempDict) {
			tempDict = [[NSDictionary alloc] init];
		}
        datos = tempDict;
	}
	return self;
}
-(BOOL)guardar{
	NSData *xmlData;
	NSString *error;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *Path = [paths objectAtIndex:0];
	//NSString *Path = [[NSBundle mainBundle] bundlePath];
    //NSLog(@"guardar %@",datosConf);
	NSString *DataPath = [Path stringByAppendingPathComponent:DATAFILENAME];
	xmlData = [NSPropertyListSerialization dataFromPropertyList:datos format:NSPropertyListXMLFormat_v1_0 errorDescription:&error];
	if (xmlData) {
		[xmlData writeToFile:DataPath atomically:YES];
		return YES;
	} else {
		NSLog(@"Error writing plist to file '%s', error = '%s'", [DataPath UTF8String], [error UTF8String]);
		return NO;
	}
}

-(NSDictionary*)getDictionary:(NSString*)key{
    return [datos objectForKey:key];
}
-(void)setDictionary:(NSDictionary*)dictionary withKey:(NSString*)key{
	NSMutableDictionary *newData = [datos mutableCopy];
	[newData setObject:dictionary forKey:key];
	datos = newData;
	[self guardar];
}
-(NSString *)getToken{
    NSString *token=[datos objectForKey:@"Token"];
    return token;
}
-(void)setToken:(NSString *)token{
    NSMutableDictionary *newData = [datos mutableCopy];
	[newData setObject:token forKey:@"Token"];
	datos = newData;
	[self guardar];
}
@end
