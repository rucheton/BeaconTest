//
//  CRTools.h
//  IDLoc
//
//  Created by Clement RUCHETON on 20/01/2014.
//  Copyright (c) 2014 Clement RUCHETON. All rights reserved.
//

#import <Foundation/Foundation.h>

/** Degrees to Radian **/
#define degreesToRadians( degrees ) ( ( degrees ) / 180.0 * M_PI )

/** Radians to Degrees **/
#define radiansToDegrees( radians ) ( ( radians ) * ( 180.0 / M_PI ) )

CGSize screenSize();
CGSize adaptedHomotheticSizeForImage(UIImage *image);

UIColor *randomColor();