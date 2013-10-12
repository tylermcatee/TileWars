//
//  RulesViewController.m
//  TileWars
//
//  Created by Tyler McAtee on 10/11/13.
//  Copyright (c) 2013 Tyler McAtee. All rights reserved.
//

#import "RulesViewController.h"

@interface RulesViewController ()

@end

@implementation RulesViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	_buttonArray = [[NSMutableArray alloc] init];
    int row = 0;
    
    UIButton *button = [self makeButton];
    CGRect newFrame = button.frame;
    newFrame.origin.x = (CGFloat) 115;
    newFrame.origin.y = 200;
    button.frame = newFrame;
    button.tag = 0;
    button.backgroundColor = [UIColor redColor];
    [self.view addSubview:button];
    [_buttonArray addObject:button];
    
    button = [self makeButton];
    newFrame = button.frame;
    newFrame.origin.x = (CGFloat) 165;
    newFrame.origin.y = 200;
    button.frame = newFrame;
    button.tag = 1;
    button.backgroundColor = [UIColor greenColor];
    [self.view addSubview:button];
    [_buttonArray addObject:button];
    
    button = [self makeButton];
    newFrame = button.frame;
    newFrame.origin.x = (CGFloat) 115;
    newFrame.origin.y = 250;
    button.frame = newFrame;
    button.tag = 2;
    button.backgroundColor = [UIColor blueColor];
    [self.view addSubview:button];
    [_buttonArray addObject:button];
    
    button = [self makeButton];
    newFrame = button.frame;
    newFrame.origin.x = (CGFloat) 165;
    newFrame.origin.y = 250;
    button.frame = newFrame;
    button.tag = 3;
    button.backgroundColor = [UIColor yellowColor];
    [self.view addSubview:button];
    [_buttonArray addObject:button];

}

-(UIButton *) makeButton
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    button.backgroundColor = [UIColor grayColor];
    [button addTarget:self
               action:@selector(selectedTile:)
     forControlEvents:UIControlEventTouchDown];
    button.frame = CGRectMake(80.0, 210.0, 40.0, 40.0);
    return button;
}

-(IBAction)selectedTile:(id)sender {
    UIButton *thisButton = (UIButton *) sender;
    int index = [thisButton tag];
    
    [UIView animateWithDuration:0.5 animations:^{
        
        if (index == 0) {
            UIButton *button1 = _buttonArray[1];
            UIButton *button2 = _buttonArray[2];
            UIButton *button3 = _buttonArray[3];
            button1.frame = CGRectMake(215, 250, 40.0, 40.0);
            button2.frame = CGRectMake(165, 300, 40.0, 40.0);
            button3.frame = CGRectMake(215, 300, 40.0, 40.0);
        } else if (index == 1) {
            UIButton *button0 = _buttonArray[0];
            UIButton *button2 = _buttonArray[2];
            UIButton *button3 = _buttonArray[3];
            button0.frame = CGRectMake(65.0, 250.0, 40.0, 40.0);
            button2.frame = CGRectMake(65.0, 300, 40.0, 40.0);
            button3.frame = CGRectMake(115.0, 300, 40.0, 40.0);
        } else if (index == 2) {
            UIButton *button0 = _buttonArray[0];
            UIButton *button1 = _buttonArray[1];
            UIButton *button3 = _buttonArray[3];
            button0.frame = CGRectMake(165.0, 150.0, 40.0, 40.0);
            button1.frame = CGRectMake(215.0, 150.0, 40.0, 40.0);
            button3.frame = CGRectMake(215.0, 200.0, 40.0, 40.0);
        } else if (index == 3) {
            UIButton *button0 = _buttonArray[0];
            UIButton *button1 = _buttonArray[1];
            UIButton *button2 = _buttonArray[2];
            button0.frame = CGRectMake(65.0, 150.0, 40.0, 40.0);
            button1.frame = CGRectMake(115.0, 150.0, 40.0, 40.0);
            button2.frame = CGRectMake(65.0, 200.0, 40.0, 40.0);
        }
        thisButton.frame = CGRectMake(115, 200, 90, 90);

        
    }];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
