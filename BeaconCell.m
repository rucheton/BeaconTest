//
//  BeaconCell.m
//  IDLoc
//
//  Created by Clement RUCHETON on 10/01/2014.
//  Copyright (c) 2014 Clement RUCHETON. All rights reserved.
//

#import "BeaconCell.h"

@implementation BeaconCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.layer.rasterizationScale = [[UIScreen mainScreen] scale];
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
