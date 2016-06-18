//
//  ExternalBound.h
//  CircularProgress
//
//  Created by williamzhang on 10/25/14.
//  Copyright (c) 2014 mauricio. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ExternalBound : UIView {
    CGFloat startAngle;
    CGFloat endAngle;
}

@property (nonatomic) NSInteger percent;
@property (nonatomic) double totalSeconds;
@property (nonatomic) NSInteger secondsLeft;

@end
