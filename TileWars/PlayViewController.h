//
//  PlayViewController.h
//  TileWars
//
//  Created by Tyler McAtee on 10/11/13.
//  Copyright (c) 2013 Tyler McAtee. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "tileMatrix.h"

@interface PlayViewController : UIViewController {
    int count;
    int speedCount;
    int timerCount;
    int chainBlueScore;
    int chainYellowScore;
    int originalRedScore;
    int originalBlueScore;
    int currentMemoryLevel;
    int maxMemoryLevel;
    int noopCount;

    int matrix_size;

    BOOL gameRunning;
    BOOL player;
    BOOL nextButtonActive;
    BOOL globalFlipper;

    NSString* speedHighScore;
    tileMatrix *matrix;
}

@property (weak, nonatomic) IBOutlet UILabel *topSquare;
@property (weak, nonatomic) IBOutlet UILabel *square;

@property (strong, nonatomic) NSMutableArray *chainStack;
@property (strong, nonatomic) NSMutableArray *allTimers;
@property (strong, nonatomic) NSMutableArray *blueMoves;
@property (strong, nonatomic) NSMutableArray *yellowMoves;

@property (strong, nonatomic) NSTimer *theClockTimer;
@property (strong, nonatomic) NSTimer *theTimer;
@property (strong, nonatomic) NSString *lastPlaymode;

@property (weak, nonatomic) IBOutlet UIButton *startButton;
@property (weak, nonatomic) IBOutlet UILabel *infoLabel;
@property (weak, nonatomic) IBOutlet UILabel *topInfoLabel;

/* selectedTile associated with every single tile in the matrix. */
-(IBAction) selectedTile: (id) sender;
/** These are the skeleton methods that must be filled out for 
  * every game added to this suite. */
-(void) makePlayForRules: (int) x andY: (int) y;
- (IBAction)reset:(id)sender;
- (IBAction)rulesButton:(id)sender;

@end
