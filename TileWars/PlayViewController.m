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
    
    whosTurn = true;
    start = true;
    count = 0;
    speedCount = 0;
    _infoLabel.text = @"";
    _topInfoLabel.text = @"";
    player = true;
    
    //Data Structures for ChainTile
    _blueMoves = [[NSMutableArray alloc] initWithObjects: nil];
    _yellowMoves = [[NSMutableArray alloc] initWithObjects: nil];
    _chainStack = [[NSMutableArray alloc] initWithObjects: nil];
    
    
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    _lastPlaymode = delegate.playmode; //Will initialize to FastTile
    
    _buttonArray = [[NSMutableArray alloc] init];
    int row = 0;
    int column;
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
    
    //Make every button grayColor
    UIButton *thisButton;
    for (int i = 0; i < 6; i++) {
        for (int j = 0; j < 6; j++) {
            thisButton = [[_buttonArray objectAtIndex:i] objectAtIndex:j];
            [thisButton setTitle:@"" forState:UIControlStateNormal];
            [thisButton setBackgroundColor:[UIColor grayColor]];
        }
    }
    
    start = true;
    if ([_lastPlaymode isEqualToString:@"SpeedTile"]) [self initSpeedTile];
    else if ([_lastPlaymode isEqualToString:@"OriginalRules"]) [self initOriginalRules];
    else if ([_lastPlaymode isEqualToString:@"ChainTile"]) [self initChainTile];
}

-(void) initSpeedTile {
    _startButton.alpha = 1.0;
    [_startButton setTitle:@"Start" forState:UIControlStateNormal];
}
-(void) initOriginalRules {
    _startButton.alpha = 0.0;
}
-(void) initChainTile {
    _startButton.alpha = 0.0;
}

- (void) viewDidAppear:(BOOL)animated {
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    if (![_lastPlaymode isEqualToString:delegate.playmode]) {
        _lastPlaymode = delegate.playmode;
        [self reloadScreen];
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
                [thisButton setTitle:@"" forState:UIControlStateNormal];
                [thisButton setBackgroundColor:[UIColor grayColor]];
            }
        }
        
        speedCount = 0;
        timerCount = 0;
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
    [UIView commitAnimations];
    pushedButton.backgroundColor = player ? [UIColor blueColor] : [UIColor yellowColor];
    
    [self flipNeighbors:x andY:y andWho:player];
    globalFlipper = !player;
    float timeStop = 0.8;
    for (int i = moves.count - 1; i > 0; i-=1) {
        struct tileCoordinate theTileCoordinate;
        [[moves objectAtIndex:i] getValue:&theTileCoordinate];
        struct tileCoordinate theOldCoordinate;
        [[moves objectAtIndex:i - 1] getValue:&theOldCoordinate];
        
        
        [_chainStack addObject: [NSNumber numberWithInt:theTileCoordinate.x]];
        [_chainStack addObject: [NSNumber numberWithInt:theTileCoordinate.y]];
        [_chainStack addObject: [NSNumber numberWithInt:theOldCoordinate.x]];
        [_chainStack addObject: [NSNumber numberWithInt:theOldCoordinate.y]];
        
        [NSTimer scheduledTimerWithTimeInterval:timeStop target:self selector:@selector(chainAnimation) userInfo:nil repeats:NO];
        timeStop += 0.8;
    }
    
    player = !player;
}

-(void) chainAnimation {
    
    int xOld = [[_chainStack objectAtIndex:0] integerValue];
    [_chainStack removeObjectAtIndex:0];
    int yOld = [[_chainStack objectAtIndex:0] integerValue];
    [_chainStack removeObjectAtIndex:0];
    int xNew = [[_chainStack objectAtIndex:0] integerValue];
    [_chainStack removeObjectAtIndex:0];
    int yNew = [[_chainStack objectAtIndex:0] integerValue];
    [_chainStack removeObjectAtIndex:0];
    
    NSLog(@"Swapping: (%d, %d) <--> (%d, %d)", xOld, yOld, xNew, yNew);
    
    UIButton* buttonA = [[_buttonArray objectAtIndex:xOld] objectAtIndex:yOld];
    UIButton* buttonB = [[_buttonArray objectAtIndex:xNew] objectAtIndex:yNew];
    int Atag = [buttonA tag];
    int Btag = [buttonB tag];
    buttonA.tag = Btag;
    buttonB.tag = Atag;
    
    
    [[_buttonArray objectAtIndex:xOld] replaceObjectAtIndex:yOld withObject:buttonB];
    [[_buttonArray objectAtIndex:xNew] replaceObjectAtIndex:yNew withObject:buttonA];
    
    
    CGRect frameA = buttonA.frame;
    CGRect frameB = buttonB.frame;
    [UIView animateWithDuration:0.5 animations:^{
        buttonA.frame = frameB;
        buttonB.frame = frameA;
    }];
    [self flipNeighbors:xNew andY:yNew andWho:globalFlipper];
    globalFlipper = !globalFlipper;
}

-(void) flipNeighbors: (int) x andY: (int) y andWho: (BOOL) whoToFlip {
    for (int i = -1; i < 2; i++) {
        for (int j = -1; j < 2; j++) {
            int newX = x + i;
            int newY = y + j;
        
            if (newX >= 0 && newY >= 0 && newX < 6 && newY < 6) {
                UIButton *adjacentButton = [[_buttonArray objectAtIndex:newX] objectAtIndex:newY];
                if (adjacentButton.backgroundColor != [UIColor grayColor] && !(i == 0 && j == 0) ) {
                    adjacentButton.backgroundColor = (globalFlipper) ? [UIColor blueColor] : [UIColor yellowColor];
                
                    [UIView beginAnimations:@"Flip" context:NULL];
                    [UIView setAnimationDuration:0.40];
                    [UIView setAnimationDelegate:self];
                    [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromRight forView:adjacentButton cache:NO];
                
                    [UIView commitAnimations];
                }
            }
        }
    }
}


@end
