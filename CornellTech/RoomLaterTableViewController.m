//
//  RoomLaterTableViewController.m
//  CornellTech
//
//  Created by Fanxing Meng on 10/31/14.
//  Copyright (c) 2014 Fanxing Meng. All rights reserved.
//

#import "RoomLaterTableViewController.h"
#define kDatePickerTag 1
#define kAttendeesTag 2


static NSString *kDateCellID = @"dateCell";
static NSString *kAttendeesCellID = @"attendeesCell";
static NSString *kDatePickerCellID = @"datePickerCell";

@interface RoomLaterTableViewController ()
@property (strong, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) NSMutableArray *dates;
@property (strong, nonatomic) NSDateFormatter *dateFormatter;

@property (strong, nonatomic) NSIndexPath *datePickerIndexPath;
@property (assign) NSInteger pickerCellRowHeight;

- (IBAction)dateChanged:(UIDatePicker *)sender;

@end

@implementation RoomLaterTableViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    UITableViewCell *pickerViewCellToCheck = [self.tableView dequeueReusableCellWithIdentifier:kDatePickerCellID];
    self.pickerCellRowHeight = 164;
    UITableViewCell *attendeesCellToCheck = [self.tableView dequeueReusableCellWithIdentifier:kAttendeesCellID];
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
        NSInteger numberOfRows = 3;
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
            if (self.datePickerIndexPath.row == indexPath.row) {                NSDate *currentTime = [NSDate date];
                NSString *resultString = [self.dateFormatter stringFromDate: currentTime];                switch (indexPath.row -1) {
                    case 0:
                        cell = [self createPickerCell:currentTime];
                        break;
                    case 1:
                        cell = [self createPickerCell:currentTime];
                        break;
                    default:
                        break;
                };
            } else {
                cell.textLabel.text = @"Attendees";
                cell.detailTextLabel.text = @"1";
            }
        } else {
            switch (indexPath.row) {
                case 0:
                    cell = [self createDateCell:@"Start"];
                    break;
                case 1:
                    cell = [self createDateCell:@"End"];
                    break;
                case 2:
                    cell = [self.tableView dequeueReusableCellWithIdentifier:@"cell"];
                    if (cell == NULL){
                        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"cell"];
                    }
                    cell.textLabel.text = @"Attendees";
                    cell.detailTextLabel.text = @"1";
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
        ;
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
