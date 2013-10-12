//
//  PlayViewController.h
//  TileWars
//
//  Created by Tyler McAtee on 10/11/13.
//  Copyright (c) 2013 Tyler McAtee. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PlayViewController : UIViewController {
    BOOL whosTurn;
    int count;
    int speedCount;
    BOOL start;
    int timerCount;
    BOOL player;
    
    
    
    int globalI;
    NSArray* globalMoves;
    int globalX;
    int globalY;
    BOOL globalFlipper;
    int globalNewX;
    int globalNewY;
}

@property (strong, nonatomic) NSMutableArray *chainStack;
@property (strong, nonatomic) NSMutableArray *blueMoves;
@property (strong, nonatomic) NSMutableArray *yellowMoves;

@property (strong, nonatomic) NSMutableArray *buttonArray;
@property (strong, nonatomic) NSTimer *theClockTimer;
@property (strong, nonatomic) NSTimer *theTimer;
@property (strong, nonatomic) NSMutableArray *flippedBits;
@property (strong, nonatomic) NSString *lastPlaymode;
-(IBAction) selectedTile: (id) sender;
-(void) makePlayForRules: (NSMutableArray *) buttonArray forX: (int) x andY: (int) y;
- (IBAction)reset:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *startButton;
- (IBAction)rulesButton:(id)sender;
-(void) youLose;
@property (weak, nonatomic) IBOutlet UILabel *infoLabel;
@property (weak, nonatomic) IBOutlet UILabel *topInfoLabel;

@end
