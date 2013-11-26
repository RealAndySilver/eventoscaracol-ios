//
//  DestacadosViewController.m
//  EventosCaracol
//
//  Created by Developer on 22/11/13.
//  Copyright (c) 2013 iAmStudio. All rights reserved.
//

#import "DestacadosViewController.h"
#import "DestacadosCollectionViewCell.h"
#import "EventDetailsViewController.h"
#import "SWRevealViewController.h"
#import "FileSaver.h"

@interface DestacadosViewController () <UICollectionViewDataSource, UICollectionViewDelegate>
@property (strong, nonatomic) FileSaver *fileSaver;
@property (strong, nonatomic) UICollectionView *collectionView;
@property (strong, nonatomic) NSArray *featuredEventsArray; //Of NSDictionary
@property (strong, nonatomic) NSMutableArray *featuredEventImages; //Of UIImage;
@end

@implementation DestacadosViewController

-(void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.navigationItem setHidesBackButton:YES];
    
    //////////////////////////////////////////////////////
    //Side bar menu button
    UIBarButtonItem *sideBarButton = [[UIBarButtonItem alloc] initWithTitle:@"SideBar"
                                                                      style:UIBarButtonItemStylePlain
                                                                     target:self.revealViewController
                                                                     action:@selector(revealToggle:)];
    self.navigationItem.leftBarButtonItem = sideBarButton;
    
    [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    
    
    //Create an array to store the thumbs images to display
    self.featuredEventImages = [[NSMutableArray alloc] init];
    
    //////////////////////////////////////////////////////////
    //Store the JSON info in a dictionary
    self.fileSaver = [[FileSaver alloc] init];
    NSDictionary *myDictionary = [self.fileSaver getDictionary:@"master"][@"app"];
    self.navigationItem.title = [myDictionary objectForKey:@"name"];
    
    //define an array with only the featured events information
    self.featuredEventsArray = [self.fileSaver getDictionary:@"master"][@"featured"];
    
    ////////////////////////////////////////////////////////////////
    //Access the web to download the thumbs images to display, and
    //store those images into featuresEventImages array.
    /*for (int i = 0; i < [self.featuredEventsArray count]; i++)
    {
        NSURL *url = [NSURL URLWithString:self.featuredEventsArray[i][@"thumb_url"]];
        UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:url]];
        self.featuredEventImages[i] = image;
    }*/
    
    /////////////////////////////////////////////////////////
    //Create UICollectionView
    UICollectionViewFlowLayout *collectionViewLayout = [[UICollectionViewFlowLayout alloc] init];
    /*self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(10.0, self.navigationController.navigationBar.frame.size.height + 30.0, self.view.frame.size.width - 20.0, self.view.frame.size.height - (self.navigationController.navigationBar.frame.size.height + 30.0))
                                             collectionViewLayout:collectionViewLayout];*/
    self.collectionView = [[UICollectionView alloc] initWithFrame:self.view.frame collectionViewLayout:collectionViewLayout];
    
    self.collectionView.dataSource = self;
    [self.collectionView setAlwaysBounceVertical:YES];
    self.collectionView.contentInset = UIEdgeInsetsMake(self.navigationController.navigationBar.frame.size.height + 30.0, 10.0, 10.0, 10.0);
    self.collectionView.delegate = self;
    [self.collectionView registerClass:[DestacadosCollectionViewCell class] forCellWithReuseIdentifier:@"featuredCell"];
    self.collectionView.backgroundColor = [UIColor clearColor];
    
    [self.view addSubview:self.collectionView];
}

#pragma mark - UICollectionViewDelegate & UICollectionViewDataSource

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"me seleccioné");
    EventDetailsViewController *eventDetailsVC = [self.storyboard instantiateViewControllerWithIdentifier:@"EventDetails"];
    [self.navigationController pushViewController:eventDetailsVC animated:YES];
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    NSLog(@"%lu", (unsigned long)[self.featuredEventsArray count]);
    return [self.featuredEventsArray count];
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    DestacadosCollectionViewCell *featuredEventCell = (DestacadosCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"featuredCell" forIndexPath:indexPath];
    
    //featuredEventCell.featuredEventImageView.image = self.featuredEventImages[indexPath.item];
    featuredEventCell.featuredEventNameLabel.text = self.featuredEventsArray[indexPath.item][@"name"];
    [featuredEventCell.spinner startAnimating];
    
    dispatch_queue_t imageLoader = dispatch_queue_create("ImageLoader", nil);
    dispatch_async(imageLoader, ^(){
        NSURL *url = [NSURL URLWithString:self.featuredEventsArray[indexPath.item][@"thumb_url"]];
        UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:url]];
        dispatch_async(dispatch_get_main_queue(), ^(){
            if (image)
            {
                featuredEventCell.featuredEventImageView.image = image;
            }
            [featuredEventCell.spinner stopAnimating];
        });
    });
    
    return featuredEventCell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
        return indexPath.item % 3 ? CGSizeMake(144, 115):CGSizeMake(self.collectionView.frame.size.width - 20, 115.0);
}

@end
