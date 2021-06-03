//
//  ViewController.m
//  PC_100Demo
//
//  Created by Creative on 2021/1/5.
//

#import "ViewController.h"
#import "CRPC100ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (IBAction)pc200ButtonClicked:(UIButton *)sender {
    CRPC100ViewController *vc = [[CRPC100ViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

@end
