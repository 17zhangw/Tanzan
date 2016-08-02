//
//  MGVC.m
//  Tanzan
//
//  Created by williamzhang on 6/16/16.
//  Copyright © 2016 William-Trademarks. All rights reserved.
//

/*
 Todolist:
 (1) Transcribe How-to-play screens
 (2) Localizations
 (3) Test IAP
 
 */

#import "MGVC.h"
#import "GameManager.h"
#import "Dice.h"
#import "Ranker.h"
#import "RankView.h"

#import "CircularProgressTimer.h"

@interface MGVC ()
@property (nonatomic) BOOL isProVersion;

@property (nonatomic) BOOL isGameOver;
@property (nonatomic) BOOL isIncorrect;

@property (nonatomic) GameManager * manager;
@property (nonatomic) NSArray * diceObjects;

@property (nonatomic, strong) NSMutableString * calculationString;

@property (nonatomic, weak) UIButton * selectedOperationButton;
@property (nonatomic, weak) Dice * selectedDice;

@property (nonatomic, strong) AVAudioPlayer * backgroundPlayer;
@property (nonatomic, strong) AVAudioPlayer * effectsPlayer;

@property (nonatomic) int totalSeconds;
@property (nonatomic) int secondsLeft;
@property (nonatomic) BOOL isEmergencyPlaying;

@property (nonatomic) NSTimer * timer;
@property (nonatomic) UIView * countdownView;
@property (nonatomic, strong) CircularProgressTimer *progressTimerView;
@end

@implementation MGVC

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
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(viewDidAppear:) name:UIApplicationWillEnterForegroundNotification object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewWillDisappear:(BOOL)animated {
    [self.backgroundPlayer stop];
    [self.effectsPlayer stop];
    
    if ([self.timer isValid]) {
        [self.timer invalidate];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    if (animated) {
        self.manager = [GameManager managerWithNewGame];
        [self displayMarkdown];
    } else {
        if (!self.isGameOver)
            [self.backgroundPlayer play];
        if (![self.timer isValid] && self.secondsLeft > 0) {
            SEL sel = @selector(countdownSequence);
            self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:sel userInfo:nil repeats:YES];
        }
    }
}

#pragma mark - Display Markdown

- (void)displayMarkdown {
    self.selectedDice = nil;
    self.selectedOperationButton = nil;
    
    [self drawCircularProgressBarWithSecondsLeft:self.totalSeconds];
    self.textLabel.text = @"";
    
    [self.manager updateScoreWithTimeLeft:self.secondsLeft];
    for (int i = 0; i < [[self.manager score] length]; i++) {
        unichar c = [[self.manager score] characterAtIndex:i];
        NSString * iName = [NSString stringWithFormat:@"N%c",c];
        NSString * path = [[NSBundle mainBundle] pathForResource:iName ofType:@"png"];
        NSData * d = [[NSData alloc] initWithContentsOfFile:path];
        UIImage * img = [UIImage imageWithData:d];
        
        NSString * key = [NSString stringWithFormat:@"sSlot%d",i];
        id obj = [self valueForKey:key];
        if ([obj isKindOfClass:[UIImageView class]])
            [(UIImageView*)obj setImage:img];
    }
    
    int level = 1;
    int stage = 1;
    BOOL doesRoundExist = [self.manager promptForNextRound:&level stage:&stage];
    if (!doesRoundExist) {
        [self gameFinishedSequence];
        return;
    }
    
    [self setHiddenStateOfImageViews:YES];
    [self.levelIndicator setHidden:YES];
    [self.stageIndicator setHidden:YES];
    
    self.countdownView = [[UIView alloc] initWithFrame:self.diceBackground.frame];
    CGFloat width = self.diceBackground.frame.size.width/2;
    CGFloat height = 40;
    CGFloat x = self.diceBackground.frame.size.width/2 - width / 2;
    CGFloat ly = self.diceBackground.frame.size.height/2 - 20 - height;
    CGFloat sy = self.diceBackground.frame.size.height/2 + 20;
    
    UIImageView * l = [[UIImageView alloc] initWithFrame:CGRectMake(x, ly, width, height)];
    UIImageView * s = [[UIImageView alloc] initWithFrame:CGRectMake(x, sy, width, height)];
    
    NSString * lImage = [NSString stringWithFormat:@"Level%d",level];
    NSString * sImage = [NSString stringWithFormat:@"Stage%d",stage];
    [l setImage:[UIImage imageNamed:lImage]];
    [s setImage:[UIImage imageNamed:sImage]];
    
    [self.countdownView addSubview:l];
    [self.countdownView addSubview:s];
    [self.countdownView setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview:self.countdownView];
    
    self.secondsLeft = 2;
    SEL sel = @selector(countdownSequence);
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:sel userInfo:nil repeats:YES];
}

- (void)countdownSequence {
    self.secondsLeft--;
    if (self.countdownView) {
        if (self.secondsLeft <= 0) {
            [self.timer invalidate];
            [self.countdownView removeFromSuperview];
            self.countdownView = nil;
            
            [self nextRound];
        }
    } else {
        [self drawCircularProgressBarWithSecondsLeft:self.secondsLeft];
        
        if (self.secondsLeft <= 8) {
            if (!self.isEmergencyPlaying) {
                self.isEmergencyPlaying = YES;
                NSError * e;
                NSURL * u = [[NSBundle mainBundle] URLForResource:@"Siren" withExtension:@"mp3"];
                [self.backgroundPlayer pause];
                
                self.effectsPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:u error:&e];
                [self.effectsPlayer play];
            }
        }
        
        if (self.secondsLeft <= 0) {
            [self.timer invalidate];
            [self displayImage:@"GameOveri5"];
        }
    }
}

- (void)nextRound {
    NSArray * images = @[self.imageZero,self.imageOne,self.imageTwo,
                         self.imageThree,self.imageFour,self.imageFive];
    for (UIImageView * i in images) [i setTag:-1];
    
    GameTuple * t = [self.manager nextRoundWithImageViews:images];
    if ([t isFinished]) {
        if ([t level] == 2) {
            /* finished because not pro */
            NSString * t = NSLocalizedString(@"GAMEFINISHED", nil);
            NSString * msg = NSLocalizedString(@"BUYPRO", nil);
            UIAlertController * a = [UIAlertController alertControllerWithTitle:t
                                                                        message:msg
                                                                 preferredStyle:UIAlertControllerStyleAlert];
            
            NSString * d = NSLocalizedString(@"DISMISS", nil);
            UIAlertAction * c = [UIAlertAction actionWithTitle:d style:UIAlertActionStyleCancel handler:nil];
            [a addAction:c];
            [self presentViewController:a animated:YES completion:nil];
        }
        [self gameFinishedSequence];
        return;
    } else if (!t) {
        NSString * title = NSLocalizedString(@"ERROR", nil);
        NSString * msg = NSLocalizedString(@"ERROR_MSG", nil);
        UIAlertController * a = [UIAlertController alertControllerWithTitle:title
                                                                    message:msg
                                                             preferredStyle:UIAlertControllerStyleAlert];
        
        NSString * d = NSLocalizedString(@"DISMISS", nil);
        UIAlertAction * c = [UIAlertAction actionWithTitle:d style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            [self dismissViewControllerAnimated:YES completion:nil];
        }];
        [a addAction:c];
        
        [self presentViewController:a animated:YES completion:nil];
        return;
    }
    
    self.textLabel.text = [NSString stringWithFormat:@"%d",[t targetNumber]];
    self.diceObjects = [t diceObjects];
    [self clear:nil];
    
    NSString * lImage = [NSString stringWithFormat:@"Level%d",[t level]];
    NSString * sImage = [NSString stringWithFormat:@"Stage%d",[t stage]];
    [self.levelIndicator setImage:[UIImage imageNamed:lImage]];
    [self.stageIndicator setImage:[UIImage imageNamed:sImage]];
    
    [self.levelIndicator setHidden:NO];
    [self.stageIndicator setHidden:NO];
    
    self.secondsLeft = [t timeLimit];
    self.totalSeconds = [t timeLimit];
    
    SEL sel = @selector(countdownSequence);
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:sel userInfo:nil repeats:YES];
    
    [self.backgroundPlayer pause];
    NSURL * url = [[NSBundle mainBundle] URLForResource:@"DiceSpinning" withExtension:@"mp3"];
    self.effectsPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
    self.effectsPlayer.delegate = self;
    [self.effectsPlayer play];
}

#pragma mark - Draw Circular View

- (void)drawCircularProgressBarWithSecondsLeft:(NSInteger)seconds {
    [self.progressTimerView removeFromSuperview];
    self.progressTimerView = nil;
    
    // Init our view and set current circular progress bar value
    CGRect progressBarFrame = self.timerView.frame;
    self.progressTimerView = [[CircularProgressTimer alloc] initWithFrame:progressBarFrame];
    [self.progressTimerView setCenter:self.view.center];
    [self.progressTimerView setTotalSeconds:self.totalSeconds];
    [self.progressTimerView setPercent:seconds];
    [self.progressTimerView setSecondsLeft:seconds];
    
    [self.view addSubview:self.progressTimerView];
    self.progressTimerView.center = self.timerView.center;
}

#pragma mark - Game Finished Sequence

- (void)gameFinishedSequence {
    self.isGameOver = YES;
    [self.backgroundPlayer stop];
    [self.effectsPlayer stop];
    self.backgroundPlayer = nil;
    self.effectsPlayer = nil;
    
    [self.timer invalidate];
    self.timer = nil;
    
    NSURL * url = [[NSBundle mainBundle] URLForResource:@"Game-Over" withExtension:@"mp3"];
    self.backgroundPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
    [self.backgroundPlayer play];
    
    RankView * rankView = (RankView *)[[NSBundle mainBundle] loadNibNamed:@"RankingView" owner:nil options:nil][0];
    CGFloat scale = self.view.frame.size.width / rankView.frame.size.width;
    rankView.transform = CGAffineTransformMakeScale(scale, 1);
    
    Ranker * ranker = [Ranker new];
    int index = [ranker insertScore:[[self.manager score] intValue]];
    NSString * rankTitle = [NSString stringWithFormat:@"T%d",index];
    [[rankView imageView] setImage:[UIImage imageNamed:rankTitle]];
    
    if (index == 1) {
        int pic = floor([[self.manager score] intValue] / 200.0);
        NSString * p = [NSString stringWithFormat:@"Score%d",pic];
        NSString * pS = [[NSBundle mainBundle] pathForResource:p ofType:@"png"];
        NSData * d = [[NSData alloc] initWithContentsOfFile:pS];
        UIImage * i = [UIImage imageWithData:d];
        UIImageView * iV = [[UIImageView alloc] initWithFrame:self.view.frame];
        [iV setImage:i];
        [iV setContentMode:UIViewContentModeScaleToFill];
        [iV setBackgroundColor:[UIColor clearColor]];
        
        UIImage * im = [UIImage imageNamed:@"Rose.png"];
        UIImageView * imView = [[UIImageView alloc] initWithFrame:self.view.frame];
        [imView setImage:im];
        [imView setContentMode:UIViewContentModeScaleToFill];
        [imView setBackgroundColor:[UIColor blackColor]];
        
        [self.view addSubview:imView];
        [self.view addSubview:iV];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [imView removeFromSuperview];
            [iV removeFromSuperview];
            [self updateRankInfo:ranker info:rankView];
        });
    } else [self updateRankInfo:ranker info:rankView];
}

- (void)updateRankInfo:(Ranker *)ranker info:(RankView *)rankView {
    NSArray * ranks = [ranker ranks];
    for (Rank * r in ranks) {
        int index = (int)[ranks indexOfObject:r] + 1;
        NSString * s = [NSString stringWithFormat:@"score%d",index];
        NSString * d = [NSString stringWithFormat:@"date%d",index];
        [(UILabel*)[rankView valueForKey:s] setText:[NSString stringWithFormat:@"%d",[r score]]];
        [(UILabel*)[rankView valueForKey:d] setText:[r formattedDate]];
    }
    
    CGRect frame = CGRectMake(0, self.view.frame.size.height - rankView.frame.size.height,
                              rankView.frame.size.width, rankView.frame.size.height);
    [rankView setFrame:frame];
    [self.view addSubview:rankView];
    
    UIButton * but = [UIButton buttonWithType:UIButtonTypeSystem];
    [but setBackgroundImage:[UIImage imageNamed:@"Back"] forState:UIControlStateNormal];
    [but addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    [but setFrame:CGRectMake(self.view.frame.size.width - 100, rankView.frame.origin.y-40, 100, 40)];
    [self.view addSubview:but];
}

- (void)back {
    [self dismissViewControllerAnimated:YES completion:nil];
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
    if (self.isGameOver) return;
    
    [self.timer invalidate];
    
    NSExpression * exp = [NSExpression expressionWithFormat:self.calculationString];
    int number = [[exp expressionValueWithObject:nil context:nil] intValue];
    if (number != [self.textLabel.text intValue]) {
        [self displayImage:@"Missi5"];
        
        SEL sel = @selector(countdownSequence);
        self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:sel userInfo:nil repeats:YES];
        self.isIncorrect = YES;
    } else {
        [self.backgroundPlayer pause];
        NSURL * url = [[NSBundle mainBundle] URLForResource:@"Game-Clear" withExtension:@"mp3"];
        self.effectsPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
        self.effectsPlayer.delegate = self;
        [self.effectsPlayer play];
        
        [self displayImage:@"Correcti5"];
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
    
    [UIView animateWithDuration:1.0 animations:^{
        [i setAlpha:1.0];
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:1.0 animations:^{
            [i setAlpha:0.0];
        } completion:^(BOOL finished) {
            [i removeFromSuperview];
            
            if ([name isEqualToString:@"Correcti5"]) {
                [self displayMarkdown];
            }
            
            else if ([name isEqualToString:@"GameOveri5"]) {
                [self gameFinishedSequence];
            }
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
    if (self.isIncorrect || self.isGameOver) return;
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
    if (self.isIncorrect || self.isGameOver) return;
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
    if (self.isIncorrect || self.isGameOver) return;
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
    if (self.isIncorrect || self.isGameOver) return;
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
    if (self.isGameOver) return;
    self.calculationString = [NSMutableString string];
    [self.selectedOperationButton setSelected:NO];
    
    self.selectedOperationButton = nil;
    self.selectedDice = nil;
    self.isIncorrect = NO;
    
    for (Dice * dice in self.diceObjects) {
        [dice diceDeselected];
    }
}

#pragma mark - Audio Finished

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
    if (player == self.effectsPlayer && !self.isGameOver) {
        [self.backgroundPlayer play];
    }
}

@end
