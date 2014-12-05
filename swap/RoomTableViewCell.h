//
//  RoomTableViewCell.h
//  CornellTech
//
//  Created by Fanxing Meng on 12/5/14.
//  Copyright (c) 2014 Fanxing Meng. All rights reserved.
//


#import <UIKit/UIKit.h>
#import <GooglePlus/GooglePlus.h>
@interface RoomTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *label;
@property (weak, nonatomic) IBOutlet UILabel *detailLabel;
@property (weak, nonatomic) IBOutlet UIButton *bookButton;
@property (nonatomic, strong) NSString *roomid;

@end
