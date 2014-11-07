//
//  ESTBeaconTableVC.m
//  DistanceDemo
//
//  Created by Grzegorz Krukiewicz-Gacek on 17.03.2014.
//  Copyright (c) 2014 Estimote. All rights reserved.
//

#import "ESTBeaconTableVC.h"
#import "ESTBeaconManager.h"
#import "ESTViewController.h"
#import "ViewController.h"

@interface ESTBeaconTableVC () <ESTBeaconManagerDelegate>

@property (nonatomic, strong) ESTBeaconManager *beaconManager;
@property (nonatomic, strong) ESTBeaconRegion *region;
@property (nonatomic, strong) NSArray *beaconsArray;

@end

@interface ESTTableViewCell : UITableViewCell

@end
@implementation ESTTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier];
    if (self)
    {
        
    }
    return self;
}
@end

@implementation ESTBeaconTableVC


- (void)viewDidLoad
{
    [super viewDidLoad];

    self.title = @"Select beacon";

    [self.tableView registerClass:[ESTTableViewCell class] forCellReuseIdentifier:@"CellIdentifier"];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    self.beaconManager = [[ESTBeaconManager alloc] init];
    self.beaconManager.delegate = self;
    
    /*
     * Creates sample region object (you can additionaly pass major / minor values).
     *
     * We specify it using only the ESTIMOTE_PROXIMITY_UUID because we want to discover all
     * hardware beacons with Estimote's proximty UUID.
     */
    self.region = [[ESTBeaconRegion alloc] initWithProximityUUID:ESTIMOTE_PROXIMITY_UUID
                                                      identifier:@"EstimoteSampleRegion"];
    [self startRangingBeacons];

}

- (void)beaconManager:(ESTBeaconManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    [self startRangingBeacons];
}

-(void)startRangingBeacons
{
    if ([ESTBeaconManager authorizationStatus] == kCLAuthorizationStatusNotDetermined)
    {
        /*
         * Request permission to use Location Services. (new in iOS 8)
         * We ask for "always" authorization so that the Notification Demo can benefit as well.
         * Also requires NSLocationAlwaysUsageDescription in Info.plist file.
         *
         * For more details about the new Location Services authorization model refer to:
         * https://community.estimote.com/hc/en-us/articles/203393036-Estimote-SDK-and-iOS-8-Location-Services
         */
        [self.beaconManager requestAlwaysAuthorization];
    }
    else if([ESTBeaconManager authorizationStatus] == kCLAuthorizationStatusAuthorizedAlways)
    {
        [self.beaconManager startRangingBeaconsInRegion:self.region];
    }
    else if([ESTBeaconManager authorizationStatus] == kCLAuthorizationStatusDenied)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Location Access Denied"
                                                        message:@"You have denied access to location services. Change this in app settings."
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles: nil];
        
        [alert show];
    }
    else if([ESTBeaconManager authorizationStatus] == kCLAuthorizationStatusRestricted)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Location Not Available"
                                                        message:@"You have no access to location services."
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles: nil];
        
        [alert show];
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    /*
     *Stops ranging after exiting the view.
     */
    [self.beaconManager stopRangingBeaconsInRegion:self.region];
    [self.beaconManager stopEstimoteBeaconDiscovery];
}

- (void)dismiss
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - ESTBeaconManager delegate

- (void)beaconManager:(ESTBeaconManager *)manager didRangeBeacons:(NSArray *)beacons inRegion:(ESTBeaconRegion *)region
{
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"name"] length] != 0) {
        NSString *name = [[NSUserDefaults standardUserDefaults] objectForKey:@"name"];
        NSString *netid = [[NSUserDefaults standardUserDefaults] objectForKey:@"netid"];
        self.beaconsArray = beacons;
        [self.tableView reloadData];
        for (ESTBeacon *beacon in beacons) {
            NSString *roomName;
            NSString *roomNumber;
            float radius = -1.0f;
            switch (beacon.major.intValue) {
                case 30200:
                    roomName = @"Studio";
                    roomNumber = @"301";
                    radius = 8.0f;
                    break;
                case 30201:
                    roomName = @"Big Red";
                    roomNumber = @"301";
                    radius = 4.0f;
                    break;
                case 30203:
                    roomName = @"Mum";
                    roomNumber = @"303";
                    radius = 2.0f;
                    break;
                case 30204:
                    roomName = @"Paddington";
                    roomNumber = @"304";
                    radius = 2.0f;
                    break;
                case 30205:
                    roomName = @"Fozzie";
                    roomNumber = @"305";
                    radius = 5.0f;
                    break;
                case 30206:
                    roomName = @"Baron";
                    roomNumber = @"306";
                    radius = 2.0f;
                    break;
                case 30207:
                    roomName = @"Bear Hug";
                    roomNumber = @"307";
                    radius = 2.0f;
                    break;
                default:
                    break;
            }
            if (radius > 0 && [beacon.distance floatValue] < radius) {
                NSString *bodyData = [NSString stringWithFormat:@"name=%@&deviceId=%@&roomId=%@&action=1", name, netid, roomNumber];
                NSMutableURLRequest *postRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://www.tejakondapalli.com/smartroom/room.php"]];
                NSLog(bodyData);
                [postRequest setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
                
                // Designate the request a POST request and specify its body data
                [postRequest setHTTPMethod:@"POST"];
                [postRequest setHTTPBody:[NSData dataWithBytes:[bodyData UTF8String] length:strlen([bodyData UTF8String])]];
                
                NSOperationQueue *queue = [[NSOperationQueue alloc] init];
                
                [NSURLConnection sendAsynchronousRequest:postRequest queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error)
                 {
                     NSLog(@"POST IN REGION CALLBACK");
                 }];
                
                
            } else if (radius > 0) {
                NSString *bodyData = [NSString stringWithFormat:@"name=%@&deviceId=%@&roomId=%@&action=0", name, netid, roomNumber];
                NSMutableURLRequest *postRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://www.tejakondapalli.com/smartroom/room.php"]];
                
                // Set the request's content type to application/x-www-form-urlencoded
                [postRequest setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
                
                // Designate the request a POST request and specify its body data
                [postRequest setHTTPMethod:@"POST"];
                [postRequest setHTTPBody:[NSData dataWithBytes:[bodyData UTF8String] length:strlen([bodyData UTF8String])]];
                
                NSLog(@"%@", postRequest);
                NSOperationQueue *queue = [[NSOperationQueue alloc] init];
                
                [NSURLConnection sendAsynchronousRequest:postRequest queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error)
                 {
                     NSLog(@"POST OUTSIDE REGION CALLBACK");
                 }];
                
            }
        }
        
        
    }
}

- (void)beaconManager:(ESTBeaconManager *)manager didDiscoverBeacons:(NSArray *)beacons inRegion:(ESTBeaconRegion *)region
{
    self.beaconsArray = beacons;
    
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.beaconsArray count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ESTTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CellIdentifier" forIndexPath:indexPath];
    
    /*
     * Fill the table with beacon data.
     */
    ESTBeacon *beacon = [self.beaconsArray objectAtIndex:indexPath.row];
    
    NSString *roomName;
    switch (beacon.major.intValue) {
            
        case 30200:
            roomName = @"Studio";
            break;
        case 30201:
            roomName = @"Big Red";
            break;
        case 30203:
            roomName = @"Mum";
            break;
        case 30204:
            roomName = @"Paddington";
            break;
        case 30205:
            roomName = @"Fozzie";
            break;
        case 30206:
            roomName = @"Baron";
            break;
        case 30207:
            roomName = @"Bear Hug";
            break;
        default:
            break;
    }
    cell.textLabel.text = [NSString stringWithFormat:@"Room: %@, Beacon: %@", roomName, beacon.minor];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"Distance: %.2f m", [beacon.distance floatValue]];

    //cell.textLabel.text = [NSString stringWithFormat:@"MacAddress: %@", beacon.macAddress];
    //cell.detailTextLabel.text = [NSString stringWithFormat:@"RSSI: %ld", (long)beacon.rssi];

    cell.imageView.image = [UIImage imageNamed:@"beacon"];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80;
}


@end
