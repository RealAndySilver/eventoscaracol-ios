//
//  DestacadosViewController.m
//  EventosCaracol
//
//  Created by Developer on 22/11/13.
//  Copyright (c) 2013 iAmStudio. All rights reserved.
//

#import "DestacadosViewController.h"

#define SPECIAL_IDENTIFIER @"SpecialCell"
#define FEATURED_IDENTIFIER @"FeaturedCell"

@interface DestacadosViewController () <UICollectionViewDataSource, UICollectionViewDelegate>

@property (strong, nonatomic) NSArray *featuredEventsArray; //Of NSDictionary
@property (strong, nonatomic) NSArray *specialItemsArray; //Of NSDictionary
@property (strong, nonatomic) UICollectionView *specialItemsCollectionView;
@property (strong, nonatomic) NSTimer * timer;
@property (nonatomic) NSInteger currentPage;
@end

@implementation DestacadosViewController

#pragma mark - View Lifecycle

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.currentPage = 1;
    
    //Create a timer that fires every five seconds. this timer is used to make
    //a slide show (like a presentation) of the special events that are displayed
    //in the top ScrollView of the screen.
    self.timer = [NSTimer scheduledTimerWithTimeInterval:5.0
                                                  target:self
                                                selector:@selector(slideShowSpecialItems)
                                                userInfo:nil
                                                 repeats:YES];
    
    //Set the color properties of the NavigationBar. we have to do this every
    //time the view appears, because this properties are differente in the other
    //controllers.
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:144.0/255.0 green:192.0/255.0 blue:58.0/255.0 alpha:1.0];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor whiteColor]};
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    //Stop the timer.
    [self.timer invalidate];
    self.timer = nil;
}

-(void)viewDidLoad
{
    [super viewDidLoad];
    
    //Create the back button that will be displayed in the next view controller
    //that is push by this view controller.
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Atrás"
                                                                            style:UIBarButtonItemStylePlain
                                                                           target:self
                                                                           action:nil];

    
    //////////////////////////////////////////////////////
    //Create the back button of the NavigationBar. When pressed, this button
    //display the slide menu.
    UIBarButtonItem *sideBarButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"SidebarIcon.png"]
                                                                      style:UIBarButtonItemStylePlain
                                                                     target:self.revealViewController
                                                                     action:@selector(revealToggle:)];
    
    //Create a NavigationBar button to share the app.
    UIBarButtonItem *shareButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ShareIcon.png"]
                                                                    style:UIBarButtonItemStylePlain
                                                                   target:self
                                                                   action:nil];
    
    //Add the buttons to the NavigationBar.
    self.navigationItem.rightBarButtonItem = shareButton;
    self.navigationItem.leftBarButtonItem = sideBarButton;
    
    //Add a pan gesture to the view, that allows the user to display the slide
    //menu by panning on screen.
    [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    
    ///////////////////////////////////////////////////////////////////////////
    //Store the JSON info in a dictionary
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
    //This methods gets called every time the timer fires.
    
    //It's neccesary to know the max number of 'pages' that are going to be
    //display in the top scrollview. So, when the presentation gets to this page
    //it returns to the page 1.
    NSUInteger maxPage = [self.specialItemsArray count];
    
    //Change the content offset of the ScrollView.
    [self.specialItemsCollectionView setContentOffset:CGPointMake(self.view.frame.size.width*self.currentPage, 0.0) animated:YES];
    
    //If the presentation is in the last page, go back to page 1.
    if (self.currentPage == maxPage)
    {
        [self.specialItemsCollectionView setContentOffset:CGPointMake(0.0, 0.0) animated:YES];
        self.currentPage = 1;
    }
}

-(void)goToNextViewControllerFromItemInArray:(NSArray *)array atIndex:(NSInteger)index
{
    //If the item has an external url, we have to check if the url is going to open inside or
    //outside the application.
    if (array[index][@"external_url"])
    {
        //If the open inside value is 'no', we present the details of the item in DetailsViewController.
        if ([array[index][@"open_inside"] isEqualToString:@"no"])
        {
            DetailsViewController *detailsVC = [self.storyboard instantiateViewControllerWithIdentifier:@"EventDetails"];
            detailsVC.objectInfo = array[index];
            detailsVC.navigationBarTitle = array[index][@"name"];
            [self.navigationController pushViewController:detailsVC animated:YES];
        }
        
        //If open inside value is 'outside', we open the url externally using safari.
        else if ([array[index][@"open_inside"] isEqualToString:@"outside"])
        {
            NSURL *url = [NSURL URLWithString:array[index][@"external_url"]];
            
            //If the URL couldn't be opened, display an alert to inform the user.
            if (![[UIApplication sharedApplication] openURL:url])
            {
                [[[UIAlertView alloc] initWithTitle:nil
                                            message:@"Oops!, no se pudo abrir la URL en este momento."
                                           delegate:self
                                  cancelButtonTitle:@"" otherButtonTitles:nil] show];
            }
        }
        
        //If open inside is 'inside', display the url internally using our WebViewController.
        else
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
    //When the user selectes an item in the CollectionView's, first we have to
    //determine which CollectionView was pressed, and the index path of the
    //the selected item and pass this info to -goToNextViewControllerFromItems...,
    //method than handles the selection.
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
    //Special items CollectionView
    if (collectionView.tag == 0)
    {
        /*AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
        [appDelegate incrementNetworkActivity];*/
        
        DestacadosCollectionViewCell *specialEventCell = (DestacadosCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:SPECIAL_IDENTIFIER forIndexPath:indexPath];
        
        specialEventCell.featuredEventNameLabel.text = self.specialItemsArray[indexPath.item][@"short_detail"];
        
        NSArray *itemImagesArray = [self getDictionaryWithName:@"master"][@"imagenes"]; //Of NSDictionary
        for (int i = 0; i < [itemImagesArray count]; i++)
        {
            if ([itemImagesArray[i][@"_id"] isEqualToString:self.specialItemsArray[indexPath.row][@"thumb_url"]])
            {
                NSURL *imageURL = [NSURL URLWithString:itemImagesArray[i][@"url"]];
                [specialEventCell.featuredEventImageView setImageWithURL:imageURL
                                                        placeholderImage:[UIImage imageNamed:@"CaracolPrueba4.png"]];
            }
        }
        
        /*//Use the method -setImageURL to download the image from the server and store it in caché.
        [specialEventCell.featuredEventImageView setImageWithURL:self.specialItemsArray[indexPath.row][@"thumb_url"]
                                                placeholderImage:[UIImage imageNamed:@"CaracolPrueba4.png"]
                                                       completed:^(UIImage *image, NSError *error, SDImageCacheType type){
                                                           //[appDelegate decrementNetworkActivity];
                                                       }];*/
        
        
        return specialEventCell;
    }
    
    //Featured items collection view.
    else if (collectionView.tag == 1)
    {
        /*AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
        [appDelegate incrementNetworkActivity];*/
        
        DestacadosCollectionViewCell *featuredEventCell = (DestacadosCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:FEATURED_IDENTIFIER forIndexPath:indexPath];
        
        featuredEventCell.featuredEventNameLabel.text = self.featuredEventsArray[indexPath.item][@"short_detail"];
        NSArray *itemImagesArray = [self getDictionaryWithName:@"master"][@"imagenes"]; //Of NSDictionary
        for (int i = 0; i < [itemImagesArray count]; i++)
        {
            if ([itemImagesArray[i][@"_id"] isEqualToString:self.featuredEventsArray[indexPath.row][@"thumb_url"]])
            {
                NSURL *imageURL = [NSURL URLWithString:itemImagesArray[i][@"url"]];
                [featuredEventCell.featuredEventImageView setImageWithURL:imageURL
                                                        placeholderImage:[UIImage imageNamed:@"CaracolPrueba4.png"]];
            }
        }
        //[featuredEventCell.featuredEventImageView setImageWithURL:self.featuredEventsArray[indexPath.item][@"thumb_url"]];
        /*[featuredEventCell.featuredEventImageView setImageWithURL:self.featuredEventsArray[indexPath.row][@"thumb_url"]
                                                 placeholderImage:[UIImage imageNamed:@"CaracolPrueba4.png"]
                                                        completed:^(UIImage *image, NSError *error, SDImageCacheType type){
                                                            //[appDelegate decrementNetworkActivity];
                                                        }];*/
        
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
    {
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
            return indexPath.item % 3 ? CGSizeMake(367, 205) : CGSizeMake(collectionView.frame.size.width - 20, 205);
        else
            return indexPath.item % 3 ? CGSizeMake(144, 114):CGSizeMake(collectionView.frame.size.width - 20, 114);
    }
    
    else
        return CGSizeZero;

}

#pragma mark - UIScrollViewDelegate

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    //We use this method to determine the curren page of the special items ScrollView.
    CGFloat pageWidth = self.specialItemsCollectionView.frame.size.width;
    float fractionalPage = self.specialItemsCollectionView.contentOffset.x / pageWidth;
    self.currentPage = round(fractionalPage) + 1;
}

#pragma mark - FileSaver Stuff

-(NSDictionary*)getDictionaryWithName:(NSString*)name
{
    FileSaver *file=[[FileSaver alloc]init];
    return [file getDictionary:name];
}

-(void)setDictionary:(NSDictionary*)dictionary withName:(NSString*)name
{
    FileSaver *file=[[FileSaver alloc]init];
    [file setDictionary:dictionary withKey:name];
}

@end
