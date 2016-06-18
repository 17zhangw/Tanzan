//
//  DMVC.h
//  Tanzan
//
//  Created by williamzhang on 6/16/16.
//  Copyright © 2016 William-Trademarks. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DMVC : UIViewController

- (IBAction)back:(id)sender;
- (IBAction)shuffleLeft:(id)sender;
- (IBAction)shuffleRight:(id)sender;

- (IBAction)increaseDice:(id)sender;
- (IBAction)decreaseDice:(id)sender;

@property (nonatomic, weak) IBOutlet UIButton * shuffleLeft;
@property (nonatomic, weak) IBOutlet UIButton * shuffleRight;
@property (nonatomic, weak) IBOutlet UIButton * upButton;
@property (nonatomic, weak) IBOutlet UIButton * downButton;

@property (nonatomic, weak) IBOutlet UIImageView * image1;
@property (nonatomic, weak) IBOutlet UIImageView * image2;
@property (nonatomic, weak) IBOutlet UIImageView * image3;
@property (nonatomic, weak) IBOutlet UIImageView * image4;
@property (nonatomic, weak) IBOutlet UIImageView * image5;
@property (nonatomic, weak) IBOutlet UIImageView * image6;

@end
