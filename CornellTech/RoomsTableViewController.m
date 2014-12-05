//
//  RoomsTableViewController.m
//  CornellTech
//
//  Created by Fanxing Meng on 12/5/14.
//  Copyright (c) 2014 Fanxing Meng. All rights reserved.
//

#import "RoomsTableViewController.h"
#import "RoomTableViewCell.h"

@interface RoomsTableViewController ()

@end

@implementation RoomsTableViewController


- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [self.room_list count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    RoomTableViewCell *cell = (RoomTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"RoomTableViewCell"];
    if (cell == nil)
    {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"RoomTableViewCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    cell.label.text = [[[self.room_list objectForKey:@"rooms"] objectAtIndex:indexPath.row] objectForKey:@"name"];
    cell.detailLabel.text = [@"Occupancy: " stringByAppendingString:[[[self.room_list objectForKey:@"rooms"] objectAtIndex:indexPath.row] objectForKey:@"occupancy"]];
    cell.roomid = [[[self.room_list objectForKey:@"rooms"] objectAtIndex:indexPath.row] objectForKey:@"id"];
    
    [cell.bookButton addTarget:self action:@selector(bookRoom:) forControlEvents:UIControlEventTouchUpInside];
    // Configure the cell...
    
    return cell;
}



-(void)bookRoom:(UIButton*)sender
{
    NSLog(@"book room button tapped");
    RoomTableViewCell *cell = (RoomTableViewCell *)[[sender superview] superview];
    NSString *bodyData = [NSString stringWithFormat:@"startTime=%@&endTime=%@&netID=%@&roomID=%@", self.startTime, self.endTime, [[NSUserDefaults standardUserDefaults] objectForKey:@"netid"], cell.roomid];
    //&csrfmiddlewaretoken=%@
    NSMutableURLRequest *postRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://54.200.176.236/room_booking/book"]];
    NSLog(@"%@", bodyData);
    [postRequest setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    
    // Designate the request a POST request and specify its body data
    [postRequest setHTTPMethod:@"POST"];
    [postRequest setHTTPBody:[NSData dataWithBytes:[bodyData UTF8String] length:strlen([bodyData UTF8String])]];
    
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    
    [NSURLConnection sendAsynchronousRequest:postRequest queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error)
     {
         NSLog(@"%@", response);
         NSLog(@"%@", error);
         //
         //
         if (!error) {
             NSMutableDictionary *response_json = [[NSMutableDictionary alloc] init];
             response_json = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
             //
             //
//                      if (error) {
//                          NSDictionary *response_json = [[NSDictionary alloc] initWithObjectsAndKeys:@"True", @"booked", @"30201", @"id", nil];
//             NSDictionary *response_json = [[NSDictionary alloc] initWithObjectsAndKeys:@"False", @"booked", @"Too slow", @"error", nil];
             //
             if ([[response_json objectForKey:@"booked"] caseInsensitiveCompare:@"false"] == NSOrderedSame) {
                 UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Could not book this room"
                                                                 message:[response_json objectForKey:@"error"]
                                                                delegate:nil
                                                       cancelButtonTitle:@"OK"
                                                       otherButtonTitles:nil];
                 [alert show];
             } else {
                 dispatch_sync(dispatch_get_main_queue(), ^{
                     //success, where to go?
                     NSString *email = [[NSUserDefaults standardUserDefaults] objectForKey:@"email"];
                     NSString *urlStr = [@"https://www.googleapis.com/calendar/v3/calendars/" stringByAppendingString:email];
                     NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlStr]
                                                                            cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData
                                                                        timeoutInterval:20];
                     [request setHTTPMethod: @"GET"];
                     NSError *requestError;
                     NSURLResponse *urlResponse = nil;
                     NSData *response1 = [NSURLConnection sendSynchronousRequest:request returningResponse:&urlResponse error:&requestError];
                     //NSLog(@"%@", urlResponse);
                     NSString* responseString = [[NSString alloc] initWithData:response1 encoding:NSUTF8StringEncoding];
                     NSError *error;
                     NSMutableDictionary *cal = [NSJSONSerialization JSONObjectWithData:response1
                                                                                options:0 error:&error];
                     if ([cal count] != 0) {
                         NSDictionary *start = [[NSDictionary alloc] initWithObjectsAndKeys:self.startTime, @"dateTime", nil];
                         NSDictionary *end = [[NSDictionary alloc] initWithObjectsAndKeys:self.endTime, @"dateTime", nil];
                         NSMutableDictionary * _params = [[NSMutableDictionary alloc] init];
                         [_params setObject:start forKey:@"start"];
                         [_params setObject:end forKey:@"end"];
                         [_params setObject:cell.label.text forKey:@"description"];
                         
                         NSError *error;
                         NSData *jsonData = [NSJSONSerialization dataWithJSONObject:_params
                                                                            options:NSJSONWritingPrettyPrinted // Pass 0 if you don't care about the readability of the generated string
                                                                              error:&error];
                         NSString *jsonString = [[NSString alloc] init];
                         if (! jsonData) {
                             NSLog(@"Got an error: %@", error);
                         } else {
                             jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
                         }
                         
                         NSString *postUrlStr = [[@"https://www.googleapis.com/calendar/v3/calendars/" stringByAppendingString:email] stringByAppendingString:@"/events"];
                         NSURL* requestURL = [NSURL URLWithString:postUrlStr];
                         
                         NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
                         
                         [request setURL:requestURL];
                         [request setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
                         [request setHTTPShouldHandleCookies:YES];
                         [request setTimeoutInterval:15];
                         [request setHTTPMethod:@"POST"];
                         
                         NSString *contentType = [NSString stringWithFormat:@"application/json"];
                         [request setValue:contentType forHTTPHeaderField: @"Content-Type"];
                         NSMutableData *body = [NSMutableData data];
                         
                         [body appendData:[jsonString dataUsingEncoding:NSUTF8StringEncoding]];
                         
                         [body appendData:[[NSString stringWithFormat:@"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
                         
                         [request setHTTPBody:body];
                         NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[body length]];
                         
                         [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
                         
                         NSOperationQueue *queue = [[NSOperationQueue alloc] init];
                         
                         [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error)
                          {
                              
                              NSLog(@"%@", response);
                              NSLog(@"%@", error);
                              NSString* responseString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                              NSLog(@"%@",responseString);
                              if (!error) {
                                  
                                  dispatch_sync(dispatch_get_main_queue(), ^{
                                      UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Success"
                                                                                      message:@"Successfully add booking info to your Google calendar."
                                                                                     delegate:nil
                                                                            cancelButtonTitle:@"OK"
                                                                            otherButtonTitles:nil];
                                      [alert show];
                                  });
                                  
                                  
                              } else {
                                  dispatch_sync(dispatch_get_main_queue(), ^{
                                      UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                                                      message:@"Could not add booking info to your Google calendar."
                                                                                     delegate:nil
                                                                            cancelButtonTitle:@"OK"
                                                                            otherButtonTitles:nil];
                                      [alert show];
                                  });
                              }
                          }];
                     } else {
                         UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                                         message:@"Could not find your Google calendar to add the booking info."
                                                                        delegate:nil
                                                               cancelButtonTitle:@"OK"
                                                               otherButtonTitles:nil];
                         [alert show];
                     }
                 });
             }
         }
         else {
             dispatch_sync(dispatch_get_main_queue(), ^{
                 UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Network error"
                                                                 message:@"Network error."
                                                                delegate:nil
                                                       cancelButtonTitle:@"OK"
                                                       otherButtonTitles:nil];
                 [alert show];
             });
         }
     }];

}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return 80;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return self.heading;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
