//
//  ViewController.h
//  CornellTech
//
//  Created by Fanxing Meng on 10/26/14.
//  Copyright (c) 2014 Fanxing Meng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ESTBeacon.h"
#import "ESTBeaconManager.h"
#import <AddressBook/AddressBook.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <CoreMotion/CoreMotion.h>
#import <CoreGraphics/CoreGraphics.h>
#import <CoreText/CoreText.h>
#import <MediaPlayer/MediaPlayer.h>
#import <Security/Security.h>
#import <SystemConfiguration/SystemConfiguration.h>

#import <GooglePlus/GooglePlus.h>


typedef enum : int
{
    ESTScanTypeBluetooth,
    ESTScanTypeBeacon
    
} ESTScanType;


@interface ViewController : UIViewController <GPPSignInDelegate, ESTBeaconManagerDelegate, CLLocationManagerDelegate>

@property (retain, nonatomic) IBOutlet GPPSignInButton *signInButton;

- (void)fetchNewDataWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler;
- (void)startRangingBeacons;
- (void)stopRangingBeacons;

@end

@class GPPSignInButton;