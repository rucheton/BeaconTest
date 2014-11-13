//
//  UIDetailViewController.h
//  IDLoc
//
//  Created by Clement RUCHETON on 17/01/2014.
//  Copyright (c) 2014 Clement RUCHETON. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DetailViewController : UIViewController

@property(nonatomic,strong) UIImage *image;
@property(nonatomic,strong) NSString *title;
@property(nonatomic,strong) NSString *description;

@end
