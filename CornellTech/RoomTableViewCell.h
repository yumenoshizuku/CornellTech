//
//  RoomTableViewCell.h
//  CornellTech
//
//  Created by Fanxing Meng on 12/5/14.
//  Copyright (c) 2014 Fanxing Meng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GooglePlus/GooglePlus.h>

@interface RoomTableViewCell : UITableViewCell <GPPSignInDelegate>

@property (weak, nonatomic) IBOutlet UILabel *label;
@property (weak, nonatomic) IBOutlet UILabel *detailLabel;
@property (nonatomic, strong) NSString *roomid;
@property (nonatomic, strong) NSString *roomName;
@property (nonatomic, strong) NSString *startTime;
@property (nonatomic, strong) NSString *endTime;

@end
