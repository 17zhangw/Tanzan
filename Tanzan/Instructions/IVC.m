//
//  IVC.m
//  Tanzan
//
//  Created by williamzhang on 6/16/16.
//  Copyright © 2016 William-Trademarks. All rights reserved.
//

#import "IVC.h"
#import "IView.h"

@interface IVC ()

@end

@implementation IVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    NSString * locale = [[NSLocale preferredLanguages] objectAtIndex:0];
    IView * v;
    if ([locale isEqualToString:@"en-US"]) {
        v = (IView*)[[NSBundle mainBundle] loadNibNamed:@"InstructView" owner:self options:nil][0];
    } else if ([locale isEqualToString:@"ja-JP"]) {
        v = (IView*)[[NSBundle mainBundle] loadNibNamed:@"InstructView2" owner:self options:nil][0];
    }
    
    CGFloat x = self.view.frame.size.width / v.frame.size.width;
    v.transform = CGAffineTransformMakeScale(x, 1);
    v.center = CGPointMake(self.view.center.x, v.center.y);
    
    [self.scrollView setContentSize:CGSizeMake(v.frame.size.width, v.frame.size.height)];
    [self.scrollView addSubview:v];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)back:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
