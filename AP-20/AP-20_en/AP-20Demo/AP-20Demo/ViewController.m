//
//  ViewController.m
//  AP-20Demo
//
//  Created by Creative on 2020/12/23.
//

#import "ViewController.h"
#import "AP20ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (IBAction)ap20ButtonClicked:(UIButton *)sender {
    AP20ViewController *vc = [[AP20ViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

@end
