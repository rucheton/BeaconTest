//
//  CRViewController.m
//  IDLoc
//
//  Created by Clement RUCHETON on 03/01/2014.
//  Copyright (c) 2014 Clement RUCHETON. All rights reserved.
//

#import "CRViewController.h"
#import <CoreLocation/CoreLocation.h>
#import <QuartzCore/QuartzCore.h>
#import "BeaconCell.h"

@interface CRViewController () <CLLocationManagerDelegate, UITableViewDataSource, UITableViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UIAlertViewDelegate>
@property (strong, nonatomic) CLLocationManager *manager;
@property (strong, nonatomic) NSMutableDictionary *data;
@property (strong, nonatomic) NSArray *datasource;
@property (strong, nonatomic) NSMutableDictionary *accessibleBeacons;
@property (strong, nonatomic) CLBeaconRegion *mainRegion;

@end

@implementation CRViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.accessibleBeacons = [NSMutableDictionary dictionary];
    
    self.data = [[NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Data" ofType:@"plist"]] mutableCopy];
    
    self.manager = [[CLLocationManager alloc] init];
    self.manager.delegate = self;
    
    CLBeaconRegion *test = [[CLBeaconRegion alloc] initWithProximityUUID:[[NSUUID alloc] initWithUUIDString:@"7F63E64B-8498-4BE5-BFBF-BA037C7AA2EC"] identifier:@"TESTREGION"];
    [test setNotifyOnExit:YES];
    [test setNotifyOnEntry:YES];
    
    self.mainRegion = [[CLBeaconRegion alloc] initWithProximityUUID:[[NSUUID alloc] initWithUUIDString:@"B9407F30-F5F8-466E-AFF9-25556B57FE6D"] identifier:@"Estimote"];
    [self.mainRegion setNotifyOnEntry:YES];
    [self.mainRegion setNotifyOnExit:YES];
    
    [self.manager startRangingBeaconsInRegion:self.mainRegion];
    
    [self.manager startMonitoringForRegion:test];
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
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    
    CLBeacon *beacon = [self.datasource objectAtIndex:indexPath.row];
    
    [cell.textLabel setText:[NSString stringWithFormat:@"%@|%@ | rssi: %ld | proximity: %ld | %f",beacon.major,beacon.minor,beacon.rssi, beacon.proximity, beacon.accuracy]];
    
    return cell;
}

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

- (void)locationManager:(CLLocationManager *)manager didRangeBeacons:(NSArray *)beacons inRegion:(CLBeaconRegion *)region
{
    NSDictionary *regionData = [self.data objectForKey:[region.proximityUUID UUIDString]];
    
    self.datasource = [self filterBeaconsWithUnknownState:beacons];
    [self.tableview reloadData];
    
    if (!regionData) {
        return;
    }
    
    for(CLBeacon *beacon in self.datasource) {
        NSString *beaconID = [NSString stringWithFormat:@"%@%@",beacon.major,beacon.minor];
        NSDictionary *beaconData = [[regionData objectForKey:@"beacons"] objectForKey:beaconID];
        
        if([[beaconData objectForKey:@"trigger"] integerValue] >= beacon.proximity && beacon.proximity != 0 && ![self.accessibleBeacons objectForKey:beaconID]) {
            [self.accessibleBeacons setObject:@"OK" forKey:beaconID];
            [self.collectionview reloadData];
            
            [self showAlertWithBeaconData:beaconData];
            
            break;
        }
    }
}

- (void)showAlertWithBeaconData:(NSDictionary*)beaconData
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[beaconData objectForKey:@"name"] message:[beaconData objectForKey:@"description"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert setDelegate:self];
    [alert show];
    
    [self.manager stopRangingBeaconsInRegion:self.mainRegion];
}

#pragma mark - CollectionView datasource & delegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"TOUCH");
    
    NSString *region = [[self.data allKeys] objectAtIndex:indexPath.section];
    NSString *beaconID = [[[[self.data objectForKey:region] objectForKey:@"beacons"] allKeys] objectAtIndex:indexPath.row];
    
    NSDictionary *beaconData = [[[self.data objectForKey:region] objectForKey:@"beacons"] objectForKey:beaconID];
    
    if([self.accessibleBeacons objectForKey:beaconID])
    {
        [self showAlertWithBeaconData:beaconData];
    }
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return [[self.data allKeys] count];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [[[[self.data objectForKey:[[self.data allKeys] objectAtIndex:section]] objectForKey:@"beacons"] allKeys] count];
}

- (UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    BeaconCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"BeaconCell" forIndexPath:indexPath];
    
    NSString *region = [[self.data allKeys] objectAtIndex:indexPath.section];
    NSString *beaconID = [[[[self.data objectForKey:region] objectForKey:@"beacons"] allKeys] objectAtIndex:indexPath.row];
    
    NSDictionary *beaconData = [[[self.data objectForKey:region] objectForKey:@"beacons"] objectForKey:beaconID];

    [cell.badge setImage:[UIImage imageNamed:[beaconData objectForKey:@"badge"]]];
    [cell.label setText:[beaconData objectForKey:@"name"]];
    
    if([self.accessibleBeacons objectForKey:beaconID]) {
        [cell.badge setAlpha:1];
        [cell.label setAlpha:1];
    }
    else {
        [cell.badge setAlpha:0.3];
        [cell.label setAlpha:0];
    }
    
    return cell;
}

- (UIEdgeInsets)collectionView:
(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? UIEdgeInsetsMake(60, 20, 60, 20) : UIEdgeInsetsMake(0, 0, 0, 0);
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(160, 190);
}


- (IBAction)toggleDev:(id)sender {
    self.tableview.hidden = !self.tableview.hidden;
}

@end
