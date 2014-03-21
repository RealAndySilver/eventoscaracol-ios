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
@property (strong, nonatomic) NSArray *imagesNamesArray;
@end

@implementation TutorialViewController

-(NSArray *)imagesNamesArray {
    if (!_imagesNamesArray) {
        _imagesNamesArray = @[@"ayudas_slide1.png", @"ayudas_slide2.png", @"ayudas_slide3.png", @"ayudas_slide4.png", @"ayudas_slide5.png"];
    }
    return _imagesNamesArray;
}

-(void)viewDidLoad
{
    [super viewDidLoad];
    
    //////////////////////////////////////////////////////
    //Create a ScrollView to display the pages of the tutorial
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0.0,
                                                                     0.0,
                                                                     self.view.frame.size.width,
                                                                     self.view.frame.size.height)];
    self.scrollView.pagingEnabled = YES;
    self.scrollView.delegate = self;
    [self.scrollView setShowsHorizontalScrollIndicator:NO];
    [self.view addSubview:self.scrollView];
    
    ///////////////////////////////////////////////////////
    //Create the pages
    int j=0;
    for (int i=0; i<5; i++) {
        [self createPage:i+1 withImage:[UIImage imageNamed:self.imagesNamesArray[i]]];
        j=i+1;
    }
    self.scrollView.contentSize = CGSizeMake(_scrollView.frame.size.width*j, self.view.frame.size.height);
    
    ///////////////////////////////////////////////////////
    //Create a page control to show the user the current page
    self.pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(self.view.frame.size.width/2- 50.0,
                                                                       self.view.frame.size.height/1.33,
                                                                       100.0,
                                                                       37.0)];
    self.pageControl.numberOfPages = j;
    self.pageControl.pageIndicatorTintColor = [UIColor lightGrayColor];
    self.pageControl.currentPageIndicatorTintColor = [UIColor colorWithRed:249.0/255.0 green:170.0/255.0 blue:0.0 alpha:1.0];
    [self.view bringSubviewToFront:self.pageControl];
    [self.view addSubview:self.pageControl];
    
    //////////////////////////////////////////////////////
    //Create a button to close the tutorial
    UIButton *enterButton = [[UIButton alloc] initWithFrame:CGRectMake(self.view.frame.size.width/2,
                                                                       20.0,
                                                                       self.view.frame.size.width/2 - 20.0,
                                                                       50.0)];
    [enterButton setTitle:@"Omitir" forState:UIControlStateNormal];
    [enterButton setTitleColor:[UIColor colorWithRed:36.0/255.0 green:56.0/255.0 blue:141.0/255.0 alpha:1.0] forState:UIControlStateNormal];
    enterButton.titleLabel.font = [UIFont fontWithName:@"Montserrat-Regular" size:17.0];
    enterButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    [enterButton addTarget:self
                    action:@selector(dismissVC) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:enterButton];
}
-(void)createPage:(int)pageNumber withImage:(UIImage*)image
{
    UIView *page=[[UIView alloc]initWithFrame:CGRectMake(_scrollView.frame.size.width*(pageNumber-1), 0, _scrollView.frame.size.width, _scrollView.frame.size.height)];
    UIImageView *tutorialIMageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0,
                                                                                   0.0,
                                                                                   self.view.frame.size.width,
                                                                                   self.view.frame.size.height)];
    tutorialIMageView.clipsToBounds = YES;
    tutorialIMageView.contentMode = UIViewContentModeScaleAspectFit;
    tutorialIMageView.image = image;
    [page addSubview:tutorialIMageView];
    [_scrollView addSubview:page];
}

-(void)dismissVC
{
    if (self.tutorialWasPresentedFromSideMenu) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"StatusBarMustBeOpaqueNotification" object:nil userInfo:nil];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
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
