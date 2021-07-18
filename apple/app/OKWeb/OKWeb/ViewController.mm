//
//  ViewController.m
//  OKWeb
//
//  Created by cort xu on 2021/7/17.
//

#import "ViewController.h"
#import "WebViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  // Do any additional setup after loading the view.
  self.title = @"主页";
  
  UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(onRightClick)];
  self.navigationItem.rightBarButtonItem = rightItem;
  
  WebViewController* vc = [[WebViewController alloc] init];
  [self.navigationController pushViewController:vc animated:YES];
}

- (void)onRightClick {
  NSLog(@"onRightClick");
}


@end
