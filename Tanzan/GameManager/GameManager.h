//
//  GameManager.h
//  Tanzan
//
//  Created by williamzhang on 6/14/16.
//  Copyright © 2016 William-Trademarks. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "GameTuple.h"

@class Dice;
@interface GameManager : NSObject

@property (nonatomic, strong) NSString * score;

+ (GameManager *)managerWithNumberOfDice:(int)dice;
+ (GameManager *)managerWithNewGame;

- (GameTuple *)nextRoundWithImageViews:(NSArray *)imageViews;
- (void)updateScoreWithTimeLeft:(int)timeLeft;
- (BOOL)promptForNextRound:(int *)level stage:(int*)stage;

- (Dice *)addDice:(UIImageView *)image;
- (void)removeDice:(Dice *)dice;
- (void)diceModeSpinAll;

@end
