//
//  MSVC.h
//  Tanzan
//
//  Created by williamzhang on 6/15/16.
//  Copyright © 2016 William-Trademarks. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IAPurchaser.h"

@interface MSVC : UIViewController <IAPurchaserDelegate>

@property (nonatomic, strong) IBOutlet UIImageView * bgImageView;

@property (nonatomic, strong) IBOutlet UIButton * startButton;
@property (nonatomic, strong) IBOutlet UIButton * practiceButton;
@property (nonatomic, strong) IBOutlet UIButton * rankingButton;
@property (nonatomic, strong) IBOutlet UIButton * instructionButton;
@property (nonatomic, strong) IBOutlet UIButton * upgradeButton;
@property (nonatomic, strong) IBOutlet UIButton * restoreButton;
@property (nonatomic, strong) IBOutlet UILongPressGestureRecognizer * lpGestureRecognizer;

- (IBAction)start:(id)sender;
- (IBAction)practice:(id)sender;
- (IBAction)ranking:(id)sender;
- (IBAction)instruction:(id)sender;
- (IBAction)upgrade:(id)sender;
- (IBAction)restore:(id)sender;
- (IBAction)hiddenMode:(id)sender;

@end
