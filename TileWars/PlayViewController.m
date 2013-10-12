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
    whosTurn = true;
    start = true;
    count = 0;
    speedCount = 0;
    _playmode = @"OriginalRules";
    
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
    int y = [thisButton tag] % 10;
    int x = [thisButton tag] / 10;
    
    [self makePlayForRules:_buttonArray forX:x andY:y];
}

-(void) makePlayForRules: (NSMutableArray *) buttonArray forX: (int) x andY: (int) y {
    if([_playmode isEqualToString:@"SpeedTile"]) [self makePlayForRulesSpeedTile:buttonArray forX:x andY:y];
    else if([_playmode isEqualToString:@"OriginalRules"]) [self originalRules:buttonArray forX:x andY:y];
}

-(void) originalRules: (NSMutableArray *) buttonArray forX: (int) x andY: (int) y {
    UIButton *pushedButton = [[buttonArray objectAtIndex:x] objectAtIndex:y];
    if (![pushedButton.backgroundColor isEqual:[UIColor grayColor]])
        return;
    
    [UIView beginAnimations:@"Flip" context:NULL];
    [UIView setAnimationDuration:0.40];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromRight forView:pushedButton cache:NO];
    [UIView setAnimationDelegate:self];
    
    [UIView commitAnimations];
    
    pushedButton.backgroundColor = whosTurn ? [UIColor blueColor] : [UIColor redColor];
    
    for (int i = -1; i < 2; i++) {
        for (int j = -1; j < 2; j++) {
            int newX = x + i;
            int newY = y + j;
            
            if (newX >= 0 && newY >= 0 && newX < 6 && newY < 6) {
                UIButton *adjacentButton = [[buttonArray objectAtIndex:newX] objectAtIndex:newY];
                if (adjacentButton.backgroundColor != [UIColor grayColor] && adjacentButton.backgroundColor != pushedButton.backgroundColor) {
                    adjacentButton.backgroundColor = whosTurn ? [UIColor blueColor] : [UIColor redColor];
                    
                    [UIView beginAnimations:@"Flip" context:NULL];
                    [UIView setAnimationDuration:0.40];
                    [UIView setAnimationDelegate:self];
                    [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromRight forView:adjacentButton cache:NO];
                    [UIView setAnimationDelegate:self];
                    
                    [UIView commitAnimations];
                }
            }
        }
    }
    if (count == 0) {
        count++;
    } else {
        whosTurn = !whosTurn;
        count = 0;
    }
}

- (IBAction)reset:(id)sender {
    if ([_playmode isEqualToString:@"SpeedTile"]) [self resetSpeedTile];
}

- (IBAction)rulesButton:(id)sender {
    if ([_playmode isEqualToString:@"SpeedTile"]) [self rulesButtonSpeedTile];
}

#pragma mark SpeedTile methods

- (void) resetSpeedTile {
    if (start) {
        _theTimer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(randomFlip) userInfo:nil repeats:YES];
        start = false;
        [_startButton setTitle:@"Stop" forState:UIControlStateNormal];
    } else {
        if (_theTimer)
            [_theTimer invalidate];
        UIButton *thisButton;
        for (int i = 0; i < 6; i++) {
            for (int j = 0; j < 6; j++) {
                thisButton = [[_buttonArray objectAtIndex:i] objectAtIndex:j];
                [thisButton setBackgroundColor:[UIColor grayColor]];
            }
        }
        whosTurn = true;
        
        speedCount = 0;
        thisButton = [[_buttonArray objectAtIndex:0] objectAtIndex:0];
        [thisButton setTitle:@"" forState:UIControlStateNormal];
        thisButton = [[_buttonArray objectAtIndex:1] objectAtIndex:0];
        [thisButton setTitle:@"" forState:UIControlStateNormal];
        thisButton = [[_buttonArray objectAtIndex:2] objectAtIndex:0];
        [thisButton setTitle:@"" forState:UIControlStateNormal];
        thisButton = [[_buttonArray objectAtIndex:0] objectAtIndex:1];
        [thisButton setTitle:@"" forState:UIControlStateNormal];
        thisButton = [[_buttonArray objectAtIndex:1] objectAtIndex:1];
        [thisButton setTitle:@"" forState:UIControlStateNormal];
        thisButton = [[_buttonArray objectAtIndex:2] objectAtIndex:1];
        [thisButton setTitle:@"" forState:UIControlStateNormal];
        thisButton = [[_buttonArray objectAtIndex:3] objectAtIndex:1];
        [thisButton setTitle:@"" forState:UIControlStateNormal];
        start = true;
        [_startButton setTitle:@"Start" forState:UIControlStateNormal];
        
    }

}

-(void) makePlayForRulesSpeedTile:(NSMutableArray *)buttonArray forX:(int)x andY:(int)y {
    UIButton *pushedButton = [[buttonArray objectAtIndex:x] objectAtIndex:y];
    
    if (![pushedButton.backgroundColor isEqual:[UIColor redColor]])
        return;
    
    [UIView beginAnimations:@"Flip" context:NULL];
    [UIView setAnimationDuration:0.40];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromRight forView:pushedButton cache:NO];
    [UIView setAnimationDelegate:self];
    [UIView commitAnimations];
    
    pushedButton.backgroundColor = [UIColor grayColor];
    
    speedCount -= 1;
}

-(void) randomFlip {
    int randX = rand() % 6;
    int randY = rand() % 6;
    UIButton *pushedButton = [[_buttonArray objectAtIndex:randX] objectAtIndex:randY];
    
    if (![pushedButton.backgroundColor isEqual:[UIColor grayColor]])
        return;
    
    [UIView beginAnimations:@"Flip" context:NULL];
    [UIView setAnimationDuration:0.40];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromRight forView:pushedButton cache:NO];
    [UIView setAnimationDelegate:self];
    [UIView commitAnimations];
    
    pushedButton.backgroundColor = [UIColor redColor];
    
    speedCount += 1;
    if (speedCount == 2) {
        [_theTimer invalidate];
        NSLog(@"Invalidating!");
        _theTimer = [NSTimer scheduledTimerWithTimeInterval:0.4 target:self selector:@selector(randomFlip) userInfo:nil repeats:YES];
    }
    if (speedCount == 4) {
        [_theTimer invalidate];
        NSLog(@"Invalidating!");
        _theTimer = [NSTimer scheduledTimerWithTimeInterval:0.3 target:self selector:@selector(randomFlip) userInfo:nil repeats:YES];
    }
    if (speedCount == 5) {
        [_theTimer invalidate];
        NSLog(@"Invalidating!");
        _theTimer = [NSTimer scheduledTimerWithTimeInterval:0.2 target:self selector:@selector(randomFlip) userInfo:nil repeats:YES];
    }
    if (speedCount == 10) {
        [_theTimer invalidate];
        NSLog(@"Invalidating!");
        _theTimer = [NSTimer scheduledTimerWithTimeInterval:0.05 target:self selector:@selector(randomFlip) userInfo:nil repeats:YES];
    }
    if (speedCount == 36) {
        [_theTimer invalidate];
        UIButton * thisButton = [[_buttonArray objectAtIndex:0] objectAtIndex:0];
        thisButton.backgroundColor = [UIColor greenColor];
        [thisButton setTitle:@"Y" forState:UIControlStateNormal];
        thisButton = [[_buttonArray objectAtIndex:1] objectAtIndex:0];
        thisButton.backgroundColor = [UIColor greenColor];
        [thisButton setTitle:@"O" forState:UIControlStateNormal];
        thisButton = [[_buttonArray objectAtIndex:2] objectAtIndex:0];
        thisButton.backgroundColor = [UIColor greenColor];
        [thisButton setTitle:@"U" forState:UIControlStateNormal];
        thisButton = [[_buttonArray objectAtIndex:0] objectAtIndex:1];
        thisButton.backgroundColor = [UIColor greenColor];
        [thisButton setTitle:@"L" forState:UIControlStateNormal];
        thisButton = [[_buttonArray objectAtIndex:1] objectAtIndex:1];
        thisButton.backgroundColor = [UIColor greenColor];
        [thisButton setTitle:@"O" forState:UIControlStateNormal];
        thisButton = [[_buttonArray objectAtIndex:2] objectAtIndex:1];
        thisButton.backgroundColor = [UIColor greenColor];
        [thisButton setTitle:@"S" forState:UIControlStateNormal];
        thisButton = [[_buttonArray objectAtIndex:3] objectAtIndex:1];
        thisButton.backgroundColor = [UIColor greenColor];
        [thisButton setTitle:@"E" forState:UIControlStateNormal];
    }
    
}

- (void) rulesButtonSpeedTile {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Speed Tile Rules"
                                                    message:@"Play against the computer who is flipping tiles faster and faster"
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
}
@end
