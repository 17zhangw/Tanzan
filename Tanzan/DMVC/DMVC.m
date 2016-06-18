//
//  DMVC.m
//  Tanzan
//
//  Created by williamzhang on 6/16/16.
//  Copyright © 2016 William-Trademarks. All rights reserved.
//

#import "DMVC.h"
#import "GameManager.h"

@interface DMVC ()
@property (nonatomic, strong) NSTimer * timer;

@property (nonatomic) BOOL isShuffling;
@property (nonatomic) BOOL isLeftPressed;
@property (nonatomic) BOOL isRightPressed;

@property (nonatomic) GameManager * manager;
@property (nonatomic) int maxNumber;

@property (nonatomic) NSMutableArray * diceObjects;
@end

@implementation DMVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {
    SEL sel = @selector(validateShuffleStates);
    self.timer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:sel userInfo:nil repeats:YES];
    
    self.manager = [GameManager new];
    self.maxNumber = [[NSUserDefaults standardUserDefaults] boolForKey:@"Diecaster.ProV"] ? 6 : 3;
    self.diceObjects = [NSMutableArray array];
    
    [self increaseDice:nil];
    [self increaseDice:nil];
    [self increaseDice:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)back:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)validateShuffleStates {
    if (self.isLeftPressed && self.isRightPressed && !self.isShuffling) {
        self.isLeftPressed = NO;
        self.isLeftPressed = NO;
        
        /* shuffle */
        self.isShuffling = YES;
        [self.manager diceModeSpinAll];
        self.isShuffling = NO;
    }
    
    self.isLeftPressed = NO;
    self.isLeftPressed = NO;
}

- (IBAction)shuffleLeft:(id)sender {
    self.isLeftPressed = YES;
}

- (IBAction)shuffleRight:(id)sender {
    self.isRightPressed = YES;
}

- (IBAction)increaseDice:(id)sender {
    int nextNum = (int)[self.diceObjects count] + 1;
    NSString * key = [NSString stringWithFormat:@"image%d",nextNum];
    Dice * d = [self.manager addDice:[self valueForKey:key]];
    [self.diceObjects addObject:d];
    
    if (nextNum >= self.maxNumber) [sender setEnabled:NO];
    else [sender setEnabled:YES];
    
    [self.downButton setEnabled:YES];
}

- (IBAction)decreaseDice:(id)sender {
    Dice * d = [self.diceObjects lastObject];
    [self.manager removeDice:d];
    [self.diceObjects removeLastObject];
    
    if ([self.diceObjects count] <= 1) [sender setEnabled:NO];
    else [sender setEnabled:YES];
    
    [self.upButton setEnabled:YES];
}

@end
