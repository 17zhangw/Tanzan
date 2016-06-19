//
//  Scoring+CoreDataProperties.h
//  Tanzan
//
//  Created by williamzhang on 6/14/16.
//  Copyright © 2016 William-Trademarks. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Scoring.h"

NS_ASSUME_NONNULL_BEGIN

@interface Scoring (CoreDataProperties)

@property (nullable, nonatomic, retain) NSNumber *stage;
@property (nullable, nonatomic, retain) NSNumber *number;
@property (nullable, nonatomic, retain) NSNumber *level;
@property (nullable, nonatomic, retain) NSNumber *award;
@property (nullable, nonatomic, retain) NSNumber *clearscore;
@property (nullable, nonatomic, retain) NSNumber *time;

@end

NS_ASSUME_NONNULL_END
