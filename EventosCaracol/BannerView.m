//
//  BannerView.m
//  EventosCaracol
//
//  Created by Developer on 7/02/14.
//  Copyright (c) 2014 iAmStudio. All rights reserved.
//

#import "BannerView.h"

@implementation BannerView

+(void)showBannerOverView:(UIView *)view withImage:(UIImage *)image {
    UIView *banner = [[UIView alloc] initWithFrame:CGRectMake(0.0, view.frame.size.height - 44.0, view.frame.size.width, 44.0)];
    banner.backgroundColor = [UIColor colorWithRed:29.0/255.0 green:80.0/255.0 blue:204.0/255.0 alpha:1.0];
    [view addSubview:banner];
    
    [UIView animateWithDuration:3.0
                          delay:3.0
                        options:UIViewAnimationOptionCurveLinear animations:^(void){
                            banner.alpha = 0.0;
                        }
                     completion:^(BOOL finished){
                         [banner removeFromSuperview];
                     }];
}

@end
