//
//  TutorialViewController.m
//  EventosCaracol
//
//  Created by Developer on 29/11/13.
//  Copyright (c) 2013 iAmStudio. All rights reserved.
//

#import "TutorialViewController.h"

@interface TutorialViewController ()
@property (strong, nonatomic) UIScrollView *scrollView;
@property (strong, nonatomic) UIPageControl *pageControl;
@end

@implementation TutorialViewController

-(void)viewDidLoad
{
    [super viewDidLoad];
    
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0.0,
                                                                     0.0,
                                                                     self.view.frame.size.width,
                                                                     self.view.frame.size.height)];
    self.scrollView.pagingEnabled = YES;
    self.scrollView.delegate = self;
    [self.view addSubview:self.scrollView];
    
    
    int j=0;
    for (int i=0; i<5; i++) {
        [self createPage:i+1 withImage:[UIImage imageNamed:@"CaracolPrueba.jpg"]];
        j=i+1;
    }
    self.scrollView.contentSize = CGSizeMake(_scrollView.frame.size.width*j, self.view.frame.size.height);

    self.pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(self.view.frame.size.width/2- 50.0,
                                                                       self.view.frame.size.height/1.2,
                                                                       100.0,
                                                                       37.0)];
    self.pageControl.backgroundColor = [[UIColor blueColor] colorWithAlphaComponent:0.5];
    self.pageControl.numberOfPages = j;
    [self.view addSubview:self.pageControl];
    
    UIButton *enterButton = [[UIButton alloc] initWithFrame:CGRectMake(self.view.frame.size.width/2 - 25,
                                                                       50.0,
                                                                       50.0,
                                                                       50.0)];
    [enterButton setTitle:@"X" forState:UIControlStateNormal];
    [self.view addSubview:enterButton];
}
-(void)createPage:(int)pageNumber withImage:(UIImage*)image{
    UIView *page=[[UIView alloc]initWithFrame:CGRectMake(_scrollView.frame.size.width*(pageNumber-1), 0, _scrollView.frame.size.width, _scrollView.frame.size.height)];
    UIImageView *tutorialIMageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0,
                                                                                   0.0,
                                                                                   self.view.frame.size.width,
                                                                                   self.view.frame.size.height)];
    tutorialIMageView.image = image;
    [page addSubview:tutorialIMageView];
    [_scrollView addSubview:page];
}

#pragma mark - ScrollViewDelegate

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat pageWidth = self.scrollView.frame.size.width;
    float fractionalPage = self.scrollView.contentOffset.x / pageWidth;
    NSInteger page = lround(fractionalPage);
    self.pageControl.currentPage = page;
}

@end
