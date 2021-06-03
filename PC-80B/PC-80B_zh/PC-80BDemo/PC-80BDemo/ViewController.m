//
//  ViewController.m
//  PC-80BDemo
//
//  Created by Creative on 2021/1/6.
//

#import "ViewController.h"
#import "CRPC80BViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (IBAction)pc80bButtonClicked:(UIButton *)sender {
    CRPC80BViewController *vc = [[CRPC80BViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

@end
