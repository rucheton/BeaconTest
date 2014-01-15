//
//  BeaconCell.h
//  IDLoc
//
//  Created by Clement RUCHETON on 10/01/2014.
//  Copyright (c) 2014 Clement RUCHETON. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BeaconCell : UICollectionViewCell

@property (nonatomic, weak) IBOutlet UIImageView *badge;
@property (nonatomic, weak) IBOutlet UILabel *label;

@end
