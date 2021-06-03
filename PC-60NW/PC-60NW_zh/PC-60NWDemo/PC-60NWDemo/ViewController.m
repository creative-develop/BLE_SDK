//
//  ViewController.m
//  PC-60NWDemo
//
//  Created by Creative on 2021/1/11.
//

#import "ViewController.h"
#import "PC60NWViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (IBAction)pc60nwButtonClicked:(UIButton *)sender {
    PC60NWViewController *vc = [[PC60NWViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

@end
