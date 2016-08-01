//
//  MSVC.m
//  Tanzan
//
//  Created by williamzhang on 6/15/16.
//  Copyright © 2016 William-Trademarks. All rights reserved.
//

#import "MSVC.h"
#import <AVFoundation/AVFoundation.h>

@interface MSVC ()
@property (nonatomic, strong) AVAudioPlayer * backgroundPlayer;
@property (nonatomic, strong) IAPurchaser * iaPurchaser;
@end

@implementation MSVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    NSURL * url = [[NSBundle mainBundle] URLForResource:@"SSMusic" withExtension:@"mp3"];
    NSError * error;
    self.backgroundPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
    [self.backgroundPlayer setNumberOfLoops:-1];
    [self.backgroundPlayer prepareToPlay];
    
    self.iaPurchaser = [[IAPurchaser alloc] init];
    [self.iaPurchaser setDelegate:self];
    
    NSUserDefaults * d = [NSUserDefaults standardUserDefaults];
    
    //!!! warning - faulty pro setting
//    [d setBool:YES forKey:@"Diecaster.ProV"];
//    [d synchronize];
    
    if ([d boolForKey:@"Diecaster.ProV"]) {
        [self setupProUI];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [self.backgroundPlayer play];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - IAPurchaser

- (void)productReceived:(NSArray *)products {
    if ([products count] != 1) [self productPurchaseFailed];
    else {
        SKProduct * product = products[0];
        NSString * t = [product localizedTitle];
        
        NSNumberFormatter * formatter = [[NSNumberFormatter alloc] init];
        [formatter setNumberStyle:NSNumberFormatterCurrencyStyle];
        [formatter setLocale:[product priceLocale]];
        NSString * cost = [formatter stringFromNumber:[product price]];
        
        NSString * desc = [NSString stringWithFormat:@"%@ %@",[product localizedDescription],cost];
        UIAlertController * ac = [UIAlertController alertControllerWithTitle:t
                                                                     message:desc preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction * c = [UIAlertAction actionWithTitle:NSLocalizedString(@"DISMISS", nil) style:UIAlertActionStyleCancel
                                                   handler:^(UIAlertAction * _Nonnull action) {
                                                       [self statusOnAllButtons:YES];
                                                   }];
        
        UIAlertAction * p = [UIAlertAction actionWithTitle:NSLocalizedString(@"PURCHASEALERT", nil) style:UIAlertActionStyleDefault
                                                   handler:^(UIAlertAction * _Nonnull action) {
                                                       [self.iaPurchaser buyProduct:product];
                                                   }];
        
        [ac addAction:c];
        [ac addAction:p];
        [self presentViewController:ac animated:YES completion:nil];
    }
}

- (void)productPurchaseCancelled {
    [self statusOnAllButtons:YES];
}

- (void)productPurchaseFailed {
    //TODO: display product purchase failed notification
    [self statusOnAllButtons:YES];
}

- (void)productPurchased {
    [self setupProUI];
    [self statusOnAllButtons:YES];
}

- (void)statusOnAllButtons:(BOOL)status {
    [self.startButton setEnabled:status];
    [self.practiceButton setEnabled:status];
    [self.rankingButton setEnabled:status];
    [self.instructionButton setEnabled:status];
    [self.upgradeButton setEnabled:status];
    [self.restoreButton setEnabled:status];
}

- (void)setupProUI {
    NSString * path = [[NSBundle mainBundle] pathForResource:@"TanzanProi5" ofType:@"png"];
    NSData * dat = [[NSData alloc] initWithContentsOfFile:path];
    self.bgImageView.image = [UIImage imageWithData:dat];
    
    [self.restoreButton setHidden:YES];
    [self.upgradeButton setHidden:YES];
}

#pragma mark - Actions

- (IBAction)start:(id)sender {
    [self.backgroundPlayer pause];
    UIStoryboard * s = [UIStoryboard storyboardWithName:@"MainS" bundle:nil];
    UIViewController * vc = [s instantiateViewControllerWithIdentifier:@"MGVC"];
    [self presentViewController:vc animated:YES completion:nil];
}

- (IBAction)practice:(id)sender {
    [self.backgroundPlayer pause];
    UIStoryboard * s = [UIStoryboard storyboardWithName:@"MainS" bundle:nil];
    UIViewController * vc = [s instantiateViewControllerWithIdentifier:@"PSVC"];
    [self presentViewController:vc animated:YES completion:nil];
}

- (IBAction)ranking:(id)sender {
    [self.backgroundPlayer pause];
    UIStoryboard * s = [UIStoryboard storyboardWithName:@"MainS" bundle:nil];
    UIViewController * vc = [s instantiateViewControllerWithIdentifier:@"RankVC"];
    [self presentViewController:vc animated:YES completion:nil];
}

- (IBAction)instruction:(id)sender {
    [self.backgroundPlayer pause];
    UIStoryboard * s = [UIStoryboard storyboardWithName:@"MainS" bundle:nil];
    UIViewController * vc = [s instantiateViewControllerWithIdentifier:@"IVC"];
    [self presentViewController:vc animated:YES completion:nil];
}

- (IBAction)upgrade:(id)sender {
    [self statusOnAllButtons:NO];
    [self.iaPurchaser requestProductInformation];
}

- (IBAction)restore:(id)sender {
    [self statusOnAllButtons:NO];
    [self.iaPurchaser restorePurchases];
}

- (IBAction)hiddenMode:(UIGestureRecognizer *)sender {
    if ([sender state] == UIGestureRecognizerStateBegan) {
        [self.backgroundPlayer pause];
        UIStoryboard * s = [UIStoryboard storyboardWithName:@"MainS" bundle:nil];
        UIViewController * vc = [s instantiateViewControllerWithIdentifier:@"DMVC"];
        [self presentViewController:vc animated:YES completion:nil];
    }
}

@end
