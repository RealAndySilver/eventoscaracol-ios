//
//  EventDetailsViewController.h
//  EventosCaracol
//
//  Created by Developer on 20/11/13.
//  Copyright (c) 2013 iAmStudio. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DetailsViewController : UIViewController
@property (strong, nonatomic) NSDictionary *objectInfo;
@property (strong, nonatomic) NSString *navigationBarTitle;
@property (nonatomic) BOOL location;
@end
