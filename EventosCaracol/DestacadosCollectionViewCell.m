//
//  DestacadosCollectionViewCell.m
//  EventosCaracol
//
//  Created by Developer on 22/11/13.
//  Copyright (c) 2013 iAmStudio. All rights reserved.
//

#import "DestacadosCollectionViewCell.h"

@implementation DestacadosCollectionViewCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.backgroundColor = [UIColor clearColor];
        
        self.featuredEventNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0,
                                                                           self.contentView.bounds.size.height - 40.0,
                                                                           self.contentView.bounds.size.width,
                                                                           self.contentView.bounds.size.height - (self.contentView.bounds.size.height - 40.0))];
        self.featuredEventNameLabel.textAlignment = NSTextAlignmentCenter;
        
        self.featuredEventImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0,
                                                                                    0,
                                                                                    self.contentView.bounds.size.width,
                                                                                    self.contentView.bounds.size.height)];
        [self.featuredEventImageView setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
        [self.featuredEventImageView setContentMode:UIViewContentModeScaleAspectFit];
        self.contentView.backgroundColor = [UIColor cyanColor];
        [self.contentView addSubview:self.featuredEventImageView];
        [self.contentView addSubview:self.featuredEventNameLabel];
    }
    return self;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}


@end
