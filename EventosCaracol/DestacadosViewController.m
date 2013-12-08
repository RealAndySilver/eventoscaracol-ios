//
//  DestacadosViewController.m
//  EventosCaracol
//
//  Created by Developer on 22/11/13.
//  Copyright (c) 2013 iAmStudio. All rights reserved.
//

#import <SDWebImage/UIImageView+WebCache.h>
#import "DestacadosViewController.h"
#import "DestacadosCollectionViewCell.h"
#import "DetailsViewController.h"
#import "SWRevealViewController.h"
#import "WebViewController.h"
#import "FileSaver.h"

#define SPECIAL_IDENTIFIER @"SpecialCell"
#define FEATURED_IDENTIFIER @"FeaturedCell"

@interface DestacadosViewController () <UICollectionViewDataSource, UICollectionViewDelegate>
{
    int currentPage;
}

@property (strong, nonatomic) NSArray *featuredEventsArray; //Of NSDictionary
@property (strong, nonatomic) NSArray *specialItemsArray; //Of NSDictionary
@property (strong, nonatomic) UICollectionView *specialItemsCollectionView;
@property (strong, nonatomic) NSTimer * timer;
//@property (strong, nonatomic) NSMutableArray *featuredEventImages; //Of UIImage;
@end

@implementation DestacadosViewController

#pragma mark - View Lifecycle

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    currentPage = 1;
    self.timer = [NSTimer scheduledTimerWithTimeInterval:5.0
                                                  target:self
                                                selector:@selector(slideShowSpecialItems)
                                                userInfo:nil
                                                 repeats:YES];
    
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:144.0/255.0 green:192.0/255.0 blue:58.0/255.0 alpha:1.0];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor whiteColor]};
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    NSLog(@"Desaparecí");
    
    [self.timer invalidate];
    self.timer = nil;
}

-(void)viewDidLoad
{
    [super viewDidLoad];
    //NSLog(@"ViewDidLoad");
    //[self.navigationItem setHidesBackButton:YES];
    
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:144.0/255.0 green:192.0/255.0 blue:58.0/255.0 alpha:1.0];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor whiteColor]};
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Atrás"
                                                                            style:UIBarButtonItemStylePlain
                                                                           target:self
                                                                           action:nil];

    
    //////////////////////////////////////////////////////
    //Side bar menu button
    UIBarButtonItem *sideBarButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"SidebarIcon.png"]
                                                                      style:UIBarButtonItemStylePlain
                                                                     target:self.revealViewController
                                                                     action:@selector(revealToggle:)];
    UIBarButtonItem *shareButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ShareIcon.png"]
                                                                    style:UIBarButtonItemStylePlain
                                                                   target:self
                                                                   action:nil];
    self.navigationItem.rightBarButtonItem = shareButton;
    self.navigationItem.leftBarButtonItem = sideBarButton;
    
    [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    
    //////////////////////////////////////////////////////////
    //Store the JSON info in a dictionary
    //self.fileSaver = [[FileSaver alloc] init];
    NSDictionary *myDictionary = [self getDictionaryWithName:@"master"][@"app"];
    self.navigationItem.title = [myDictionary objectForKey:@"name"];
    
    //define an array with only the featured events information
    self.featuredEventsArray = [self getDictionaryWithName:@"master"][@"destacados"];
    
    //Define an array with the special items
    self.specialItemsArray = [self getDictionaryWithName:@"master"][@"especiales"];
    
    /////////////////////////////////////////////////////////////
    //Create UICollectionView to display the special items
    UICollectionViewFlowLayout *specialItemsCollectionViewLayout = [[UICollectionViewFlowLayout alloc] init];
    specialItemsCollectionViewLayout.minimumInteritemSpacing = 0;
    specialItemsCollectionViewLayout.minimumLineSpacing = 0;
    specialItemsCollectionViewLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    self.specialItemsCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0.0, self.navigationController.navigationBar.frame.origin.y + self.navigationController.navigationBar.frame.size.height + 10.0, self.view.frame.size.width, self.view.frame.size.height/4.3) collectionViewLayout:specialItemsCollectionViewLayout];
    self.specialItemsCollectionView.tag = 0;
    self.specialItemsCollectionView.dataSource = self;
    self.specialItemsCollectionView.delegate = self;
    self.specialItemsCollectionView.alwaysBounceHorizontal = YES;
    self.specialItemsCollectionView.pagingEnabled = YES;
    [self.specialItemsCollectionView registerClass:[DestacadosCollectionViewCell class] forCellWithReuseIdentifier:SPECIAL_IDENTIFIER];
    self.specialItemsCollectionView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.specialItemsCollectionView];
    
    /////////////////////////////////////////////////////////
    //Create UICollectionView that display the list of featured items
    UICollectionViewFlowLayout *collectionViewLayout = [[UICollectionViewFlowLayout alloc] init];
    UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0.0, self.specialItemsCollectionView.frame.origin.y + self.specialItemsCollectionView.frame.size.height + 10.0, self.view.frame.size.width, self.view.frame.size.height - (self.specialItemsCollectionView.frame.origin.y + self.specialItemsCollectionView.frame.size.height + 20.0)) collectionViewLayout:collectionViewLayout];
    collectionView.tag = 1;
    collectionView.dataSource = self;
    [collectionView setAlwaysBounceVertical:YES];
    collectionView.contentInset = UIEdgeInsetsMake(0.0, 10.0, 0.0, 10.0);
    collectionView.delegate = self;
    [collectionView registerClass:[DestacadosCollectionViewCell class] forCellWithReuseIdentifier:FEATURED_IDENTIFIER];
    collectionView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:collectionView];
}

#pragma mark - Custom Methods

-(void)slideShowSpecialItems
{
    NSLog(@"el timer me activó");
    int maxPage = [self.specialItemsArray count];
    [self.specialItemsCollectionView setContentOffset:CGPointMake(self.view.frame.size.width*currentPage, 0.0) animated:YES];
    //currentPage++;
    if (currentPage == maxPage)
    {
        NSLog(@"llegué a la útima página");
        [self.specialItemsCollectionView setContentOffset:CGPointMake(0.0, 0.0) animated:YES];
        currentPage = 1;
    }
}

-(void)goToNextViewControllerFromItemInArray:(NSArray *)array atIndex:(NSInteger)index
{
    //If the item has an external url, we have to check if the url is going to open inside or
    //outside the application.
    if (array[index][@"external_url"])
    {
        if ([array[index][@"open_inside"] isEqualToString:@"no"])
        {
            DetailsViewController *detailsVC = [self.storyboard instantiateViewControllerWithIdentifier:@"EventDetails"];
            detailsVC.objectInfo = array[index];
            detailsVC.navigationBarTitle = array[index][@"name"];
            [self.navigationController pushViewController:detailsVC animated:YES];
        }
        
        else if ([array[index][@"open_inside"] isEqualToString:@"outside"])
        {
            NSURL *url = [NSURL URLWithString:array[index][@"external_url"]];
            if (![[UIApplication sharedApplication] openURL:url])
            {
                [[[UIAlertView alloc] initWithTitle:nil
                                            message:@"Oops!, no se pudo abrir la URL en este momento."
                                           delegate:self
                                  cancelButtonTitle:@"" otherButtonTitles:nil] show];
            }
        }
        
        else //Else if open_inside = inside
        {
            WebViewController *webViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"Web"];
            webViewController.urlString = array[index][@"external_url"];
            [self.navigationController pushViewController:webViewController animated:YES];
        }
    }
    
    //if the item doesn't have an external url, open the detail view.
    else
    {
        DetailsViewController *detailsVC = [self.storyboard instantiateViewControllerWithIdentifier:@"EventDetails"];
        detailsVC.objectInfo = array[index];
        detailsVC.navigationBarTitle = array[index][@"name"];
        [self.navigationController pushViewController:detailsVC animated:YES];
    }

}

#pragma mark - UICollectionViewDelegate & UICollectionViewDataSource

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (collectionView.tag == 0)
        [self goToNextViewControllerFromItemInArray:self.specialItemsArray atIndex:indexPath.row];
    
    if (collectionView.tag == 1)
        [self goToNextViewControllerFromItemInArray:self.featuredEventsArray atIndex:indexPath.row];
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if (collectionView.tag == 0)
    {
        return [self.specialItemsArray count];
    }
    
    else if (collectionView.tag == 1)
        return [self.featuredEventsArray count];
    else
        return 0;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (collectionView.tag == 0)
    {
        DestacadosCollectionViewCell *specialEventCell = (DestacadosCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:SPECIAL_IDENTIFIER forIndexPath:indexPath];
        
        specialEventCell.featuredEventNameLabel.text = self.specialItemsArray[indexPath.item][@"short_detail"];
        [specialEventCell.featuredEventImageView setImageWithURL:self.specialItemsArray[indexPath.row][@"thumb_url"]
                                                placeholderImage:[UIImage imageNamed:@"CaracolPrueba4.png"]];
        
        
        return specialEventCell;
    }
    
    else if (collectionView.tag == 1)
    {
        DestacadosCollectionViewCell *featuredEventCell = (DestacadosCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:FEATURED_IDENTIFIER forIndexPath:indexPath];
        
        featuredEventCell.featuredEventNameLabel.text = self.featuredEventsArray[indexPath.item][@"short_detail"];
        //[featuredEventCell.featuredEventImageView setImageWithURL:self.featuredEventsArray[indexPath.item][@"thumb_url"]];
        [featuredEventCell.featuredEventImageView setImageWithURL:self.featuredEventsArray[indexPath.row][@"thumb_url"]
                                                 placeholderImage:[UIImage imageNamed:@"CaracolPrueba4.png"]];
        
        return featuredEventCell;
    }
    else
        return nil;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (collectionView.tag == 0)
        return CGSizeMake(self.view.frame.size.width, self.view.frame.size.height/4.3);
    
    else if (collectionView.tag == 1)
        return indexPath.item % 3 ? CGSizeMake(self.view.frame.size.width/2.22, self.view.frame.size.height/4.98) :
                CGSizeMake(collectionView.frame.size.width - 20, self.view.frame.size.height/4.98);
        //return indexPath.item % 3 ? CGSizeMake(144, 114):CGSizeMake(collectionView.frame.size.width - 20, 114);
    
    else
        return CGSizeZero;

}

#pragma mark - UIScrollViewDelegate

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat pageWidth = self.specialItemsCollectionView.frame.size.width;
    float fractionalPage = self.specialItemsCollectionView.contentOffset.x / pageWidth;
    currentPage = lround(fractionalPage) + 1;
    //NSLog(@"Page: %d", currentPage);
}

#pragma mark - FileSaver Stuff

-(NSDictionary*)getDictionaryWithName:(NSString*)name{
    FileSaver *file=[[FileSaver alloc]init];
    return [file getDictionary:name];
}
-(void)setDictionary:(NSDictionary*)dictionary withName:(NSString*)name{
    FileSaver *file=[[FileSaver alloc]init];
    [file setDictionary:dictionary withKey:name];
}

@end
