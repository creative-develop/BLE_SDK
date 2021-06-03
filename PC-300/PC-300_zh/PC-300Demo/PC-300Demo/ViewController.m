//
//  ViewController.m
//  PC-300Demo
//
//  Created by Creative on 2020/12/28.
//

#import "ViewController.h"
#import "PC300ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (IBAction)pc300ButtonClicked:(UIButton *)sender {
    PC300ViewController *vc = [[PC300ViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

@end
