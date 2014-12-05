//
//  RoomsTableViewController.h
//  CornellTech
//
//  Created by Fanxing Meng on 12/5/14.
//  Copyright (c) 2014 Fanxing Meng. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RoomsTableViewController : UITableViewController 

@property (nonatomic, strong) NSMutableDictionary *room_list;
@property (nonatomic, strong) NSString *startTime;
@property (nonatomic, strong) NSString *endTime;
@property (nonatomic, strong) NSString *heading;
@end
