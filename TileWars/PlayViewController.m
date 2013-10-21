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
#import "tileMatrix.h"

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
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    maxMemoryLevel = [prefs integerForKey:@"maxMemoryLevel"];
    
    speedHighScore = [prefs objectForKey:@"speedHighScore"];
    
    whosTurn = true;
    gameRunning = false;
    count = 0;
    speedCount = 0;
    _infoLabel.text = @"";
    _topInfoLabel.text = @"";
    player = true;
    nextButtonActive = true;
    
    //Data Structures for ChainTile
    _blueMoves = [[NSMutableArray alloc] initWithObjects: nil];
    _yellowMoves = [[NSMutableArray alloc] initWithObjects: nil];
    _chainStack = [[NSMutableArray alloc] initWithObjects: nil];
    _allTimers = [[NSMutableArray alloc] initWithObjects: nil];
    
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    _lastPlaymode = delegate.playmode; //Will initialize to FastTile
    
    
    matrix = [[tileMatrix alloc] initWithSize:6];
    [self.view addSubview:matrix];
    
    for (int i = 0; i < 6; i++) {
        for (int j = 0; j < 6; j++) {
            UIButton *refButton = [matrix getButtonAtX:i andY:j];
            [refButton addTarget:self
                          action:@selector(selectedTile:)
             forControlEvents:UIControlEventTouchDown];
        }
    }
}

-(void) reloadScreen {
    _infoLabel.text = @"";
    _topInfoLabel.text = @"";
    
    for (id timerObject in _allTimers){
        if ([timerObject isValid]) [timerObject invalidate];
    }
    [_allTimers removeAllObjects];
    
    //Make every button grayColor
    //HERE IS A RESET
    [matrix resetToGray];
    
    gameRunning = false;
    if ([_lastPlaymode isEqualToString:@"SpeedTile"]) [self initSpeedTile];
    else if ([_lastPlaymode isEqualToString:@"OriginalRules"]) [self initOriginalRules];
    else if ([_lastPlaymode isEqualToString:@"ChainTile"]) [self initChainTile];
    else [self initMemoryTile];
}

-(void) initSpeedTile {
    [self makeTilesClickable];
    _startButton.alpha = 1.0;
    [_startButton setTitle:@"Start" forState:UIControlStateNormal];
    _infoLabel.text = @"";
    _topInfoLabel.text = speedHighScore;
    _topSquare.backgroundColor = [UIColor clearColor];
    _square.backgroundColor = [UIColor clearColor];
}
-(void) initOriginalRules {
    [self makeTilesClickable];
    [_startButton setTitle:@"Reset" forState:UIControlStateNormal];
    _topInfoLabel.text = @"Blue Score: 0";
    _infoLabel.text =    @"Red  Score: 0";
    whosTurn = true;
    count = 0;
    _topSquare.backgroundColor = [UIColor blueColor];
    _square.backgroundColor = [UIColor clearColor];
}
-(void) initChainTile {
    [self makeTilesClickable];
    [_startButton setTitle:@"Reset" forState:UIControlStateNormal];
    player = true;
    _blueMoves = [[NSMutableArray alloc] initWithObjects: nil];
    _yellowMoves = [[NSMutableArray alloc] initWithObjects: nil];
    _chainStack = [[NSMutableArray alloc] initWithObjects: nil];
    _topInfoLabel.text = @"Blue   Score: 0";
    _infoLabel.text =    @"Yellow Score: 0";
    _topSquare.backgroundColor = [UIColor blueColor];
    _square.backgroundColor = [UIColor clearColor];
    chainYellowScore = 0;
    chainBlueScore = 0;
}
-(void) initMemoryTile {
    [_startButton setTitle:@"Next" forState:UIControlStateNormal];
    _chainStack = [[NSMutableArray alloc] initWithObjects: nil];
    _topSquare.backgroundColor = [UIColor clearColor];
    _square.backgroundColor = [UIColor clearColor];
    _topInfoLabel.text = [NSString stringWithFormat:@"Max Level: %d", maxMemoryLevel];
    _infoLabel.text = @"Current Level: 0";
    currentMemoryLevel = 0;
    [self makeTilesNonclickable];
    [self makeNextButtonActive];
}

- (void) viewDidAppear:(BOOL)animated {
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    if (![_lastPlaymode isEqualToString:delegate.playmode]) {
        _lastPlaymode = delegate.playmode;
        [self reloadScreen];
    }
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
    else [self makePlayForRulesMemoryTile:buttonArray forX:x andY:y];
}

- (IBAction)reset:(id)sender {
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSString *playmode = delegate.playmode;
    if ([playmode isEqualToString:@"SpeedTile"]) [self resetSpeedTile];
    else if ([playmode isEqualToString:@"OriginalRules"]) [self resetOriginalRules];
    else if ([playmode isEqualToString:@"ChainTile"]) [self resetChainTile];
    else [self resetMemoryTile];
}

- (IBAction)rulesButton:(id)sender {
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSString *playmode = delegate.playmode;
    if ([playmode isEqualToString:@"SpeedTile"]) [self rulesButtonSpeedTile];
    else if ([playmode isEqualToString:@"OriginalRules"]) [self rulesButtonOriginalRules];
    else if ([playmode isEqualToString:@"ChainTile"]) [self rulesButtonChainTile];
    else [self rulesButtonMemoryTile];
}

#pragma mark SpeedTile methods

- (void) resetSpeedTile {
    if (!gameRunning) {
        _theTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(randomFlip) userInfo:nil repeats:YES];
        [_allTimers addObject:_theTimer];
        _infoLabel.text = @"0:00:00";
        _theClockTimer = [NSTimer scheduledTimerWithTimeInterval:.01 target:self selector:@selector(incrementTimer) userInfo:Nil repeats:YES];
        [_allTimers addObject:_theClockTimer];
        gameRunning = true;
        [_startButton setTitle:@"Reset" forState:UIControlStateNormal];
        speedCount = 0;
        timerCount = 0;
    } else {
        if (_theTimer)
            [_theTimer invalidate];
        if (_theClockTimer) {
            [_theClockTimer invalidate];
            _infoLabel.text = @"";
        }
        
        //Reset to gray and notitle
        // HERE IS A RESET
        [matrix resetToGray];
        
        speedCount = 0;
        timerCount = 0;
        chainBlueScore = 0;
        chainYellowScore = 0;
        
        gameRunning = false;
        [_startButton setTitle:@"Start" forState:UIControlStateNormal];
        
    }

}

-(void) makePlayForRulesSpeedTile:(NSMutableArray *)buttonArray forX:(int)x andY:(int)y {
    if (![[matrix colorAtX:x andY:y] isEqual:[UIColor redColor]])
        return;
    [matrix changeColorTo:[UIColor grayColor] atX:x andY:y];
    [matrix flipRightAtX:x andY:y forDuration:0.40];
    speedCount -= 1;
}

-(void) randomFlip {
    timerCount += 1;
    int randX = arc4random() % 6;
    int randY = arc4random() % 6;
    while ([[matrix colorAtX:randX andY:randY] isEqual:[UIColor redColor]]) {
        randX = rand() % 6;
        randY = rand() % 6;
    }
    [matrix flipRightAtX:randX andY:randY forDuration:0.40];
    [matrix changeColorTo:[UIColor redColor] atX:randX andY:randY];
    speedCount += 1;
    
    [_theTimer invalidate];
    float delay = 1/(pow((float)timerCount, 0.3));
    _theTimer = [NSTimer scheduledTimerWithTimeInterval: delay target:self selector:@selector(randomFlip) userInfo:nil repeats:YES];
    [_allTimers addObject:_theTimer];
    if (speedCount == 10) {
        [_theClockTimer invalidate];
        [_theTimer invalidate];
        _theTimer = [NSTimer scheduledTimerWithTimeInterval:0.6 target:self selector:@selector(youLose) userInfo:nil repeats:NO];
        [_allTimers addObject:_theTimer];
    }
}

-(void) youLose {
    
    [matrix changeColorTo:[UIColor greenColor] atX:1 andY:2];
    [matrix setTitle:@"G" atX:1 andY:2];
    [matrix changeColorTo:[UIColor greenColor] atX:2 andY:2];
    [matrix setTitle:@"A" atX:2 andY:2];
    [matrix changeColorTo:[UIColor greenColor] atX:3 andY:2];
    [matrix setTitle:@"M" atX:3 andY:2];
    [matrix changeColorTo:[UIColor greenColor] atX:4 andY:2];
    [matrix setTitle:@"E" atX:4 andY:2];
    
    [matrix changeColorTo:[UIColor greenColor] atX:1 andY:3];
    [matrix setTitle:@"O" atX:1 andY:3];
    [matrix changeColorTo:[UIColor greenColor] atX:2 andY:3];
    [matrix setTitle:@"V" atX:2 andY:3];
    [matrix changeColorTo:[UIColor greenColor] atX:3 andY:3];
    [matrix setTitle:@"E" atX:3 andY:3];
    [matrix changeColorTo:[UIColor greenColor] atX:4 andY:3];
    [matrix setTitle:@"R" atX:4 andY:3];
    
    _startButton.titleLabel.text = @"Reset";
    
    if ([_topInfoLabel.text isEqualToString:@""]) {
        _topInfoLabel.text = _infoLabel.text;
        speedHighScore = _infoLabel.text;
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:speedHighScore forKey:@"speedHighScore"];
    } else if ([self timeToInt:_infoLabel] > [self timeToInt:_topInfoLabel]) {
        _topInfoLabel.text = _infoLabel.text;
        speedHighScore = _infoLabel.text;
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:speedHighScore forKey:@"speedHighScore"];
    }
}

- (void) rulesButtonSpeedTile {
    if (!gameRunning) {
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
    
    if (![matrix isGrayAtX:x andY:y])
        return;
    [matrix flipRightAtX:x andY:y forDuration:0.40];
    UIColor *newColor = whosTurn ? [UIColor blueColor] : [UIColor redColor];
    [matrix changeColorTo:newColor atX:x andY:y];
    UIButton *pushedButton = [matrix getButtonAtX:x andY:y];
    int myPoints = 1;
    int minusPoints = 0;
    for (int i = -1; i < 2; i++) {
        for (int j = -1; j < 2; j++) {
            int newX = x + i;
            int newY = y + j;
            
            if (newX >= 0 && newY >= 0 && newX < 6 && newY < 6) {
                UIButton *adjacentButton = [matrix getButtonAtX:newX andY:newY];
                if (adjacentButton.backgroundColor != [UIColor grayColor] && adjacentButton.backgroundColor != pushedButton.backgroundColor) {
                    myPoints += 1;
                    minusPoints += 1;
                    [matrix changeColorTo:newColor atX:newX andY:newY];
                    [matrix flipRightAtX:newX andY:newY forDuration:0.40];
                }
            }
        }
    }
    
    NSString *scoreString = whosTurn ? _topInfoLabel.text : _infoLabel.text;
    NSString *otherScoreString = whosTurn ? _infoLabel.text : _topInfoLabel.text;
    NSArray *secondSplits = [otherScoreString componentsSeparatedByString:@" "];
    NSArray *theSplits = [scoreString componentsSeparatedByString:@" "];
    int currentScore = [[theSplits objectAtIndex:2] intValue];
    int theirScore = [[secondSplits objectAtIndex:2] intValue];
    theirScore -= minusPoints;
    currentScore += myPoints;
    NSString *stringOne = [theSplits objectAtIndex:0];
    NSString *stringTwo = [theSplits objectAtIndex:1];
    NSString *theirOne = [secondSplits objectAtIndex:0];
    if (whosTurn) {
        _topInfoLabel.text = [NSString stringWithFormat:@"%@ %@ %d", stringOne, stringTwo, currentScore];
        _infoLabel.text = [NSString stringWithFormat:@"%@ %@ %d", theirOne, stringTwo, theirScore];
    } else {
        _infoLabel.text = [NSString stringWithFormat:@"%@ %@ %d", stringOne, stringTwo, currentScore];
        _topInfoLabel.text = [NSString stringWithFormat:@"%@ %@ %d", theirOne, stringTwo, theirScore];
    }
    
    if (count == 0) {
        count++;
    } else {
        whosTurn = !whosTurn;
        if (whosTurn) {
            _topSquare.backgroundColor = [UIColor blueColor];
            _square.backgroundColor = [UIColor clearColor];
        } else {
            _topSquare.backgroundColor = [UIColor clearColor];
            _square.backgroundColor = [UIColor redColor];
        }
        count = 0;
    }
}

-(void) resetOriginalRules {
    
    [_startButton setTitle:@"Reset" forState:UIControlStateNormal];
    _topInfoLabel.text = @"Blue Score: 0";
    _infoLabel.text =    @"Red  Score: 0";
    whosTurn = true;
    count = 0;
    _topSquare.backgroundColor = [UIColor blueColor];
    _square.backgroundColor = [UIColor clearColor];
    
    //Make every button grayColor
    [matrix resetToGray];
    
    gameRunning = false;
    
}

- (void) rulesButtonOriginalRules {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Flip Tile Rules"
                                                        message:@"Play against a friend! Take two turns each and try to get the most tiles"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
}

#pragma mark ChainTile methods

- (void) makePlayForRulesChainTile: (NSMutableArray *) buttonArray forX: (int) x andY: (int) y {
    if (![matrix isGrayAtX:x andY:y])
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
    
    [matrix makeTilesNonclickable];
    [matrix flipRightAtX:x andY:y forDuration:0.40];
    UIColor *newColor = player ? [UIColor blueColor] : [UIColor yellowColor];
    [matrix changeColorTo:newColor atX:x andY:y];
    
    if (player) chainBlueScore += 1;
    else chainYellowScore += 1;
    
    [self flipNeighbors:x andY:y andWho:player];
    
    globalFlipper = !player;
    
    float timeStop = 0.65;
    for (int i = moves.count - 1; i > 0; i-=1) {
        struct tileCoordinate theTileCoordinate;
        [[moves objectAtIndex:i] getValue:&theTileCoordinate];
        struct tileCoordinate theOldCoordinate;
        [[moves objectAtIndex:i - 1] getValue:&theOldCoordinate];
        
        [_chainStack addObject: [NSNumber numberWithInt:theTileCoordinate.x]];
        [_chainStack addObject: [NSNumber numberWithInt:theTileCoordinate.y]];
        [_chainStack addObject: [NSNumber numberWithInt:theOldCoordinate.x]];
        [_chainStack addObject: [NSNumber numberWithInt:theOldCoordinate.y]];
        
        [_allTimers addObject: [NSTimer scheduledTimerWithTimeInterval:timeStop target:self selector:@selector(chainAnimation) userInfo:nil repeats:NO]];
        timeStop += 0.65;
    }
    
    [_allTimers addObject: [NSTimer scheduledTimerWithTimeInterval:timeStop target:self selector:@selector(makeTilesClickable) userInfo:nil repeats:NO]];
    [self updateChain];
    
    player = !player;
    
    if (player) {
        _topSquare.backgroundColor = [UIColor blueColor];
        _square.backgroundColor = [UIColor clearColor];
    } else {
        _topSquare.backgroundColor = [UIColor clearColor];
        _square.backgroundColor = [UIColor yellowColor];
    }
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
    [matrix swapFirstX:xOld firstY:yOld secondX:xNew secondY:yNew];
    [self flipNeighbors:xNew andY:yNew andWho:globalFlipper];
    globalFlipper = !globalFlipper;
}

-(void) updateChain {
    _topInfoLabel.text = [NSString stringWithFormat:@"Blue Score: %d", chainBlueScore];
    _infoLabel.text = [NSString stringWithFormat:@"Yellow Score: %d", chainYellowScore];
}

-(void) flipNeighbors: (int) x andY: (int) y andWho: (BOOL) whoToFlip {
    for (int i = -1; i < 2; i++) {
        for (int j = -1; j < 2; j++) {
            int newX = x + i;
            int newY = y + j;
        
            if (newX >= 0 && newY >= 0 && newX < 6 && newY < 6) {
                UIColor *nextColor = (whoToFlip) ? [UIColor blueColor] : [UIColor yellowColor];
                if (![matrix isGrayAtX:newX andY:newY] && !(i == 0 && j == 0) ) {
                    if ([matrix colorAtX:newX andY:newY] != nextColor){
                        if (whoToFlip) {
                            chainBlueScore += 1;
                            chainYellowScore -= 1;
                        }
                        else {
                            chainYellowScore += 1;
                            chainBlueScore -= 1;
                        }
                    }
                    [matrix changeColorTo:nextColor atX:newX andY:newY];
                    [matrix flipRightAtX:newX andY:newY forDuration:0.40];
                }
            }
        }
    }
    [self updateChain];
}

-(void) resetChainTile {
    //Make every button grayColor
    [matrix resetToGray];
    [self initChainTile];
    
}

- (void) rulesButtonChainTile {
    if (!gameRunning) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Chain Tile Rules"
                                                        message:@"Play with a friend. Flipping a tile activates a chain reaction!"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    }
}

#pragma mark memoryTile methods

-(void) makeTilesNonclickable {
    [matrix makeTilesClickable];
}

-(void) makeTilesClickable {
    [matrix makeTilesClickable];
}

-(void) makePlayForRulesMemoryTile:(NSMutableArray *)buttonArray forX:(int)x andY:(int)y {
    UIButton *thisButton = [matrix getButtonAtX:x andY:y];
    if ([_chainStack containsObject: thisButton]) {
        [_chainStack removeObject:thisButton];
        [matrix changeColorTo:[UIColor greenColor] atX:x andY:y];
        [matrix flipRightAtX:x andY:y forDuration:0.40];
        if (_chainStack.count == 0) {
            currentMemoryLevel += 1;
            [matrix makeTilesClickable];
            [_allTimers addObject:[NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(makeTilesGrayFlip) userInfo:nil repeats:NO]];
            [_allTimers addObject:[NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(makeNextButtonActive) userInfo:nil repeats:NO]];
            [self updateMemoryLevels];
        }
    } else {
        [matrix changeColorTo:[UIColor redColor] atX:x andY:y];
        if (maxMemoryLevel < currentMemoryLevel) {
            maxMemoryLevel = currentMemoryLevel;
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            [defaults setInteger:maxMemoryLevel forKey:@"maxMemoryLevel"];
            [defaults synchronize];
        }
        currentMemoryLevel = 0;
        [self updateMemoryLevels];
        [matrix makeTilesNonclickable];
        [matrix flipRightAtX:x andY:y forDuration:0.40];
        [_allTimers addObject:[NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(makeNextButtonActive) userInfo:nil repeats:NO]];
        
        
        for (UIButton *missedButton in _chainStack) {
            int tag = [missedButton tag];
            int missed_x = tag/10;
            int missed_y = tag%10;
            [matrix changeColorTo:[UIColor blueColor] atX:missed_x andY:missed_y];
        }
        [_allTimers addObject:[NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(makeTilesGrayFlip) userInfo:nil repeats:NO]];
        [self initMemoryTile];
    }
    
}
-(void) makeNextButtonActive{
    nextButtonActive = true;
}

-(void) resetMemoryTile {
    if (!nextButtonActive) return;
    while (_chainStack.count > 0) [_chainStack removeObjectAtIndex:0];
    
    [self makeMemoryLevel];
    [_allTimers addObject:[NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(makeTilesGrayFlip) userInfo:nil repeats:NO]];
    
    if (_chainStack.count > 1) {
        noopCount = (currentMemoryLevel - 1);
        [_allTimers addObject:[NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(makeTileSwaps) userInfo:nil repeats:NO]];
    }
    if (_chainStack.count == 2){
        [_allTimers addObject:[NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(makeTilesClickable) userInfo:nil repeats:NO]];
    }
    else[_allTimers addObject:[NSTimer scheduledTimerWithTimeInterval:_chainStack.count target:self selector:@selector(makeTilesClickable) userInfo:nil repeats:NO]];
    nextButtonActive = false;
}

-(void) makeMemoryLevel {
    int increment = 1;
    int numLoops = 0;
    for(int i = 0; i < currentMemoryLevel + 1 && numLoops < 17; i+= increment){
        int randX = arc4random() % 6;
        int randY = arc4random() % 6;
        while ([[matrix colorAtX:randX andY:randY] isEqual:[UIColor greenColor]]){
            randX = arc4random() % 6;
            randY = arc4random() % 6;
        }
        UIButton *hiddenButton = [matrix getButtonAtX:randX andY:randY];
        [_chainStack addObject:hiddenButton];
        [matrix changeColorTo:[UIColor greenColor] atX:randX andY:randY];
        [matrix flipRightAtX:randX andY:randY forDuration:0.40];
        numLoops += 1;
        if (i > 6 && i % 3 == 0) {
            increment += 1;
        }
    }
}

-(void) makeTileSwaps {
    if (noopCount > 0) {
        int tileToSwap = arc4random() % _chainStack.count;
        UIButton *buttonToSwap = [_chainStack objectAtIndex:tileToSwap];
        int theTag = [buttonToSwap tag];
        int xOld = theTag % 10;
        int yOld = theTag / 10;
        int xNew = arc4random() % 6;
        int yNew = arc4random() % 6;
        while (xNew == xOld && yNew == yOld) {
            xNew = arc4random() % 6;
            yNew = arc4random() % 6;
        }
        [matrix swapFirstX:xOld firstY:yOld secondX:xNew secondY:yNew];
        [_allTimers addObject:[NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(noop) userInfo:Nil repeats:NO]];
    }
}

-(void) noop {
    noopCount -= 1;
    [self makeTileSwaps];
}

- (void) makeTilesGrayFlip {
    UIButton *thisButton;
    for (int i = 0; i < 6; i++) {
        for (int j = 0; j < 6; j++) {
            thisButton = [matrix getButtonAtX:i andY:j];
            [matrix setTitle:@"" atX:i andY:j];
            if (thisButton.backgroundColor != [UIColor grayColor]) {
                [matrix flipRightAtX:i andY:j forDuration:0.40];
            }
            [matrix changeColorTo:[UIColor grayColor] atX:i andY:j];
        }
    }
}

-(void) updateMemoryLevels {
    self.topInfoLabel.text = [NSString stringWithFormat:@"Max Level: %d", maxMemoryLevel];
    self.infoLabel.text = [NSString stringWithFormat:@"Current Level: %d", currentMemoryLevel];
}

- (void) rulesButtonMemoryTile {
    if (!gameRunning) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Memory Tile Rules"
                                                        message:@"Remember where the tiles were shown."
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    }
}


@end
