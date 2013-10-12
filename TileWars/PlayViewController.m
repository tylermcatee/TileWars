//
//  PlayViewController.m
//  TileWars
//
//  Created by Tyler McAtee on 10/11/13.
//  Copyright (c) 2013 Tyler McAtee. All rights reserved.
//

#import "PlayViewController.h"

@interface PlayViewController ()

@end

@implementation PlayViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    _buttonArray = [[NSMutableArray alloc] init];
    int row = 0;
    int column;
    
    for (int i = 15; i < 300; i += 50) {
        NSMutableArray *columnArray = [[NSMutableArray alloc] init];
        column = 0;
        for (int j = 70; j < 370; j += 50) {
            UIButton *button = [self makeButton];
            CGRect newFrame = button.frame;
            newFrame.origin.x = (CGFloat) i;
            newFrame.origin.y = (CGFloat) j;
            button.frame = newFrame;
            button.tag = row*10 + column;
            [columnArray addObject:button];
            [self.view addSubview:button];
            column += 1;
        }
        [_buttonArray addObject:columnArray];
        row += 1;
    }
    
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction) selectedTile: (id) sender {
    UIButton *thisButton = (UIButton *) sender;
    if (thisButton.backgroundColor == [UIColor blueColor]){
        thisButton.backgroundColor = [UIColor redColor];
    } else {
        thisButton.backgroundColor = [UIColor blueColor];
    }
    int j = [thisButton tag] % 10;
    int i = [thisButton tag]/10;
    NSLog(@"%d, %d", i, j);
    
    UIButton *nextButton = [[_buttonArray objectAtIndex:i + 1] objectAtIndex:j + 1];
    nextButton.backgroundColor = [UIColor greenColor];
}
@end
