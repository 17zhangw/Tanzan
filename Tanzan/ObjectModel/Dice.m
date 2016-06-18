//
//  Dice.m
//  Tanzan
//
//  Created by williamzhang on 6/14/16.
//  Copyright © 2016 William-Trademarks. All rights reserved.
//

#import "Dice.h"

@interface Dice ()
@property (nonatomic, readwrite) int diceNumber;
@end

@implementation Dice

- (void)spinRandomNumber {
    int number = arc4random_uniform(6) + 1;
    self.diceNumber = number;
    
    [self setDiceImageWithMode:0];
}

- (void)diceDeselected {
    [self setDiceImageWithMode:0];
}

- (void)diceSelected {
    [self setDiceImageWithMode:1];
}

- (void)diceOperationPerformed {
    [self setDiceImageWithMode:2];
}

- (void)setDiceImageWithMode:(int)mode {
    NSString * dicePath = [NSString stringWithFormat:@"%dP%d",self.diceNumber,mode];
    NSString * path = [[NSBundle mainBundle] pathForResource:dicePath ofType:@"png"];
    NSData * imageData = [NSData dataWithContentsOfFile:path];
    [self.diceImage setImage:[UIImage imageWithData:imageData]];
    
    self.diceState = mode;
}

@end
