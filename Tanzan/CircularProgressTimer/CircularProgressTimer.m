//
//  CircularProgressTimer.m
//  CircularProgressTimer
//
//  Created by mc on 6/30/13.
//  Copyright (c) 2013 mauricio. All rights reserved.
//

#import "CircularProgressTimer.h"
#import "ExternalBound.h"

@implementation CircularProgressTimer

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setBackgroundColor:[UIColor clearColor]];
        [self setup:frame];
    }
    
    return self;
}

- (void)drawRect:(CGRect)rect
{
    ExternalBound *e = [[ExternalBound alloc] initWithFrame:rect];
    [e setPercent:_percent];
    [e setTotalSeconds:_totalSeconds];
    [e setSecondsLeft:_secondsLeft];
    [self addSubview:e];
    [self sendSubviewToBack:e];
    
    UIImageView *image = [[UIImageView alloc] initWithFrame:rect];
    [image setImage:[UIImage imageNamed:@"circle.png"]];
    [self addSubview:image];
    [self sendSubviewToBack:image];
}

- (void)setup:(CGRect)frame
{
    
}

@end
