//
//  RoomLaterTableViewController.m
//  CornellTech
//
//  Created by Fanxing Meng on 10/31/14.
//  Copyright (c) 2014 Fanxing Meng. All rights reserved.
//

#define kDatePickerTag 1

#import "RoomLaterTableViewController.h"
#import "RoomsTableViewController.h"


static NSString *kDateCellID = @"dateCell";
static NSString *kDatePickerCellID = @"datePickerCell";

@interface RoomLaterTableViewController ()
@property (strong, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) NSMutableArray *dates;
@property (strong, nonatomic) NSDateFormatter *dateFormatter;

@property (strong, nonatomic) NSIndexPath *datePickerIndexPath;
@property (assign) NSInteger pickerCellRowHeight;

@property (strong, nonatomic) NSDate *startTime;
@property (strong, nonatomic) NSDate *endTime;
- (IBAction)dateChanged:(UIDatePicker *)sender;

@end

@implementation RoomLaterTableViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    self.startTime = [[NSDate alloc] init];
    self.endTime = [[NSDate alloc] init];
    UITableViewCell *pickerViewCellToCheck = [self.tableView dequeueReusableCellWithIdentifier:kDatePickerCellID];
    self.pickerCellRowHeight = 164;
    //NSLog(@"%ld", self.pickerCellRowHeight);
    [self createDateFormatter];
}


- (void)createDateFormatter {
    self.dateFormatter = [[NSDateFormatter alloc] init];
    [self.dateFormatter setDateStyle:NSDateFormatterShortStyle];
    [self.dateFormatter setTimeStyle:NSDateFormatterShortStyle];
}

- (BOOL)datePickerIsShown {
    return self.datePickerIndexPath != nil;
}

- (UITableViewCell *)createDateCell:(NSString *)dateType {
    
    NSDate *currentTime = [NSDate date];
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:kDateCellID];
    if (cell == NULL){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:kDateCellID];
    }
    cell.textLabel.text = dateType;
    cell.detailTextLabel.text = [self.dateFormatter stringFromDate:currentTime];
    return cell;
}


- (UITableViewCell *)createPickerCell:(NSDate *)date {
    NSDate *currentTime = [NSDate date];
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:kDatePickerCellID];
    if (cell == NULL) {
        cell =[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:kDatePickerCellID];
    }
    UIDatePicker *targetedDatePicker = (UIDatePicker *)[cell viewWithTag:kDatePickerTag];
    return cell;
}


- (void)hideExistingPicker {
    
    [self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:self.datePickerIndexPath.row inSection:0]]
                          withRowAnimation:UITableViewRowAnimationFade];
    self.datePickerIndexPath = nil;
}

- (NSIndexPath *)calculateIndexPathForNewPicker:(NSIndexPath *)selectedIndexPath {
    
    NSIndexPath *newIndexPath;
    
    if (([self datePickerIsShown]) && (self.datePickerIndexPath.row < selectedIndexPath.row)){
        newIndexPath = [NSIndexPath indexPathForRow:selectedIndexPath.row - 1 inSection:0];
    }else {
        newIndexPath = [NSIndexPath indexPathForRow:selectedIndexPath.row  inSection:0];
    }
    return newIndexPath;
}

- (void)showNewPickerAtIndex:(NSIndexPath *)indexPath {
    NSArray *indexPaths = @[[NSIndexPath indexPathForRow:indexPath.row + 1 inSection:0]];
    [self.tableView insertRowsAtIndexPaths:indexPaths
                          withRowAnimation:UITableViewRowAnimationFade];
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    CGFloat rowHeight = self.tableView.rowHeight;
    
    if ([self datePickerIsShown] && (self.datePickerIndexPath.row == indexPath.row)){
        
        rowHeight = self.pickerCellRowHeight;
        
    }
    
    return rowHeight;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    if (section == 0) {
        NSInteger numberOfRows = 2;
        if ([self datePickerIsShown]){
            numberOfRows++;
        }
        return numberOfRows;
    } else {
        return 1;
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell;
    if (indexPath.section == 0) {
        if ([self datePickerIsShown]){
            if (self.datePickerIndexPath.row == indexPath.row) {
                NSDate *currentTime = [NSDate date];
                NSString *resultString = [self.dateFormatter stringFromDate: currentTime];
                switch (indexPath.row -1) {
                    case 0:
                        cell = [self createPickerCell:currentTime];
                        break;
                    case 1:
                        cell = [self createPickerCell:currentTime];
                        break;
                    default:
                        break;
                };
            }
        } else {
            switch (indexPath.row) {
                case 0:
                    cell = [self createDateCell:@"Start"];
                    break;
                case 1:
                    cell = [self createDateCell:@"End"];
                    break;
                default:
                    break;
            };
        }
    } else {
        cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
        
        if (cell == NULL){
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
        }
        cell.textLabel.text = @"Find Room";
        cell.textLabel.textAlignment = NSTextAlignmentCenter;
    }

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    
    if (indexPath.section == 0) {
        switch (indexPath.row) {
            default:
                [self.tableView beginUpdates];
                if ([self datePickerIsShown] && (self.datePickerIndexPath.row - 1 == indexPath.row)){
                    [self hideExistingPicker];
                }else {
                    NSIndexPath *newPickerIndexPath = [self calculateIndexPathForNewPicker:indexPath];
                    if ([self datePickerIsShown]){
                        [self hideExistingPicker];
                    }
                    [self showNewPickerAtIndex:newPickerIndexPath];
                    self.datePickerIndexPath = [NSIndexPath indexPathForRow:newPickerIndexPath.row + 1 inSection:0];
                }
                [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
                [self.tableView endUpdates];
                break;
        }
    } else {
        [self.tableView beginUpdates];
        if ([self datePickerIsShown]) {
            
            [self hideExistingPicker];
        }
        [self.tableView endUpdates];
        NSString *startTime;
        NSString *endTime;
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm':00'ZZZ"];
        startTime = [dateFormatter stringFromDate:self.startTime];
        endTime = [dateFormatter stringFromDate:self.endTime];
        NSString *bodyData = [NSString stringWithFormat:@"startTime=%@&endTime=%@&occupancy=1", startTime, endTime];
        //&csrfmiddlewaretoken=%@
        NSMutableURLRequest *postRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://54.200.176.236/room_booking/available"]];
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
             //
             //
            if (!error) {
                 NSMutableDictionary *room_list = [[NSMutableDictionary alloc] init];
                 room_list = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
                 //
                //
//                if (error) {
//                 NSMutableArray *fake = [[NSMutableArray alloc] init];
//                 NSDictionary *fd = [[NSDictionary alloc] initWithObjectsAndKeys:@"Big Red", @"name", @"30201", @"id", @"30", @"occupancy", nil];
//                 [fake addObject:fd];
//                 NSMutableDictionary *room_list = [[NSMutableDictionary alloc] initWithObjectsAndKeys:fake, @"rooms", nil];
                 //
                 //
                 if ([room_list count] == 0) {
                     UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No Result Found"
                                                                     message:@"All rooms are booked for this time slot."
                                                                    delegate:nil
                                                           cancelButtonTitle:@"OK"
                                                           otherButtonTitles:nil];
                     [alert show];
                 } else {
                     dispatch_sync(dispatch_get_main_queue(), ^{
                         RoomsTableViewController *roomsTVC = [[RoomsTableViewController alloc] initWithStyle:UITableViewStyleGrouped];
                         
                         NSDateFormatter *df = [[NSDateFormatter alloc] init];
                         df.dateStyle = kCFDateFormatterShortStyle;
                         
                         roomsTVC.heading = [@"Rooms available during " stringByAppendingString: [[[df stringFromDate:self.startTime] stringByAppendingString:@" - "] stringByAppendingString:[df stringFromDate:self.endTime]]];
                         roomsTVC.room_list = room_list;
                         roomsTVC.startTime = startTime;
                         roomsTVC.endTime = endTime;
                         [self.navigationController pushViewController:roomsTVC animated:YES];
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

}


- (IBAction)dateChanged:(UIDatePicker *)sender {
    
    NSIndexPath *parentCellIndexPath = nil;
    
    if ([self datePickerIsShown]){
        parentCellIndexPath = [NSIndexPath indexPathForRow:self.datePickerIndexPath.row - 1 inSection:0];
    }else {
        return;
    }
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:parentCellIndexPath];
    //NSLog(sender.date);
    
    cell.detailTextLabel.text = [self.dateFormatter stringFromDate:sender.date];
    if (parentCellIndexPath.row == 0) {
        self.startTime = sender.date;
    } else {
        self.endTime = sender.date;
    }
}

#pragma mark - VCAddPersonDelegate methods

- (void)saveDateDetails {
    ;
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
