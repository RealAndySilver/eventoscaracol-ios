//
//  WebViewController.h
//  EventosCaracol
//
//  Created by Developer on 5/12/13.
//  Copyright (c) 2013 iAmStudio. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WebViewController : UIViewController <UIWebViewDelegate>
@property (strong, nonatomic) NSString *urlString;
@end
