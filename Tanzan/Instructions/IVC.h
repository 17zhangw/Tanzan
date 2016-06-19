//
//  IVC.h
//  Tanzan
//
//  Created by williamzhang on 6/16/16.
//  Copyright © 2016 William-Trademarks. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IVC : UIViewController <UIScrollViewDelegate>

@property (nonatomic, strong) IBOutlet UIScrollView * scrollView;
- (IBAction)back:(id)sender;

@end
