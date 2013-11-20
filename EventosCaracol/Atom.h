//
//  Atom.h
//  EventosCaracol
//
//  Created by Developer on 20/11/13.
//  Copyright (c) 2013 iAmStudio. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Atom : NSObject

@property (strong, nonatomic) NSString *appID;
@property (strong, nonatomic) NSString *appName;
@property (strong, nonatomic) NSString *menuItemID;
@property (strong, nonatomic) NSString *type;
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSDate *publishTime;
@property (strong, nonatomic) NSDate *eventTime;
@property (strong, nonatomic) NSString *detail;
@property (strong, nonatomic) NSString *shortDetail;
@property (strong, nonatomic) NSString *locationID;
@property (strong, nonatomic) NSArray *imageURL;
@property (strong, nonatomic) NSString *thumbURL;
@property (strong, nonatomic) NSString *category;

-(instancetype)initWithDictionary:(NSDictionary *)dictionary;

@end
