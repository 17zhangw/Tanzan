//
//  ExternalBound.m
//  CircularProgress
//
//  Created by williamzhang on 10/25/14.
//  Copyright (c) 2014 mauricio. All rights reserved.
//

#import "ExternalBound.h"

@implementation ExternalBound

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setBackgroundColor:[UIColor clearColor]];
    }
    
    return self;
}

- (void)drawRect:(CGRect)rect {
    double fullCircle = 2 * M_PI;
    double percentage = fullCircle + (_percent / -_totalSeconds * 2 * M_PI);
    
    float initialAngleFactor = 1.5 * M_PI;
    UIBezierPath *bezierPath = [UIBezierPath bezierPath];
    [bezierPath addArcWithCenter:CGPointMake(rect.size.width / 2, rect.size.height / 2)
                          radius:rect.size.width/4
                      startAngle:0 + initialAngleFactor
                        endAngle:percentage + initialAngleFactor
                       clockwise:YES];
    bezierPath.lineWidth = rect.size.width/2;
    
    double green = _secondsLeft/_totalSeconds;
    double red = 1.0 - _secondsLeft/_totalSeconds;
    [[UIColor colorWithRed:red green:green blue:0 alpha:1] setStroke];
    [bezierPath stroke];
}

@end
