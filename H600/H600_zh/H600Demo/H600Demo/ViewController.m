//
//  ViewController.m
//  H600Demo
//
//  Created by Creative on 2021/1/8.
//

#import "ViewController.h"
#import "CRH600ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (IBAction)h600ButtonClicked:(UIButton *)sender {
    CRH600ViewController *vc = [[CRH600ViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

@end
