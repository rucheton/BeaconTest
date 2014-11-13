//
//  CRTools.m
//  IDLoc
//
//  Created by Clement RUCHETON on 20/01/2014.
//  Copyright (c) 2014 Clement RUCHETON. All rights reserved.
//

#import "CRTools.h"

CGSize adaptedHomotheticSizeForImage(UIImage *image)
{
    CGSize imageSize = image.size;
    
    return CGSizeMake(screenSize().width, imageSize.height / imageSize.width * screenSize().width);
}

CGSize screenSize()
{
    return [[UIScreen mainScreen] bounds].size;
}

UIColor *randomColor()
{
    CGFloat hue = ( arc4random() % 256 / 256.0 );  //  0.0 to 1.0
    CGFloat saturation = ( arc4random() % 128 / 256.0 ) + 0.5;  //  0.5 to 1.0, away from white
    CGFloat brightness = ( arc4random() % 128 / 256.0 ) + 0.5;  //  0.5 to 1.0, away from black
    return [UIColor colorWithHue:hue saturation:saturation brightness:brightness alpha:1];
}
