//
//  Ranker.h
//  Tanzan
//
//  Created by williamzhang on 6/15/16.
//  Copyright © 2016 William-Trademarks. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Rank : NSObject
@property (nonatomic) int score;
@property (nonatomic) NSString * formattedDate;
@end

@interface Ranker : NSObject

@property (nonatomic, strong) NSMutableArray * ranks;
- (int)insertScore:(int)score;

@end
