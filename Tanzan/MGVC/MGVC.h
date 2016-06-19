//
//  MGVC.h
//  Tanzan
//
//  Created by williamzhang on 6/16/16.
//  Copyright © 2016 William-Trademarks. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface MGVC : UIViewController <AVAudioPlayerDelegate, UIGestureRecognizerDelegate>

@property (nonatomic, strong) IBOutlet UIImageView * imageZero;
@property (nonatomic, strong) IBOutlet UIImageView * imageOne;
@property (nonatomic, strong) IBOutlet UIImageView * imageTwo;
@property (nonatomic, strong) IBOutlet UIImageView * imageThree;
@property (nonatomic, strong) IBOutlet UIImageView * imageFour;
@property (nonatomic, strong) IBOutlet UIImageView * imageFive;

@property (nonatomic, strong) IBOutlet UIImageView * diceBackground;
@property (nonatomic, strong) IBOutlet UILabel * textLabel;

- (IBAction)add:(id)sender;
- (IBAction)subtract:(id)sender;
- (IBAction)multiply:(id)sender;
- (IBAction)divide:(id)sender;
- (IBAction)clear:(id)sender;

@property (nonatomic, strong) IBOutlet UIView * timerView;
@property (nonatomic, strong) IBOutlet UIImageView * levelIndicator;
@property (nonatomic, strong) IBOutlet UIImageView * stageIndicator;

@property (nonatomic, strong) IBOutlet UIImageView * sSlot0;
@property (nonatomic, strong) IBOutlet UIImageView * sSlot1;
@property (nonatomic, strong) IBOutlet UIImageView * sSlot2;
@property (nonatomic, strong) IBOutlet UIImageView * sSlot3;
@property (nonatomic, strong) IBOutlet UIImageView * sSlot4;

@end
