//
//  PSVC.m
//  Tanzan
//
//  Created by williamzhang on 6/15/16.
//  Copyright © 2016 William-Trademarks. All rights reserved.
//

#import "PSVC.h"
#import "GameManager.h"
#import "Dice.h"

@interface PSVC ()
@property (nonatomic) BOOL isProVersion;
@property (nonatomic) GameManager * manager;
@property (nonatomic) NSArray * diceObjects;

@property (nonatomic, strong) NSMutableString * calculationString;

@property (nonatomic, weak) UIButton * selectedOperationButton;
@property (nonatomic, weak) Dice * selectedDice;

@property (nonatomic, strong) AVAudioPlayer * backgroundPlayer;
@property (nonatomic, strong) AVAudioPlayer * effectsPlayer;
@end

@implementation PSVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.isProVersion = [[NSUserDefaults standardUserDefaults] boolForKey:@"Diecaster.ProV"];
    self.calculationString = [NSMutableString string];
    
    NSArray * images = @[self.imageZero,self.imageOne,self.imageTwo,
                         self.imageThree,self.imageFour,self.imageFive];
    for (UIImageView * i in images) {
        SEL sel = @selector(imageViewTapped:);
        UITapGestureRecognizer * t = [[UITapGestureRecognizer alloc] initWithTarget:self action:sel];
        [t setNumberOfTapsRequired:1];
        [i setUserInteractionEnabled:YES];
        [i addGestureRecognizer:t];
        [t setDelegate:self];
    }

    NSError * error;
    NSURL * url = [[NSBundle mainBundle] URLForResource:@"Background" withExtension:@"mp3"];
    self.backgroundPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
    [self.backgroundPlayer setNumberOfLoops:-1];
    [self.backgroundPlayer prepareToPlay];
    [self.backgroundPlayer play];
}

- (IBAction)back:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillDisappear:(BOOL)animated {
    [self.backgroundPlayer stop];
    [self.effectsPlayer stop];
}

- (void)viewDidAppear:(BOOL)animated {
    if (animated) {
        /* means transitioned */
        [self promptForDiceCount];
    }
}

- (void)promptForDiceCount {
    NSString * t = NSLocalizedString(@"SELECT_DICE_TITLE", nil);
    NSString * desc = NSLocalizedString(@"SELECT_DICE_MSG", nil);
    UIAlertController * ac = [UIAlertController alertControllerWithTitle:t message:desc preferredStyle:0];
    
    int count = self.isProVersion ? 6 : 3;
    for (int i = 2; i <= count; i++) {
        NSString * k = [NSString stringWithFormat:@"%d Dice",i];
        NSString * bT = NSLocalizedString(k, nil);
        UIAlertAction * a = [UIAlertAction actionWithTitle:bT style:0 handler:^(UIAlertAction * _Nonnull action) {
            [self initializeGameWithDiceCount:i];
        }];
        [ac addAction:a];
    }
    
    NSString * ti = NSLocalizedString(@"RETURN", nil);
    UIAlertAction * a = [UIAlertAction actionWithTitle:ti style:1 handler:^(UIAlertAction * _Nonnull action) {
        if (!self.manager)
            [self dismissViewControllerAnimated:YES completion:nil];
    }];
    
    [ac addAction:a];
    [self presentViewController:ac animated:YES completion:nil];
}

- (void)initializeGameWithDiceCount:(int)dice {
    GameManager * manager = [GameManager managerWithNumberOfDice:dice];
    self.manager = manager;
    [self shuffle:nil];
}

- (IBAction)shuffle:(id)sender {
    [self setHiddenStateOfImageViews:YES];
    NSArray * images = @[self.imageZero,self.imageOne,self.imageTwo,
                         self.imageThree,self.imageFour,self.imageFive];
    for (UIImageView * i in images) [i setTag:-1];
    
    GameTuple * t = [self.manager nextRoundWithImageViews:images];
    self.textLabel.text = [NSString stringWithFormat:@"%d",[t targetNumber]];
    self.diceObjects = [t diceObjects];    
    [self clear:nil];
    
    [self.backgroundPlayer pause];
    NSURL * url = [[NSBundle mainBundle] URLForResource:@"DiceSpinning" withExtension:@"mp3"];
    self.effectsPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
    self.effectsPlayer.delegate = self;
    [self.effectsPlayer play];
}

- (IBAction)changeDiceNumber:(id)sender {
    [self promptForDiceCount];
}

#pragma mark - Actions

- (void)imageViewTapped:(UITapGestureRecognizer *)tap {
    if ([self isLastCharNumber]) return;
    
    UIImageView * i = (UIImageView *)[tap view];
    NSInteger tag = [i tag];
    Dice * d = self.diceObjects[tag];
    if ([d diceState] == 1) return;
    
    self.selectedDice = d;
    [self.calculationString appendFormat:@"%d",d.diceNumber];
    [d diceSelected];
    [self.selectedOperationButton setSelected:NO];
    
    if ([self isAllDiceSelected]) {
        [self validateAnswer];
    }
}

- (void)setHiddenStateOfImageViews:(BOOL)state {
    NSArray * images = @[self.imageZero,self.imageOne,self.imageTwo,
                         self.imageThree,self.imageFour,self.imageFive];
    for (UIImageView * i in images) {
        [i setHidden:state];
    }
}

- (BOOL)isAllDiceSelected {
    for (Dice * dice in self.diceObjects) {
        if ([dice diceState] == 0) return NO;
    }
    
    return YES;
}

- (void)validateAnswer {
    NSExpression * exp = [NSExpression expressionWithFormat:self.calculationString];
    int number = [[exp expressionValueWithObject:nil context:nil] intValue];
    if (number != [self.textLabel.text intValue]) {
        [self displayImage:@"Missi5"];
    } else {
        [self displayImage:@"Correcti5"];
        
        [self.backgroundPlayer pause];
        NSURL * url = [[NSBundle mainBundle] URLForResource:@"Game-Clear" withExtension:@"mp3"];
        self.effectsPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
        self.effectsPlayer.delegate = self;
        [self.effectsPlayer play];
    }
}

- (void)displayImage:(NSString *)name {
    UIImageView * i = [[UIImageView alloc] initWithFrame:self.view.frame];
    NSString * gameOverStr = [[NSBundle mainBundle] pathForResource:name ofType:@"png"];
    NSData * dat = [[NSData alloc] initWithContentsOfFile:gameOverStr];
    UIImage * image = [UIImage imageWithData:dat];
    [i setImage:image];
    [i setAlpha:0.0];
    [self.view addSubview:i];
    
    [UIView animateWithDuration:0.5 animations:^{
        [i setAlpha:1.0];
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.5 animations:^{
            [i setAlpha:0.0];
        } completion:^(BOOL finished) {
            [i removeFromSuperview];
        }];
    }];
}

- (BOOL)isLastCharNumber {
    if ([self.calculationString length] == 0) return NO;
    unichar c = [self.calculationString characterAtIndex:[self.calculationString length]-1];
    if (c == '1') return YES;
    if (c == '2') return YES;
    if (c == '3') return YES;
    if (c == '4') return YES;
    if (c == '5') return YES;
    if (c == '6') return YES;
    return NO;
}

- (IBAction)add:(id)sender {
    if (![self isLastCharNumber] && [self.calculationString length] == 0) return;
    if (![self isLastCharNumber])
        self.calculationString = [[self.calculationString substringToIndex:[self.calculationString length]-1] mutableCopy];
    
    [self.selectedOperationButton setSelected:NO];
    self.selectedOperationButton = sender;
    [sender setSelected:YES];
    
    [self.calculationString appendString:@"+"];
    [self.selectedDice diceOperationPerformed];
}

- (IBAction)subtract:(id)sender {
    if (![self isLastCharNumber] && [self.calculationString length] == 0) return;
    if (![self isLastCharNumber])
        self.calculationString = [[self.calculationString substringToIndex:[self.calculationString length]-1] mutableCopy];
    
    [self.selectedOperationButton setSelected:NO];
    self.selectedOperationButton = sender;
    [sender setSelected:YES];
    
    [self.calculationString appendString:@"-"];
    [self.selectedDice diceOperationPerformed];
}

- (IBAction)multiply:(id)sender {
    if (![self isLastCharNumber] && [self.calculationString length] == 0) return;
    if (![self isLastCharNumber])
        self.calculationString = [[self.calculationString substringToIndex:[self.calculationString length]-1] mutableCopy];
    
    [self.selectedOperationButton setSelected:NO];
    self.selectedOperationButton = sender;
    [sender setSelected:YES];
    
    [self.calculationString appendString:@"*"];
    [self.selectedDice diceOperationPerformed];
}

- (IBAction)divide:(id)sender {
    if (![self isLastCharNumber] && [self.calculationString length] == 0) return;
    if (![self isLastCharNumber])
        self.calculationString = [[self.calculationString substringToIndex:[self.calculationString length]-1] mutableCopy];
    
    [self.selectedOperationButton setSelected:NO];
    self.selectedOperationButton = sender;
    [sender setSelected:YES];
    
    [self.calculationString appendString:@"/"];
    [self.selectedDice diceOperationPerformed];
    
}

- (IBAction)clear:(id)sender {
    self.calculationString = [NSMutableString string];
    [self.selectedOperationButton setSelected:NO];
    
    self.selectedOperationButton = nil;
    self.selectedDice = nil;
    
    for (Dice * dice in self.diceObjects) {
        [dice diceDeselected];
    }
}

#pragma mark - Audio Finished

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
    if (player == self.effectsPlayer) {
        [self.backgroundPlayer play];
    }
}

@end
