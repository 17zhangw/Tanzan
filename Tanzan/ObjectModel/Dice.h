//
//  Dice.h
//  Tanzan
//
//  Created by williamzhang on 6/14/16.
//  Copyright © 2016 William-Trademarks. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface Dice : NSObject

@property (nonatomic, readonly) int diceNumber;
@property (nonatomic, weak) UIImageView * diceImage;

@property (nonatomic) int diceState;

- (void)spinRandomNumber;
- (void)diceSelected;
- (void)diceOperationPerformed;
- (void)diceDeselected;

@end
