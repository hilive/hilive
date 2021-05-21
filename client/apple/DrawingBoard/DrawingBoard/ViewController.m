//
//  ViewController.m
//  DrawingBoard
//
//  Created by cort xu on 2021/5/7.
//

#import "ViewController.h"
#import "PaintView.h"

@interface ViewController ()
@property (nonatomic, strong) PaintView* paintView;
@end

@implementation ViewController

- (void)dealloc {

}

- (void)viewDidLoad {
  [super viewDidLoad];

  CGFloat viewBottomSize = 50;

  self.paintView = [[PaintView alloc] init];
  self.paintView.backgroundColor = [UIColor redColor];
  self.paintView.frame = CGRectMake(0, viewBottomSize, self.view.bounds.size.width, self.view.bounds.size.height - viewBottomSize * 2);
  [self.view addSubview:self.paintView];
}

@end
