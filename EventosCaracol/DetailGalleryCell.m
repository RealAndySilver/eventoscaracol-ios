//
//  DetailGalleryCell.m
//  EventosCaracol
//
//  Created by Developer on 15/10/14.
//  Copyright (c) 2014 iAmStudio. All rights reserved.
//

#import "DetailGalleryCell.h"

@implementation DetailGalleryCell

-(instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.galleryImageView = [[UIImageView alloc] init];
        self.galleryImageView.backgroundColor = [UIColor cyanColor];
        self.galleryImageView.contentMode = UIViewContentModeScaleAspectFill;
        [self.contentView addSubview:self.galleryImageView];
    }
    return self;
}

-(void)layoutSubviews {
    [super layoutSubviews];
    CGRect bounds = self.contentView.bounds;
    self.galleryImageView.frame = CGRectMake(0.0, 0.0, bounds.size.width, bounds.size.height);
}

@end
