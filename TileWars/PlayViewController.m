//
//  PlayViewController.m
//  TileWars
//
//  Created by Tyler McAtee on 10/11/13.
//  Copyright (c) 2013 Tyler McAtee. All rights reserved.
//

#import "math.h"
#import "PlayViewController.h"
#import "AppDelegate.h"

@interface PlayViewController ()

@end

struct tileCoordinate {
    int x;
    int y;
};

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
    _infoLabel.text = @"";
    _topInfoLabel.text = @"";
    player = true;
    
    _blueMoves = [[NSMutableArray alloc] initWithObjects: nil];
    _yellowMoves = [[NSMutableArray alloc] initWithObjects: nil];
    _chainStack = [[NSMutableArray alloc] initWithObjects: nil];
    
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    _lastPlaymode = delegate.playmode;
    for (int i = 15; i < 300; i += 50) {
        NSMutableArray *columnArray = [[NSMutableArray alloc] init];
        column = 0;
        for (int j = 90; j < 390; j += 50) {
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

-(void) reloadScreen {
    _infoLabel.text = @"";
    _topInfoLabel.text = @"";
    UIButton *thisButton;
    for (int i = 0; i < 6; i++) {
        for (int j = 0; j < 6; j++) {
            thisButton = [[_buttonArray objectAtIndex:i] objectAtIndex:j];
            [thisButton setBackgroundColor:[UIColor grayColor]];
        }
    }
    
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

- (void) viewDidAppear:(BOOL)animated {
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    if (![_lastPlaymode isEqualToString:delegate.playmode]) {
        [self reloadScreen];
        _lastPlaymode = delegate.playmode;
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
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSString *playmode = delegate.playmode;
    if([playmode isEqualToString:@"SpeedTile"]) [self makePlayForRulesSpeedTile:buttonArray forX:x andY:y];
    else if([playmode isEqualToString:@"OriginalRules"]) [self originalRules:buttonArray forX:x andY:y];
    else if([playmode isEqualToString:@"ChainTile"]) [self makePlayForRulesChainTile:buttonArray forX:x andY:y];
}

- (IBAction)reset:(id)sender {
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSString *playmode = delegate.playmode;
    if ([playmode isEqualToString:@"SpeedTile"]) [self resetSpeedTile];
}

- (IBAction)rulesButton:(id)sender {
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSString *playmode = delegate.playmode;
    if ([playmode isEqualToString:@"SpeedTile"]) [self rulesButtonSpeedTile];
}

#pragma mark SpeedTile methods

- (void) resetSpeedTile {
    if (start) {
        _theTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(randomFlip) userInfo:nil repeats:YES];
        _infoLabel.text = @"0:00:00";
        _theClockTimer = [NSTimer scheduledTimerWithTimeInterval:.01 target:self selector:@selector(incrementTimer) userInfo:Nil repeats:YES];
        start = false;
        [_startButton setTitle:@"Stop" forState:UIControlStateNormal];
    } else {
        if (_theTimer)
            [_theTimer invalidate];
        if (_theClockTimer) {
            [_theClockTimer invalidate];
            _infoLabel.text = @"";
        }
        UIButton *thisButton;
        for (int i = 0; i < 6; i++) {
            for (int j = 0; j < 6; j++) {
                thisButton = [[_buttonArray objectAtIndex:i] objectAtIndex:j];
                [thisButton setBackgroundColor:[UIColor grayColor]];
            }
        }
        
        speedCount = 0;
        timerCount = 0;
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
    
    timerCount += 1;
    
    int randX = rand() % 6;
    int randY = rand() % 6;
    UIButton *pushedButton = [[_buttonArray objectAtIndex:randX] objectAtIndex:randY];
        
    while ([pushedButton.backgroundColor isEqual:[UIColor redColor]]) {
        randX = rand() % 6;
        randY = rand() % 6;
        pushedButton = [[_buttonArray objectAtIndex:randX] objectAtIndex:randY];
    }
    [UIView beginAnimations:@"Flip" context:NULL];
    [UIView setAnimationDuration:0.40];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromRight forView:pushedButton cache:NO];
    [UIView setAnimationDelegate:self];
    [UIView commitAnimations];
    pushedButton.backgroundColor = [UIColor redColor];
    speedCount += 1;
    
    [_theTimer invalidate];
    float delay = 1/(pow((float)timerCount, 0.3));
    _theTimer = [NSTimer scheduledTimerWithTimeInterval: delay target:self selector:@selector(randomFlip) userInfo:nil repeats:YES];
    
    if (speedCount == 10) {
        [_theClockTimer invalidate];
        [_theTimer invalidate];
        _theTimer = [NSTimer scheduledTimerWithTimeInterval:0.6 target:self selector:@selector(youLose) userInfo:nil repeats:NO];
    }
    
}

-(void) youLose {
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
    
    if ([_topInfoLabel.text isEqualToString:@""]) {
        _topInfoLabel.text = _infoLabel.text;
    } else if ([self timeToInt:_infoLabel] > [self timeToInt:_topInfoLabel]) {
        _topInfoLabel.text = _infoLabel.text;
    }
}

- (void) rulesButtonSpeedTile {
    if (start) {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Speed Tile Rules"
                                                    message:@"Play against the computer who is flipping tiles faster and faster"
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
    }
}

-(void) incrementTimer {
    NSString *theText = _infoLabel.text;
    NSArray *theNums = [theText componentsSeparatedByString:@":"];
    NSInteger minute = [[theNums objectAtIndex:0] intValue];
    NSInteger second = [[theNums objectAtIndex:1] intValue];
    NSInteger milisecond = [[theNums objectAtIndex:2] intValue];
    milisecond += 1;
    if (milisecond == 60) {
        milisecond = 0;
        second += 1;
    }
    if (second == 60) {
        second = 0;
        minute += 1;
    }
    
    NSString *minutes = [NSString stringWithFormat:@"%d:", minute];
    NSString *seconds = (second < 10) ? [NSString stringWithFormat:@"0%d:", second] : [NSString stringWithFormat:@"%d:", second];
    NSString *miliseconds = (milisecond < 10) ? [NSString stringWithFormat:@"0%d", milisecond] : [NSString stringWithFormat:@"%d", milisecond];
    
    _infoLabel.text = [NSString stringWithFormat:@"%@%@%@", minutes, seconds, miliseconds];
}

-(NSInteger *) timeToInt : (UILabel *) labelUnderExamination{
    NSString *theText = labelUnderExamination.text;
    NSArray *theNums = [theText componentsSeparatedByString:@":"];
    NSInteger minute = [[theNums objectAtIndex:0] intValue];
    NSInteger second = [[theNums objectAtIndex:1] intValue];
    NSInteger milisecond = [[theNums objectAtIndex:2] intValue];
    
    return (NSInteger *)(minute * 10000 + second* 100 + milisecond);
}

#pragma mark OriginalRules methods

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

#pragma mark ChainTile methods

- (void) makePlayForRulesChainTile: (NSMutableArray *) buttonArray forX: (int) x andY: (int) y {
    UIButton *pushedButton = [[_buttonArray objectAtIndex:x] objectAtIndex:y];
    if (![pushedButton.backgroundColor isEqual:[UIColor grayColor]])
        return;
    NSMutableArray *moves;
    if (player) {
        struct tileCoordinate t;
        t.x = x;
        t.y = y;
        [_blueMoves addObject: [NSValue value:&t withObjCType:@encode(struct tileCoordinate)]];
        moves = _blueMoves;
    } else {
        struct tileCoordinate t;
        t.x = x;
        t.y = y;
        [_yellowMoves addObject: [NSValue value:&t withObjCType:@encode(struct tileCoordinate)]];
        moves = _yellowMoves;
    }
    
    [UIView beginAnimations:@"Flip" context:NULL];
    [UIView setAnimationDuration:0.40];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromRight forView:pushedButton cache:NO];
    [UIView setAnimationDelegate:self];
    [UIView commitAnimations];
    pushedButton.backgroundColor = player ? [UIColor blueColor] : [UIColor yellowColor];
    
    [self flipNeighbors:x andY:y andWho:player];
    BOOL flipper = !player;
    float timeStop = 0.5;
    for (int i = moves.count - 2; i >= 0; i-=1) {
        struct tileCoordinate theTileCoordinate;
        [[globalMoves objectAtIndex:i] getValue:&theTileCoordinate];
        [_chainStack addObject: [NSNumber numberWithInt:i]];
        [_chainStack addObject: [NSNumber numberWithInt:x]];
        [_chainStack addObject: [NSNumber numberWithInt:y]];
        [_chainStack addObject: [NSNumber numberWithInt: theTileCoordinate.x]];
        [_chainStack addObject: [NSNumber numberWithInt: theTileCoordinate.y]];
        [_chainStack addObject: moves];
        [_chainStack addObject: [NSNumber numberWithInt: (int) flipper]];
        [NSTimer scheduledTimerWithTimeInterval:timeStop target:self selector:@selector(flipBack) userInfo:nil repeats:NO];
        flipper = !flipper;
        timeStop += 0.5;
    }
    
    player = !player;
}

-(void) flipBack {
    
    int theI = [[_chainStack objectAtIndex:0] integerValue];
    [_chainStack removeObjectAtIndex:0];
    int oldX = [[_chainStack objectAtIndex:0] integerValue];
    [_chainStack removeObjectAtIndex:0];
    int oldY = [[_chainStack objectAtIndex:0] integerValue];
    [_chainStack removeObjectAtIndex:0];
    int newX = [[_chainStack objectAtIndex:0] integerValue];
    [_chainStack removeObjectAtIndex:0];
    int newY = [[_chainStack objectAtIndex:0] integerValue];
    [_chainStack removeObjectAtIndex:0];
    NSMutableArray *theMoves = [_chainStack objectAtIndex:0];
    [_chainStack removeObjectAtIndex:0];
    bool theFlipper = (bool) [[_chainStack objectAtIndex:0] integerValue];
    [_chainStack removeObjectAtIndex:0];
    
    struct tileCoordinate theTileCoordinate;
    [[theMoves objectAtIndex:theI] getValue:&theTileCoordinate];
    
    UIButton *buttonA = [[_buttonArray objectAtIndex:oldX] objectAtIndex:oldY];
    CGRect frameA = buttonA.frame;
    UIButton *buttonB = [[_buttonArray objectAtIndex:newX] objectAtIndex:newY];
    CGRect frameB = buttonB.frame;
    
    [[_buttonArray objectAtIndex:oldX] replaceObjectAtIndex:oldY withObject:buttonB];
    [[_buttonArray objectAtIndex:newX] replaceObjectAtIndex:newY withObject:buttonA];
    
    [UIView animateWithDuration:0.5 animations:^{
        buttonA.frame = frameB;
        buttonB.frame = frameA;
    }];
    [self flipNeighbors:newX andY:newY andWho:theFlipper];

}

-(void) flipNeighbors: (int) x andY: (int) y andWho: (BOOL) whoToFlip {
    UIButton *pushedButton = [[_buttonArray objectAtIndex:x] objectAtIndex:y];
    for (int i = -1; i < 2; i++) {
        for (int j = -1; j < 2; j++) {
            int newX = x + i;
            int newY = y + j;
        
            if (newX >= 0 && newY >= 0 && newX < 6 && newY < 6) {
                UIButton *adjacentButton = [[_buttonArray objectAtIndex:newX] objectAtIndex:newY];
                if (adjacentButton.backgroundColor != [UIColor grayColor] && adjacentButton.backgroundColor != pushedButton.backgroundColor) {
                    adjacentButton.backgroundColor = whoToFlip ? [UIColor blueColor] : [UIColor yellowColor];
                
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
}


@end
