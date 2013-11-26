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
        self.menuItemLabel = [[UILabel alloc] initWithFrame:CGRectMake(70.0,
                                                                       self.contentView.frame.size.height/2 - 10.0,
                                                                       self.contentView.frame.size.width,
                                                                       20.0)];
        [self.contentView addSubview:self.menuItemLabel];
        
        self.menuItemImageView = [[UIImageView alloc] initWithFrame:CGRectMake(20.0,
                                                                               self.contentView.frame.size.height/2 - 15,
                                                                               30.0,
                                                                               30.0)];
        self.menuItemImageView.backgroundColor = [UIColor clearColor];
        [self.menuItemLabel setContentMode:UIViewContentModeScaleAspectFit];
        [self.contentView addSubview:self.menuItemImageView];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
