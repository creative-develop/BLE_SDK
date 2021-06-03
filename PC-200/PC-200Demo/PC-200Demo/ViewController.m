//
//  ViewController.m
//  PC-200Demo
//
//  Created by Creative on 2020/12/31.
//

#import "ViewController.h"
#import "CRPC200ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
}

- (IBAction)pc200ButtonClicked:(UIButton *)sender {
    CRPC200ViewController *vc = [[CRPC200ViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

@end
