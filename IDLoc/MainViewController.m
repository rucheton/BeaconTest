//
//  CRViewController.m
//  IDLoc
//
//  Created by Clement RUCHETON on 03/01/2014.
//  Copyright (c) 2014 Clement RUCHETON. All rights reserved.
//

#import "MainViewController.h"
#import <CoreLocation/CoreLocation.h>
#import <QuartzCore/QuartzCore.h>
#import <CoreImage/CoreImage.h>
#import "BeaconCell.h"
#import "DetailViewController.h"
#import <ESTBeacon.h>
#import <ESTBeaconManager.h>
#import <ESTBeaconRegion.h>

#define kDuration .5f

@interface MainViewController () <ESTBeaconManagerDelegate, UITableViewDataSource, UITableViewDelegate>
@property (strong, nonatomic) ESTBeaconManager *manager;
@property (strong, nonatomic) NSMutableDictionary *data;
@property (strong, nonatomic) NSArray *datasource;
@property (strong, nonatomic) NSMutableDictionary *accessibleBeacons;
@property (strong, nonatomic) ESTBeaconRegion *mainRegion;
@property (weak, nonatomic) IBOutlet UIImageView *radarView;
@property (strong, nonatomic) ESTBeacon *lastBeacon;
@property (weak, nonatomic) IBOutlet UIButton *thumbView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *thumbHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *thumbWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *thumbXConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *thumbYConstraint;
@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *textYConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *textWidthConstraint;
@property (weak, nonatomic) IBOutlet UIScrollView *detailView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *textHeightConstraint;

@end

@implementation MainViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)rotateImageViewForce:(BOOL)force
{
    [UIView animateWithDuration:.4 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
        [self.radarView setTransform:CGAffineTransformRotate(self.radarView.transform, M_PI_2)];
    }completion:^(BOOL finished){
        if (finished || force) {
            [self rotateImageViewForce:NO];
        }
    }];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self rotateImageViewForce:NO];
    
    [self.thumbView.layer setCornerRadius:128];
    [self.thumbView.layer setBorderColor:[UIColor blackColor].CGColor];
    [self.thumbView.layer setBorderWidth:1.0f];
    [self.thumbView setHidden:YES];
    
    self.accessibleBeacons = [NSMutableDictionary dictionary];
    
    self.data = [[NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Data" ofType:@"plist"]] mutableCopy];
    
    self.manager = [[ESTBeaconManager alloc] init];
    self.manager.delegate = self;
    
    ESTBeaconRegion *test = [[ESTBeaconRegion alloc] initWithProximityUUID:[[NSUUID alloc] initWithUUIDString:@"23542266-18D1-4FE4-B4A1-23F8195B9D39"] identifier:@"TESTREGION"];
    [test setNotifyOnExit:YES];
    [test setNotifyOnEntry:YES];
    
    self.mainRegion = [[ESTBeaconRegion alloc] initWithProximityUUID:[[NSUUID alloc] initWithUUIDString:@"23542266-18D1-4FE4-B4A1-23F8195B9D39"] identifier:@"Estimote"];
//    self.mainRegion = [[ESTBeaconRegion alloc] initWithProximityUUID:[[NSUUID alloc] initWithUUIDString:@"92F8BD5A-BACB-4935-9138-A28BA77CE57D"] identifier:@"Estimote"];
    [self.mainRegion setNotifyOnEntry:YES];
    [self.mainRegion setNotifyOnExit:YES];
    
    [self.manager setAvoidUnknownStateBeacons:YES];
    [self.manager startRangingBeaconsInRegion:self.mainRegion];
    [self.manager startMonitoringForRegion:test];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:@"close" object:nil queue:nil usingBlock:^(NSNotification *note) {
        [self dismissViewControllerAnimated:YES completion:nil];
        [self.manager startRangingBeaconsInRegion:self.mainRegion];
        [self rotateImageViewForce:YES];
    }];
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
//    if (scrollView.contentOffset.y < -80 && scrollView == self.detailView)
//    {
//        [scrollView setDelegate:nil];
//        [self close];
//    }
}

- (void)animationDidStop:(CAAnimation *)animation finished:(BOOL)flag
{
//    if(animation == [self.thumbView.layer animationForKey:@"cornerRadius"])
//    {
//        [self close];
//    }
}

- (void)animateThumbnail
{
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
    [animation setDuration:kDuration];
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    [animation setDelegate:self];
    
    int steps = 100;
    NSMutableArray *values = [NSMutableArray arrayWithCapacity:steps];
    double value = 0;
    float e = 2.71;
    CATransform3D transform;
    for (int t = 0; t < steps; t++) {
        value = -1 * pow(e, -0.055*t) * cos(0.08*t) + 1;
        transform = CATransform3DMakeScale(value, value, 1);
        [values addObject:[NSValue valueWithCATransform3D:transform]];
    }
    animation.values = values;
    
    [self.thumbView.layer addAnimation:animation forKey:nil];
}

#pragma mark - Beacon Monitoring

- (NSArray*)filterBeaconsWithUnknownState:(NSArray*)beacons
{
    NSMutableArray *data = [NSMutableArray array];
    for(CLBeacon *beacon in beacons) {
        if(beacon.proximity != 0) {
            [data addObject:beacon];
        }
    }
    
    return data;
}

- (void)beaconManager:(ESTBeaconManager *)manager didRangeBeacons:(NSArray *)beacons inRegion:(ESTBeaconRegion *)region
{
    NSDictionary *regionData = [self.data objectForKey:[region.proximityUUID UUIDString]];
    
    self.datasource = beacons;
    [self.tableview reloadData];
    
    if (!regionData) {
        return;
    }
    
    for(ESTBeacon *beacon in self.datasource) {
        NSString *beaconID = [NSString stringWithFormat:@"%@%@",beacon.major,beacon.minor];
        NSDictionary *beaconData = [[regionData objectForKey:@"beacons"] objectForKey:beaconID];
        ESTBeacon *closestBeacon = nil;
        NSDictionary *closestBeaconData = nil;
        
        if([[beaconData objectForKey:@"trigger"] integerValue] >= beacon.proximity && beacon.proximity != 0 && [beacon.distance floatValue] < 0.5f && beacon != self.lastBeacon) {
            if(!closestBeacon || [beacon.distance floatValue] < [closestBeacon.distance floatValue])
            {
                closestBeacon = beacon;
                closestBeaconData = beaconData;
            }
        }
        
        if(closestBeacon)
        {
            self.lastBeacon = closestBeacon;
            
            [self.accessibleBeacons setObject:@"OK" forKey:beaconID];
            
            [self.thumbView setHidden:NO];
            
            [self.textView setText:[NSString stringWithFormat:@"*%@*\n\n%@",[closestBeaconData objectForKey:@"name"],[closestBeaconData objectForKey:@"description"]]];
            
            // Dispatch a background thread for download
            dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
                
                NSData *imageData = [NSData dataWithContentsOfURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:[closestBeaconData objectForKey:@"badge"] ofType:@""]]];
                UIImage *imageLoad = [[UIImage alloc] initWithData:imageData];
                
                // Update UI on main thread
                dispatch_async(dispatch_get_main_queue(), ^(void) {
                    [self.thumbView setImage:imageLoad forState:UIControlStateNormal];
                    [self animateThumbnail];
                });
            });
        }
    }
}

- (void)close
{
    [self.manager startRangingBeaconsInRegion:self.mainRegion];
    
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"cornerRadius"];
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    animation.fromValue = [NSNumber numberWithFloat:0];
    animation.toValue = [NSNumber numberWithFloat:128];
    animation.duration = kDuration;
    
    CABasicAnimation *border = [CABasicAnimation animationWithKeyPath:@"borderWidth"];
    border.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    border.fromValue = @0.0f;
    border.toValue = @1.0f;
    animation.duration = kDuration;
    
    CAAnimationGroup *group = [CAAnimationGroup animation];
    [group setAnimations:@[animation,border]];
    [group setDuration:kDuration];
    [group setRemovedOnCompletion:NO];
    [group setFillMode:kCAFillModeBoth];
    [group setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    
    [self.thumbView.layer addAnimation:group forKey:@"close"];
    
    [self.textHeightConstraint setConstant:0];
    [self.thumbWidthConstraint setConstant:256];
    [self.thumbHeightConstraint setConstant:256];
    
    [UIView animateWithDuration:kDuration/2 animations:^{
        [self.textView layoutIfNeeded];
        [self.textView setAlpha:0];
        [self.detailView layoutIfNeeded];
    } completion:^(BOOL finished) {
        [self.thumbYConstraint setConstant:-18];
        [UIView animateWithDuration:kDuration/2 animations:^{
            [self.thumbView layoutIfNeeded];
        } completion:^(BOOL finished) {
            [self.detailView setContentOffset:CGPointZero animated:YES];
            [self.detailView setScrollEnabled:NO];
        }];
    }];
}

- (IBAction)showDetails:(id)sender
{
    if(self.textView.alpha == 1)
    {
        [self close];
        return;
    }
    
    [self.detailView setDelegate:self];
    [self.manager stopRangingBeaconsInRegion:self.mainRegion];
    
    [self.detailView setScrollEnabled:YES];
    
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"cornerRadius"];
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    animation.fromValue = [NSNumber numberWithFloat:128];
    animation.toValue = [NSNumber numberWithFloat:0];
    animation.duration = kDuration;
    
    CABasicAnimation *border = [CABasicAnimation animationWithKeyPath:@"borderWidth"];
    border.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    border.fromValue = @1.0f;
    border.toValue = @0.0f;
    animation.duration = kDuration;
    
    CAAnimationGroup *group = [CAAnimationGroup animation];
    [group setAnimations:@[animation,border]];
    [group setDuration:kDuration];
    [group setRemovedOnCompletion:NO];
    [group setFillMode:kCAFillModeBoth];
    [group setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    [group setDelegate:self];
    
    [self.thumbView.layer addAnimation:group forKey:@"cornerRadius"];
    
    CGSize screen = screenSize();
    CGSize image = adaptedHomotheticSizeForImage([self.thumbView imageForState:UIControlStateNormal]);
    
    [self.textHeightConstraint setConstant:[self.textView sizeThatFits:CGSizeMake(screen.width, CGFLOAT_MAX)].height];
    [self.thumbWidthConstraint setConstant:screen.width];
    [self.thumbHeightConstraint setConstant:image.height];
    [self.thumbYConstraint setConstant:(screen.height / 2) - (image.height / 2)];
    [self.textYConstraint setConstant:image.height];
    [self.textWidthConstraint setConstant:screen.width];
    
    [UIView animateWithDuration:kDuration animations:^{
        [self.textView layoutIfNeeded];
        [self.textView setAlpha:1];
        [self.thumbView layoutIfNeeded];
        [self.detailView layoutIfNeeded];
    } completion:^(BOOL finished) {
        
    }];
}

- (NSDictionary*)dataForBeacon:(ESTBeacon*)beacon
{
    return [[[self.data objectForKey:[beacon.proximityUUID UUIDString]] objectForKey:@"beacons"] objectForKey:[NSString stringWithFormat:@"%@%@",beacon.major,beacon.minor]];
}

#pragma mark - Region Monitoring

- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region
{
    UILocalNotification *notif = [[UILocalNotification alloc] init];
    notif.fireDate = [NSDate date];
    notif.alertBody = @"YOOOO BRO - ENTER";
    
    [[UIApplication sharedApplication] scheduleLocalNotification:notif];
}

- (void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region
{
    UILocalNotification *notif = [[UILocalNotification alloc] init];
    notif.fireDate = [NSDate date];
    notif.alertBody = @"YOOOO BRO - EXIT";
    
    [[UIApplication sharedApplication] scheduleLocalNotification:notif];
}

#pragma mark - AlertView delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [self.manager startRangingBeaconsInRegion:self.mainRegion];
}

#pragma mark - TableView datasource & delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.datasource.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    
    if(!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cell"];
    }
    
    ESTBeacon *beacon = [self.datasource objectAtIndex:indexPath.row];
    NSDictionary *beaconData = [self dataForBeacon:beacon];
    
    [cell.textLabel setText:[beaconData objectForKey:@"name"] ? [beaconData objectForKey:@"name"] : [NSString stringWithFormat:@"%@|%@",beacon.major,beacon.minor]];
    [cell.detailTextLabel setText:[NSString stringWithFormat:@"%ld | %ld | %@",(long)beacon.rssi, (long)beacon.proximity, beacon.distance]];
    
    return cell;
}

- (UIImage*)filterImageWithPath:(NSString*)imagePath andFilterName:(NSString*)filterName
{
    CIImage *beginImage = [CIImage imageWithContentsOfURL:[NSURL fileURLWithPath:imagePath]];
    CIContext *context = [CIContext contextWithOptions:nil];
    
    CIFilter *filter = [CIFilter filterWithName:filterName
                                  keysAndValues: kCIInputImageKey, beginImage,
                        @"inputIntensity", @0.8, nil];
    CIImage *outputImage = [filter outputImage];
    CGImageRef cgimg = [context createCGImage:outputImage fromRect:[outputImage extent]];
    
    UIImage *newImage = [UIImage imageWithCGImage:cgimg];
    CGImageRelease(cgimg);
    
    return newImage;
}

- (IBAction)toggleDev:(id)sender {
    self.tableview.hidden = !self.tableview.hidden;
}

@end
