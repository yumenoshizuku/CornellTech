//
//  ViewController.m
//  CornellTech
//
//  Created by Fanxing Meng on 10/26/14.
//  Copyright (c) 2014 Fanxing Meng. All rights reserved.
//

#import "ViewController.h"
#import "RoomLaterTableViewController.h"
#import "RoomNowTableViewController.h"
#import <GoogleOpenSource/GoogleOpenSource.h>
#import <GooglePlus/GooglePlus.h>

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UIButton *bookRoomLaterButton;
@property (weak, nonatomic) IBOutlet UIButton *bookRoomNowButton;
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *netid;
@property   (nonatomic, strong) RoomLaterTableViewController *roomLaterTableViewController;
@property   (nonatomic, strong) RoomNowTableViewController *roomNowTableViewController;
@end

static NSString * const kClientId = @"67337671681-rhejhgkl8plulfq0e8c31nmmpfgvbn4n.apps.googleusercontent.com";

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.bookRoomLaterButton.hidden = YES;
    self.bookRoomNowButton.hidden = YES;
    // Do any additional setup after loading the view, typically from a nib.
    GPPSignIn *signIn = [GPPSignIn sharedInstance];
    signIn.shouldFetchGooglePlusUser = YES;
    signIn.shouldFetchGoogleUserEmail = YES;  // Uncomment to get the user's email
    
    // You previously set kClientId in the "Initialize the Google+ client" step
    signIn.clientID = kClientId;
    
    // Uncomment one of these two statements for the scope you chose in the previous step
    signIn.scopes = @[ kGTLAuthScopePlusLogin ];  // "https://www.googleapis.com/auth/plus.login" scope
    //signIn.scopes = @[ @"profile" ];            // "profile" scope
    
    // Optional: declare signIn.actions, see "app activities"
    signIn.delegate = self;
    [signIn trySilentAuthentication];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)finishedWithAuth: (GTMOAuth2Authentication *)auth
                   error: (NSError *) error {
    NSLog(@"Received error %@ and auth object %@",error, auth);
    if (error) {
        // Do some error handling here.
    } else {
        [self refreshInterfaceBasedOnSignIn];
        [self refreshUserInfo];
    }
}

- (void)refreshUserInfo {
    if ([GPPSignIn sharedInstance].authentication == nil) {
        return;
    }
    
    //self.emailLabel.text = [GPPSignIn sharedInstance].userEmail;
    
    // The googlePlusUser member will be populated only if the appropriate
    // scope is set when signing in.
    GTLPlusPerson *person = [GPPSignIn sharedInstance].googlePlusUser;
    if (person == nil) {
        return;
    }
    self.nameLabel.text = person.displayName;
    self.name = person.displayName;
    [[NSUserDefaults standardUserDefaults] setObject:self.name forKey:@"name"];
    for (int i =0; i  < person.emails.count; i++) {
        GTLPlusPersonEmailsItem *email = person.emails[i];
        if ([email.value containsString:@"cornell.edu"]) {
            self.netid = [email.value componentsSeparatedByString:@"@"][0];
            [[NSUserDefaults standardUserDefaults] setObject:self.netid forKey:@"netid"];
        }
    }
    
    
//    // Load avatar image asynchronously, in background
//    dispatch_queue_t backgroundQueue =
//    dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
//    
//    dispatch_async(backgroundQueue, ^{
//        NSData *avatarData = nil;
//        NSString *imageURLString = person.image.url;
//        if (imageURLString) {
//            NSURL *imageURL = [NSURL URLWithString:imageURLString];
//            avatarData = [NSData dataWithContentsOfURL:imageURL];
//        }
//        
//        if (avatarData) {
//            // Update UI from the main thread when available
//            dispatch_async(dispatch_get_main_queue(), ^{
//                self.userAvatar.image = [UIImage imageWithData:avatarData];
//            });
//        }
//    });
}

- (void)presentSignInViewController:(UIViewController *)viewController {
    // This is an example of how you can implement it if your app is navigation-based.
    [[self navigationController] pushViewController:viewController animated:YES];
}

-(void)refreshInterfaceBasedOnSignIn {
    if ([[GPPSignIn sharedInstance] authentication]) {
        // The user is signed in.
        self.signInButton.hidden = YES;
        
        self.bookRoomLaterButton.hidden = NO;
        self.bookRoomNowButton.hidden = NO;
        // Perform other actions here, such as showing a sign-out button
    } else {
        self.signInButton.hidden = NO;
        self.bookRoomLaterButton.hidden = YES;
        self.bookRoomNowButton.hidden = YES;
        [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:@"name"];
        [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:@"netid"];
        // Perform other actions here
    }
}

- (IBAction)bookRoomLater:(id)sender {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    RoomLaterTableViewController *roomLaterTableViewController = [storyboard instantiateViewControllerWithIdentifier:@"RoomLater"];
    self.roomLaterTableViewController = roomLaterTableViewController;
}

- (void)signOut {
    [[GPPSignIn sharedInstance] signOut];
}

- (void)disconnect {
    [[GPPSignIn sharedInstance] disconnect];
}

- (void)didDisconnectWithError:(NSError *)error {
    if (error) {
        NSLog(@"Received error %@", error);
    } else {
        [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:@"name"];
        [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:@"netid"];
        // The user is signed out and disconnected.
        // Clean up user data as specified by the Google+ terms.
    }
}

@end
