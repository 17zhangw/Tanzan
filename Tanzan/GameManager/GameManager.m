//
//  GameManager.m
//  Tanzan
//
//  Created by williamzhang on 6/14/16.
//  Copyright © 2016 William-Trademarks. All rights reserved.
//

#import "GameManager.h"
#import "Dice.h"
#import "AppDelegate.h"
#import "Scoring.h"

@interface GameManager ()
@property (nonatomic, strong) NSMutableArray * diceObjects;

@property (nonatomic) BOOL isGameMode;
@property (nonatomic) int level;
@property (nonatomic) int stage;

@property (nonatomic) Scoring * scoringObject;
@end

@implementation GameManager

+ (GameManager *)managerWithNewGame {
    GameManager * manager = [GameManager new];
    [manager setIsGameMode:YES];
    
    [manager setLevel:1];
    [manager setStage:0];
    [manager setScore:@"0"];
    [manager setDiceObjects:[NSMutableArray arrayWithObject:[Dice new]]];
    return manager;
}

+ (GameManager *)managerWithNumberOfDice:(int)dice {
    GameManager * manager = [GameManager new];
    [manager setIsGameMode:NO];
    
    NSMutableArray * a = [NSMutableArray array];
    for (int i = 0; i < dice; i++) {
        Dice * dice = [Dice new];
        [a addObject:dice];
    }
    
    [manager setDiceObjects:a];
    return manager;
}

- (id)init {
    if ((self = [super init])) {
        if (!self.diceObjects) self.diceObjects = [NSMutableArray array];
    }
    return self;
}

- (BOOL)promptForNextRound:(int *)level stage:(int*)stage {
    int nS = self.stage + 1;
    int nL = self.level;
    if (nS > 10) {
        nL = self.level + 1;
        nS = 1;
    }
    
    int maxLevel = [[NSUserDefaults standardUserDefaults] boolForKey:@"Diecaster.ProV"] ? 5 : 2;
    if (nL > maxLevel) return NO;
    
    *level = nL;
    *stage = nS;
    return YES;
}

- (void)updateScoreWithTimeLeft:(int)timeLeft {
    if (self.scoringObject) {
        int scoreAddition = [[self.scoringObject clearscore] intValue] + ceil([[self.scoringObject award] doubleValue] * timeLeft);
        int prevScore = [self.score intValue];
        self.score = [NSString stringWithFormat:@"%d",scoreAddition + prevScore];
    }
}

- (GameTuple *)nextRoundWithImageViews:(NSArray *)imageViews {
    GameTuple * tuple = [GameTuple new];
    if (self.isGameMode) {
        self.stage++;
        if (self.stage > 10) {
            self.level++;
            self.stage = 1;
            [self.diceObjects addObject:[Dice new]];
        }
        
        int maxLevel = [[NSUserDefaults standardUserDefaults] boolForKey:@"Diecaster.ProV"] ? 5 : 2;
        if (self.level > maxLevel) {
            [tuple setLevel:maxLevel];
            [tuple setIsFinished:YES];
            return tuple;
        }
        
        NSManagedObjectContext * context = [(AppDelegate*)[[UIApplication sharedApplication] delegate] managedObjectContext];
        NSFetchRequest * fetch = [NSFetchRequest fetchRequestWithEntityName:@"Scoring"];
        NSPredicate * lPred = [NSPredicate predicateWithFormat:@"level==%d",self.level];
        NSPredicate * sPred = [NSPredicate predicateWithFormat:@"stage==%d",self.stage];
        NSPredicate * aPred = [NSCompoundPredicate andPredicateWithSubpredicates:@[lPred,sPred]];
        [fetch setPredicate:aPred];
        
        NSError * error;
        NSArray * result = [context executeFetchRequest:fetch error:&error];
        if ([result count] == 0) return nil;
        self.scoringObject = result[0];
        
        [tuple setLevel:self.level];
        [tuple setStage:self.stage];
        [tuple setTimeLimit:[[self.scoringObject time] intValue]];
        
        for (int i = (int)[self.diceObjects count]; i < [[self.scoringObject number] intValue]; i++) {
            [self.diceObjects addObject:[Dice new]];
        }
    }
    
    for (int i = 0; i < [self.diceObjects count]; i++) {
        int dest = arc4random_uniform((int)[self.diceObjects count]);
        [self.diceObjects exchangeObjectAtIndex:i withObjectAtIndex:dest];
    }
    
    [self associateImageViewsWithDice:imageViews];
    for (Dice * d in self.diceObjects) {
        [d spinRandomNumber];
    }
    
    int value = 0;
    while (value <= 0 || value >= 100) {
        NSMutableString * expressionStr = [NSMutableString string];
        for (Dice * d in self.diceObjects) {
            [expressionStr appendFormat:@"%d.0",[d diceNumber]];
            if (d != [self.diceObjects lastObject]) {
                [expressionStr appendString:[self generateMathOperator]];
            }
        }
        
        NSExpression * exp = [NSExpression expressionWithFormat:expressionStr];
        NSNumber * calcVal = [exp expressionValueWithObject:nil context:nil];
        if ([calcVal intValue] == [calcVal floatValue])
            value = [calcVal intValue];
        else value = -1;
        NSLog(@"%@",expressionStr);
    }
    
    [tuple setTargetNumber:value];
    [tuple setDiceObjects:self.diceObjects];
    return tuple;
}

- (NSString *)generateMathOperator {
    int r = arc4random_uniform(4);
    switch (r) {
        case 0:
            return @"+";
            break;
        case 1:
            return @"-";
            break;
        case 2:
            return @"*";
            break;
        case 3:
            return @"/";
            break;
        default:
            return nil;
            break;
    }
}

/* imageView layout
 0 1 2
 3 4 5
*/

- (void)associateImageViewsWithDice:(NSArray *)imageViews {
    int * index = NULL;
    int count = (int)[self.diceObjects count];
    if (count == 6) {
        int ind[6] = {0,1,2,3,4,5};
        index = ind;
    } else if (count == 4) {
        int ind[4] = { 0,2,3,5 };
        index = ind;
    } else if (count == 3 || count == 5) {
        int r = arc4random_uniform(2);
        if (r == 0 && count == 3) {
            int ind[3] = { 0,4,2 };
            index = ind;
        } else if (r == 1 && count == 3) {
            int ind[3] = { 3,1,5 };
            index = ind;
        } else if (r == 0 && count == 5) {
            int ind[5] = { 0,1,2,3,5 };
            index = ind;
        } else if (r == 1 && count == 5) {
            int ind[5] = { 0,2,3,4,5 };
            index = ind;
        }
    } else if (count == 2) {
        int r = arc4random_uniform(3);
        if (r == 0) {
            int ind[2] = {0,5};
            index = ind;
        } else if (r == 1) {
            int ind[2] = {1,4};
            index = ind;
        } else if (r == 2) {
            int ind[2] = {2,3};
            index = ind;
        }
    }
    
    for (int i = 0; i < count; i++) {
        [(Dice*)self.diceObjects[i] setDiceImage:imageViews[index[i]]];
        [imageViews[index[i]] setTag:i];
        [imageViews[index[i]] setHidden:NO];
    }
}

#pragma mark - Dice

- (Dice *)addDice:(UIImageView *)image {
    [image setHidden:NO];
    
    Dice * d = [Dice new];
    [d setDiceImage:image];
    [d spinRandomNumber];
    [self.diceObjects addObject:d];
    return d;
}

- (void)removeDice:(Dice *)dice {
    [[dice diceImage] setHidden:YES];
    [self.diceObjects removeObject:dice];
}

- (void)diceModeSpinAll {
    for (Dice * d in self.diceObjects) {
        [d spinRandomNumber];
    }
}

@end
