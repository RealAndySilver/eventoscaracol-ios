//
//  MenuTableViewCell.m
//  EventosCaracol
//
//  Created by Developer on 26/11/13.
//  Copyright (c) 2013 iAmStudio. All rights reserved.
//

#import "MenuTableViewCell.h"

@implementation MenuTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor clearColor];
        
        self.menuItemLabel = [[UILabel alloc] init ];
        self.menuItemLabel.font = [UIFont fontWithName:@"Montserrat-Regular" size:15.0];
        self.menuItemLabel.textColor = [UIColor colorWithRed:243.0/255.0 green:195.0/255.0 blue:23.0/255.0 alpha:1.0];
        [self.contentView addSubview:self.menuItemLabel];
        
        self.menuItemImageView = [[UIImageView alloc] init];
        self.menuItemImageView.backgroundColor = [UIColor clearColor];
        self.menuItemImageView.clipsToBounds = YES;
        [self.menuItemImageView setContentMode:UIViewContentModeScaleAspectFill];
        [self.contentView addSubview:self.menuItemImageView];
    }
    return self;
}

-(void)layoutSubviews {
    [super layoutSubviews];
    CGRect bounds = self.contentView.bounds;
    self.menuItemLabel.frame = CGRectMake(60.0,
                                          self.contentView.frame.size.height/2 - 10.0,
                                          self.contentView.frame.size.width,
                                          20.0);

    self.menuItemImageView.frame = CGRectMake(10.0,
                                              self.contentView.frame.size.height/2 - 17,
                                              34.0,
                                              34.0);

}

@end
