//
//  MapViewController.h
//  EventosCaracol
//
//  Created by Developer on 27/11/13.
//  Copyright (c) 2013 iAmStudio. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MapViewController : UIViewController <UIPickerViewDataSource, UIPickerViewDelegate, SWRevealViewControllerDelegate>
@property (strong, nonatomic) NSString *navigationBarTitle;
@property (strong, nonatomic) NSString *menuID;
@property (strong, nonatomic) NSString *objectType;
@property (strong, nonatomic) NSArray *locationsArray;
@property (strong, nonatomic) NSString *filter1ID;
@property (strong, nonatomic) NSString *filter2ID;
@property (strong, nonatomic) NSString *filter1Name;
@property (strong, nonatomic) NSString *filter2Name;
@property (assign, nonatomic) NSUInteger numberOfFilters;
@end
