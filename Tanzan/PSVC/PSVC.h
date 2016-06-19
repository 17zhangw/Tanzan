//
//  PSVC.h
//  Tanzan
//
//  Created by williamzhang on 6/15/16.
//  Copyright © 2016 William-Trademarks. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface PSVC : UIViewController <AVAudioPlayerDelegate, UIGestureRecognizerDelegate>

@property (nonatomic, strong) IBOutlet UIImageView * imageZero;
@property (nonatomic, strong) IBOutlet UIImageView * imageOne;
@property (nonatomic, strong) IBOutlet UIImageView * imageTwo;
@property (nonatomic, strong) IBOutlet UIImageView * imageThree;
@property (nonatomic, strong) IBOutlet UIImageView * imageFour;
@property (nonatomic, strong) IBOutlet UIImageView * imageFive;

@property (nonatomic, strong) IBOutlet UILabel * textLabel;

- (IBAction)shuffle:(id)sender;
- (IBAction)changeDiceNumber:(id)sender;

- (IBAction)add:(id)sender;
- (IBAction)subtract:(id)sender;
- (IBAction)multiply:(id)sender;
- (IBAction)divide:(id)sender;
- (IBAction)clear:(id)sender;

- (IBAction)back:(id)sender;

@end
