//
//  Atom.m
//  EventosCaracol
//
//  Created by Developer on 20/11/13.
//  Copyright (c) 2013 iAmStudio. All rights reserved.
//

#import "Atom.h"

@implementation Atom

-(instancetype)initWithDictionary:(NSDictionary *)dictionary
{
    if (self == [super init])
    {
        _appID = dictionary[@"app_id"];
        _appName = dictionary[@"app_name"];
        _menuItemID = dictionary[@"menu_item_id"];
        _type = dictionary[@"type"];
        _name = dictionary[@"name"];
        _eventTime = dictionary[@"event_time"];
        _detail = dictionary[@"detail"];
        _shortDetail = dictionary[@"short_detail"];
        _locationID = dictionary[@"location_id"];
        _imageURL = dictionary[@"image_url"];
        _thumbURL = dictionary[@"thumb_url"];
        _category = dictionary[@"category"];
    }
    
    return self;
}

@end
