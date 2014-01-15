//
//  CRViewController.h
//  IDLoc
//
//  Created by Clement RUCHETON on 03/01/2014.
//  Copyright (c) 2014 Clement RUCHETON. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CRViewController : UIViewController
@property (weak, nonatomic) IBOutlet UITableView *tableview;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionview;
- (IBAction)toggleDev:(id)sender;

@end
