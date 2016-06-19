//
//  RankVC.m
//  Tanzan
//
//  Created by williamzhang on 6/15/16.
//  Copyright © 2016 William-Trademarks. All rights reserved.
//

#import "RankVC.h"
#import "RankView.h"
#import "Ranker.h"

@interface RankVC ()
@property (nonatomic) CGFloat xShift;
@property (nonatomic) RankView * rankD;
@end

@implementation RankVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.rankView setHidden:YES];
}

- (void)viewWillAppear:(BOOL)animated {
    RankView * v = (RankView*)[[NSBundle mainBundle] loadNibNamed:@"RankingView" owner:nil options:nil][0];
    CGFloat scale = self.view.frame.size.width/v.frame.size.width;
    v.transform = CGAffineTransformMakeScale(scale, 1);
    [self.view addSubview:v];
    [v setCenter:self.view.center];
    
    self.rankD = v;
    
    Ranker * ranker = [Ranker new];
    NSArray * scores = [ranker ranks];
    for (int i = 0; i < [scores count]; i++) {
        NSString * sKey = [NSString stringWithFormat:@"score%d",i+1];
        NSString * dKey = [NSString stringWithFormat:@"date%d",i+1];
        
        UILabel * score = [v valueForKey:sKey];
        UILabel * date = [v valueForKey:dKey];
        Rank * r = scores[i];
        score.text = [NSString stringWithFormat:@"%d",[r score]];
        date.text = [r formattedDate];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)back:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
