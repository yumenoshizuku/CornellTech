//
//  Counter.m
//  CornellTech
//
//  Created by Fanxing Meng on 11/12/14.
//  Copyright (c) 2014 Fanxing Meng. All rights reserved.
//

#import "Counter.h"

@implementation Counter
- (instancetype)init
{
    self = [super init];
    if (self) {
        self.count = 0;
    }
    return self;
}
@end
