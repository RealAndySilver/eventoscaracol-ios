//
//  Location.h
//  EventosCaracol
//
//  Created by Developer on 20/11/13.
//  Copyright (c) 2013 iAmStudio. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Location : NSObject

@property (strong, nonatomic) NSString *appID;
@property (strong, nonatomic) NSString *placeName;
@property (strong, nonatomic) NSString *detail;
@property (strong, nonatomic) NSString *shortDetail;
@property (nonatomic) double lat;
@property (nonatomic) double lon;
@property (strong, nonatomic) NSDate *creationDate;
@property (strong, nonatomic) NSString *thumbURL;
@property (strong, nonatomic) NSArray *imageURL;
@property (strong, nonatomic) NSString *type;

-(instancetype)initWithDictionary:(NSDictionary *)dictionary;

@end
