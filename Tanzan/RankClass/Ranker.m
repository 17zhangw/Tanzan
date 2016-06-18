//
//  Ranker.m
//  Tanzan
//
//  Created by williamzhang on 6/15/16.
//  Copyright © 2016 William-Trademarks. All rights reserved.
//

#import "Ranker.h"

@implementation Rank
@end

@interface Ranker ()
@property (nonatomic, strong) NSDateFormatter * formatter;
@end

@implementation Ranker

- (id)init {
    if ((self = [super init])) {
        self.formatter = [[NSDateFormatter alloc] init];
        [self.formatter setDateFormat:@"MM/dd/YY HH:mm"];
        
        NSString * path = [self filePath];
        NSMutableArray * scores = [NSMutableArray array];
        if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
            NSString * contents = [[NSString alloc] initWithContentsOfFile:path encoding:4 error:nil];
            NSArray * split = [contents componentsSeparatedByString:@"\n"];
            for (NSString * s in split) {
                NSArray * a = [s componentsSeparatedByString:@"."];
                if ([a count] != 2) continue;
                
                Rank * r = [[Rank alloc] init];
                [r setScore:[a[0] intValue]];
                [r setFormattedDate:a[1]];
                [scores addObject:r];
            }
        }
        
        self.ranks = scores;
    }
    return self;
}

- (NSString *)filePath {
    NSString * documents = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    NSString * path = [documents stringByAppendingPathComponent:@"HS.txt"];
    return path;
}

- (int)insertScore:(int)score {
    NSDate * date = [NSDate date];
    BOOL didInsert = NO;
    
    int index = 0;
    for (int i = 0; i < [self.ranks count]; i++) {
        Rank * r = self.ranks[i];
        if (score >= [r score]) {
            Rank * nR = [Rank new];
            [nR setScore:score];
            [nR setFormattedDate:[self.formatter stringFromDate:date]];
            
            if (score == [r score]) [self.ranks replaceObjectAtIndex:i withObject:nR];
            else [self.ranks insertObject:nR atIndex:i];
            didInsert = YES;
            index = i + 1;
            break;
        }
    }
    
    if (!didInsert && [self.ranks count] < 10) {
        Rank * nR = [Rank new];
        [nR setScore:score];
        [nR setFormattedDate:[self.formatter stringFromDate:date]];
        [self.ranks addObject:nR];
        index = (int)[self.ranks indexOfObject:nR] + 1;
    }
    
    [self save];
    return index;
}

- (void)save {
    NSMutableString * s = [NSMutableString string];
    for (Rank * r in self.ranks) {
        [s appendFormat:@"%d.%@\n",[r score],[r formattedDate]];
    }
    
    [s writeToFile:[self filePath] atomically:NO encoding:4 error:nil];
}

@end
