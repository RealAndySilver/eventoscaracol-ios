//
//  PopUpView.m
//  EventosCaracol
//
//  Created by Developer on 22/11/13.
//  Copyright (c) 2013 iAmStudio. All rights reserved.
//

#import "PopUpView.h"

@implementation PopUpView

+(void)showPopUpViewOverView:(UIView*)view image:(UIImage *)image
{
    
    UIImageView *heartView = [[UIImageView alloc] initWithFrame:CGRectMake(50.0,
                                                                 view.frame.size.height/2 - (view.frame.size.width-100)/2,
                                                                 view.frame.size.width - 100 ,
                                                                 view.frame.size.width - 100)];
    
    heartView.alpha = 0.0;
    if (!image)
        heartView.image = [UIImage imageNamed:@"CorazonRojo.png"];
    else
        heartView.image = image;
    
    
    //Container view for heartView
    UIView *containerHeartView = [[UIView alloc] initWithFrame:CGRectMake(view.frame.origin.x, view.frame.origin.y, view.frame.size.width, view.frame.size.height)];
    containerHeartView.backgroundColor = [UIColor clearColor];
    [containerHeartView addSubview:heartView];
    
    [view addSubview:containerHeartView];
    
    //View Animation
    [UIView animateWithDuration:0.5
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^(){
                         heartView.alpha = 1.0;
                     }
                     completion:^(BOOL finished){
                         [UIView animateWithDuration:0.5
                                               delay:1.0
                                             options:UIViewAnimationOptionCurveEaseInOut
                                          animations:^(){
                                              heartView.alpha = 0.0;
                                          }
                                          completion:^(BOOL finished){
                                              [containerHeartView removeFromSuperview];
                                          }];
                     }];
}

@end
