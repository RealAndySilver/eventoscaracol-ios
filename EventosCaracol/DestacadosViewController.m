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
#import "FileSaver.h"

#define SPECIAL_IDENTIFIER @"SpecialCell"
#define FEATURED_IDENTIFIER @"FeaturedCell"

@interface DestacadosViewController () <UICollectionViewDataSource, UICollectionViewDelegate>
//@property (strong, nonatomic) FileSaver *fileSaver;
//@property (strong, nonatomic) UICollectionView *collectionView;
@property (strong, nonatomic) NSArray *featuredEventsArray; //Of NSDictionary
@property (strong, nonatomic) NSArray *specialItemsArray; //Of NSDictionary
//@property (strong, nonatomic) NSMutableArray *featuredEventImages; //Of UIImage;
@end

@implementation DestacadosViewController

-(void)viewDidLoad
{
    [super viewDidLoad];
    NSLog(@"ViewDidLoad");
    [self.navigationItem setHidesBackButton:YES];
    
    //////////////////////////////////////////////////////
    //Side bar menu button
    UIBarButtonItem *sideBarButton = [[UIBarButtonItem alloc] initWithTitle:@"SideBar"
                                                                      style:UIBarButtonItemStylePlain
                                                                     target:self.revealViewController
                                                                     action:@selector(revealToggle:)];
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
    UICollectionView *specialItemsCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0.0, self.navigationController.navigationBar.frame.origin.y + self.navigationController.navigationBar.frame.size.height, self.view.frame.size.width, self.view.frame.size.height/4.3) collectionViewLayout:specialItemsCollectionViewLayout];
    specialItemsCollectionView.tag = 0;
    specialItemsCollectionView.dataSource = self;
    specialItemsCollectionView.delegate = self;
    specialItemsCollectionView.alwaysBounceHorizontal = YES;
    specialItemsCollectionView.pagingEnabled = YES;
    [specialItemsCollectionView registerClass:[DestacadosCollectionViewCell class] forCellWithReuseIdentifier:SPECIAL_IDENTIFIER];
    specialItemsCollectionView.backgroundColor = [UIColor orangeColor];
    [self.view addSubview:specialItemsCollectionView];
    
    /////////////////////////////////////////////////////////
    //Create UICollectionView that display the list of featured items
    UICollectionViewFlowLayout *collectionViewLayout = [[UICollectionViewFlowLayout alloc] init];
    UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0.0, specialItemsCollectionView.frame.origin.y + specialItemsCollectionView.frame.size.height + 10.0, self.view.frame.size.width, self.view.frame.size.height - (specialItemsCollectionView.frame.origin.y + specialItemsCollectionView.frame.size.height + 20.0)) collectionViewLayout:collectionViewLayout];
    collectionView.tag = 1;
    collectionView.dataSource = self;
    [collectionView setAlwaysBounceVertical:YES];
    collectionView.contentInset = UIEdgeInsetsMake(0.0, 10.0, 0.0, 10.0);
    collectionView.delegate = self;
    [collectionView registerClass:[DestacadosCollectionViewCell class] forCellWithReuseIdentifier:FEATURED_IDENTIFIER];
    collectionView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:collectionView];
}

#pragma mark - UICollectionViewDelegate & UICollectionViewDataSource

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (collectionView.tag == 1)
    {
        DetailsViewController *detailsVC = [self.storyboard instantiateViewControllerWithIdentifier:@"EventDetails"];
        
        //We pass the object that was selected to the next view controller
        detailsVC.objectInfo = self.featuredEventsArray[indexPath.item];
        detailsVC.navigationBarTitle = self.featuredEventsArray[indexPath.item][@"name"];
        [self.navigationController pushViewController:detailsVC animated:YES];
    }
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
        
        [specialEventCell.featuredEventImageView setImageWithURL:self.specialItemsArray[indexPath.row][@"thumb_url"]
                                                placeholderImage:[UIImage imageNamed:@"CaracolPrueba4.png"]];
        
        return specialEventCell;
    }
    
    else if (collectionView.tag == 1)
    {
        DestacadosCollectionViewCell *featuredEventCell = (DestacadosCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:FEATURED_IDENTIFIER forIndexPath:indexPath];
        
        featuredEventCell.featuredEventNameLabel.text = self.featuredEventsArray[indexPath.item][@"name"];
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
        return indexPath.item % 3 ? CGSizeMake(144, 114):CGSizeMake(collectionView.frame.size.width - 20, 114);
    
    else
        return CGSizeZero;

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
