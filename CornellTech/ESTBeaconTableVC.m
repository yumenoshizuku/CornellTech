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
#import "BackgroundTask.h"

@interface ESTBeaconTableVC () <ESTBeaconManagerDelegate>

@property (nonatomic, strong) ESTBeaconManager *beaconManager;
@property (nonatomic, strong) ESTBeaconRegion *region;
@property (nonatomic, strong) ESTBeacon *nullBeacon;
@property (nonatomic, strong) NSArray *beaconsArray;
@property (nonatomic, strong) NSMutableArray *historyQueue;
@property (nonatomic, strong) NSNumber *lastSent;
@property (strong, nonatomic) NSString *csrf;
@property (weak) NSTimer *repeatingTimer;
@property (strong, nonatomic) NSDictionary *userInfo;
@property (strong, nonatomic) CLLocationManager *locationManager;

@end


static const double CONF_DIST_STUDIO = 1.5;
static const double CONF_DIST_STUDIO_BLUE = 5.0;
static const double CONF_DIST_BIGRED = 4.0;
static const double CONF_DIST_MUM = 1.25;
static const double CONF_DIST_PADDINGTON = 1.25;
static const double CONF_DIST_FOZZIE = 2.0;
static const double CONF_DIST_BARON = 1.25;
static const double CONF_DIST_BEARHUG = 1.25;
static const double CONF_DIST_TOUCHDOWN = 4.0;

static const double AMB_DIST_STUDIO = 2.5;
static const double AMB_DIST_STUDIO_BLUE = 7.0;
static const double AMB_DIST_BIGRED = 6.0;
static const double AMB_DIST_MUM = 2.25;
static const double AMB_DIST_PADDINGTON = 2.25;
static const double AMB_DIST_FOZZIE = 3.5;
static const double AMB_DIST_BARON = 2.25;
static const double AMB_DIST_BEARHUG = 2.25;
static const double AMB_DIST_TOUCHDOWN = 6.0;



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
    self.title = @"Beacons";
    [self.tableView registerClass:[ESTTableViewCell class] forCellReuseIdentifier:@"CellIdentifier"];
    self.historyQueue = [[NSMutableArray alloc] init];
    self.lastSent = [[NSNumber alloc] initWithInt:0];
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    //self.csrf = [self CSRFTokenFromURL:@"http://TODO"];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    self.beaconManager = [[ESTBeaconManager alloc] init];
    self.beaconManager.delegate = self;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyKilometer;
    [self.locationManager startUpdatingLocation];
    /*
     * Creates sample region object (you can additionaly pass major / minor values).
     *
     * We specify it using only the ESTIMOTE_PROXIMITY_UUID because we want to discover all
     * hardware beacons with Estimote's proximty UUID.
     */
    self.region = [[ESTBeaconRegion alloc] initWithProximityUUID:ESTIMOTE_PROXIMITY_UUID
                                                      identifier:@"EstimoteSampleRegion"];
    [self startRangingBeacons];
    BackgroundTask * bgTask =[[BackgroundTask alloc] init];
    [bgTask startBackgroundTasks:2 target:self selector:@selector(updateStatus:)];
}

- (void)beaconManager:(ESTBeaconManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    [self startRangingBeacons];
}

- (NSString *)CSRFTokenFromURL:(NSString *)url
{
    // Pass in any url with a CSRF protected form
    NSURL *baseURL = [NSURL URLWithString:url];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:baseURL];
    [request setHTTPMethod:@"GET"];
    NSURLResponse *response;
    [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:nil];
    NSArray *cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookiesForURL:baseURL];
    for (NSHTTPCookie *cookie in cookies)
    {
        if ([[cookie name] isEqualToString:@"csrftoken"])
            return [cookie value];
    }
    return nil;
}


- (IBAction)startRepeatingTimer {
    // Cancel a preexisting timer.
    [self.repeatingTimer invalidate];
    
    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:10
                                                      target:self selector:@selector(updateStatus:)
                                                    userInfo:[self userInfo] repeats:YES];
    self.repeatingTimer = timer;
}

- (IBAction)stopRepeatingTimer {
    [self.repeatingTimer invalidate];
    self.repeatingTimer = nil;
}

-(void)stopRangingBeacons
{
    NSLog(@"from appdelegate's performFetchWithCompletionHandler");
    [self.beaconManager stopRangingBeaconsInRegion:self.region];
}

-(void)fetchNewDataWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler{
    //[self startRepeatingTimer];
    NSLog(@"started timer");
    [self.beaconManager stopRangingBeaconsInRegion:self.region];
    NSLog(@"stopped range beacons");
    [self.beaconManager startRangingBeaconsInRegion:self.region];
    NSLog(@"ranged beacons");
    completionHandler(UIBackgroundFetchResultNewData);
    //NSLog(@"stopping the timer now");
    //[self stopRepeatingTimer];
}

- (void)updateStatus:(NSTimer*)theTimer {
    [self.beaconManager stopRangingBeaconsInRegion:self.region];
    [self.beaconManager startRangingBeaconsInRegion:self.region];
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
    //[self.beaconManager stopRangingBeaconsInRegion:self.region];
    //[self.beaconManager stopEstimoteBeaconDiscovery];
}

- (void)dismiss
{
    [self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - ESTBeaconManager delegate

- (void)beaconManager:(ESTBeaconManager *)manager didRangeBeacons:(NSArray *)beacons inRegion:(ESTBeaconRegion *)region
{
    NSString *netid = [[NSUserDefaults standardUserDefaults] objectForKey:@"netid"];
    if ([netid length] != 0) {
        
        int numConfBeacons = 0;
        int numAmbBeacons = 0;
        int numFarBeacons = 0;
        NSMutableArray *confBeacons = [[NSMutableArray alloc] init];
        NSMutableArray *ambBeacons = [[NSMutableArray alloc] init];
        NSMutableArray *farBeacons = [[NSMutableArray alloc] init];
        
        self.beaconsArray = beacons;
        [self.tableView reloadData];
        for (ESTBeacon *beacon in beacons) {
            NSDictionary *thisBeacon;
            double confDist = -1.0;
            double ambDist = -1.0;
            double dist = [beacon.distance floatValue];
            switch (beacon.major.intValue) {
                case 30200:
                    confDist = CONF_DIST_STUDIO;
                    ambDist = AMB_DIST_STUDIO;
                    break;
                case 30299:
                    confDist = CONF_DIST_STUDIO_BLUE;
                    ambDist = AMB_DIST_STUDIO_BLUE;
                    break;
                case 30201:
                    confDist = CONF_DIST_BIGRED;
                    ambDist = AMB_DIST_BIGRED;
                    break;
                case 30203:
                    confDist = CONF_DIST_MUM;
                    ambDist = AMB_DIST_MUM;
                    break;
                case 30204:
                    confDist = CONF_DIST_PADDINGTON;
                    ambDist = AMB_DIST_PADDINGTON;
                    break;
                case 30205:
                    confDist = CONF_DIST_FOZZIE;
                    ambDist = AMB_DIST_FOZZIE;
                    break;
                case 30206:
                    confDist = CONF_DIST_BARON;
                    ambDist = AMB_DIST_BARON;
                    break;
                case 30207:
                    confDist = CONF_DIST_BEARHUG;
                    ambDist = AMB_DIST_BEARHUG;
                    break;
                case 30217:
                    confDist = CONF_DIST_TOUCHDOWN;
                    ambDist = AMB_DIST_TOUCHDOWN;
                    break;
                default:
                    break;
            }
            if (confDist > 0 && dist > 0) {
                if (dist < confDist) {
                    numConfBeacons += 1;
                    thisBeacon = [NSDictionary dictionaryWithObjectsAndKeys: beacon, @"beacon", [NSNumber numberWithDouble:dist/confDist], @"distRatio", nil];
                    [confBeacons addObject:thisBeacon];
                } else if (dist >= confDist && dist < ambDist) {
                    numAmbBeacons += 1;
                    thisBeacon = [NSDictionary dictionaryWithObjectsAndKeys: beacon, @"beacon", [NSNumber numberWithDouble:dist/confDist], @"distRatio", nil];
                    [ambBeacons addObject:thisBeacon];
                } else if (dist >= ambDist) {
                    numFarBeacons += 1;
                    thisBeacon = [NSDictionary dictionaryWithObjectsAndKeys: beacon, @"beacon", [NSNumber numberWithDouble:dist], @"dist", nil];
                    [farBeacons addObject:thisBeacon];
                }
            }
        }
        NSSortDescriptor *distDescriptor = [[NSSortDescriptor alloc] initWithKey:@"distRatio" ascending:YES];
        NSArray *sortDescriptors = [NSArray arrayWithObject:distDescriptor];
        NSArray *sortedArray;
        if (numConfBeacons == 1) {
            [self addToQueue:[[confBeacons objectAtIndex:0] objectForKey:@"beacon"] toQueue:self.historyQueue];
        } else if (numConfBeacons > 1) {
            sortedArray = [confBeacons sortedArrayUsingDescriptors:sortDescriptors];
            [self addToQueue:[[confBeacons objectAtIndex:0] objectForKey:@"beacon"] toQueue:self.historyQueue];
        } else if (numConfBeacons == 0) {
            if (numAmbBeacons == 1) {
                [self addToQueue:[[ambBeacons objectAtIndex:0] objectForKey:@"beacon"] toQueue:self.historyQueue];
            } else if (numAmbBeacons > 1) {
                sortedArray = [ambBeacons sortedArrayUsingDescriptors:sortDescriptors];
                [self addToQueue:[[ambBeacons objectAtIndex:0] objectForKey:@"beacon"] toQueue:self.historyQueue];
            } else if (numAmbBeacons == 0) {
                if (numFarBeacons == 1) {
                    [self addToQueue:[[farBeacons objectAtIndex:0] objectForKey:@"beacon"] toQueue:self.historyQueue];
                } else if (numFarBeacons > 1) {
                    distDescriptor = [[NSSortDescriptor alloc] initWithKey:@"dist" ascending:YES];
                    sortDescriptors = [NSArray arrayWithObject:distDescriptor];
                    sortedArray = [farBeacons sortedArrayUsingDescriptors:sortDescriptors];
                    [self addToQueue:[[farBeacons objectAtIndex:0] objectForKey:@"beacon"] toQueue:self.historyQueue];
                } else {
                    self.nullBeacon = [[ESTBeacon alloc] init];
                    [self addToQueue:self.nullBeacon toQueue:self.historyQueue];
                }
            }
        }
        
        
    }
}


- (void) addToQueue: (ESTBeacon*) beacon toQueue: (NSMutableArray *) queue
{
    if (beacon.major) {
        [queue addObject:beacon.major];
    } else {
        [queue addObject:[NSNumber numberWithInt:0]];
    }

    if ([queue count] > 10) {
        [queue removeObjectAtIndex:0];
    }
    NSCountedSet *bag = [[NSCountedSet alloc] initWithArray:queue];
    NSLog(@"%@", bag);
    NSNumber *mostOccurring = [[NSNumber alloc] init];
    NSUInteger highest = 0;
    for (NSNumber *s in bag)
    {
        if ([bag countForObject:s] > highest)
        {
            highest = [bag countForObject:s];
            mostOccurring = s;
        }
    }
    if (![mostOccurring isEqualToNumber:self.lastSent]) {
        [self updateLocation:[[NSUserDefaults standardUserDefaults] objectForKey:@"name"] andNetid:[[NSUserDefaults standardUserDefaults] objectForKey:@"netid"] andMajor:mostOccurring.intValue];
        self.lastSent = mostOccurring;
        NSLog(@"updated to %d", self.lastSent.intValue);
    }
}

- (void) updateLocation: (NSString *) name andNetid: (NSString *) netid andMajor: (int) major
{
    NSString *bodyData = [NSString stringWithFormat:@"name=%@&netId=%@&major=%d&minor=1", name, netid, major];
    //&csrfmiddlewaretoken=%@
    NSMutableURLRequest *postRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://54.200.176.236/room_booking/occupy"]];
    NSLog(bodyData);
    [postRequest setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    
    // Designate the request a POST request and specify its body data
    [postRequest setHTTPMethod:@"POST"];
    [postRequest setHTTPBody:[NSData dataWithBytes:[bodyData UTF8String] length:strlen([bodyData UTF8String])]];
    
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    
    [NSURLConnection sendAsynchronousRequest:postRequest queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error)
     {
         //NSLog(@"POST IN REGION CALLBACK");
     }];
    
    
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
            roomName = @"Studio Yellow";
            break;
        case 30299:
            roomName = @"Studio Blue";
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
    //http://54.200.176.236/room_booking/json/room/30205
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
