//
//  GameTuple.h
//  Tanzan
//
//  Created by williamzhang on 6/15/16.
//  Copyright © 2016 William-Trademarks. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GameTuple : NSObject

@property (nonatomic) BOOL isFinished;

@property (nonatomic) int level;
@property (nonatomic) int stage;

@property (nonatomic) int timeLimit;
@property (nonatomic) int targetNumber;

@property (nonatomic) NSArray * diceObjects;

@end
