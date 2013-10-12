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
    newFrame.origin.x = (CGFloat) 95;
    newFrame.origin.y = 200;
    button.frame = newFrame;
    button.tag = 1000 + row;
    [self.view addSubview:button];
    [_buttonArray addObject:button];
    
    button = [self makeButton];
    newFrame = button.frame;
    newFrame.origin.x = (CGFloat) 145;
    newFrame.origin.y = 200;
    button.frame = newFrame;
    button.tag = 1000 + row;
    [self.view addSubview:button];
    [_buttonArray addObject:button];
    
    button = [self makeButton];
    newFrame = button.frame;
    newFrame.origin.x = (CGFloat) 95;
    newFrame.origin.y = 250;
    button.frame = newFrame;
    button.tag = 1000 + row;
    [self.view addSubview:button];
    [_buttonArray addObject:button];
    
    button = [self makeButton];
    newFrame = button.frame;
    newFrame.origin.x = (CGFloat) 145;
    newFrame.origin.y = 250;
    button.frame = newFrame;
    button.tag = 1000 + row;
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
    int x;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
