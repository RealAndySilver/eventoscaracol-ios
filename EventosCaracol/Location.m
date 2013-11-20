//
//  Location.m
//  EventosCaracol
//
//  Created by Developer on 20/11/13.
//  Copyright (c) 2013 iAmStudio. All rights reserved.
//

#import "Location.h"

@implementation Location

-(instancetype)initWithDictionary:(NSDictionary *)dictionary
{
    if (self = [super init])
    {
        _appID = dictionary[@"app_id"];
        _placeName = dictionary[@"place_name"];
        _detail = dictionary[@"detail"];
        _shortDetail = dictionary[@"short_detail"];
        _lat = [dictionary[@"lat"] doubleValue];
        _lon  = [dictionary[@"lon"] doubleValue];
        _creationDate = dictionary[@"creation_date"];
        _thumbURL = dictionary[@"thumb_url"];
        _imageURL = dictionary[@"image_url"];
        _type = dictionary[@"type"];
    }
    
    return self;
}

@end
