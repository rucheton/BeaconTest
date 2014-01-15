//
//  CircleView.m
//  IDLoc
//
//  Created by Clement RUCHETON on 07/01/2014.
//  Copyright (c) 2014 Clement RUCHETON. All rights reserved.
//

#import "CircleView.h"

@implementation CircleView

- (id)initWithFrame:(CGRect)frame
{
    frame.size.height = frame.size.width;
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        self.layer.cornerRadius = self.frame.size.width;
    }
    return self;
}

- (void)setFrame:(CGRect)frame
{
    frame.size.height = frame.size.width;
    self.layer.cornerRadius = self.frame.size.width / 2;
    [super setFrame:frame];
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
