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
}

@property (strong, nonatomic) NSMutableArray *buttonArray;
@property (strong, nonatomic) NSTimer *theClockTimer;
@property (strong, nonatomic) NSTimer *theTimer;
@property (strong, nonatomic) NSString *playmode;
@property (strong, nonatomic) NSMutableArray *flippedBits;
-(IBAction) selectedTile: (id) sender;
-(void) makePlayForRules: (NSMutableArray *) buttonArray forX: (int) x andY: (int) y;
- (IBAction)reset:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *startButton;
- (IBAction)rulesButton:(id)sender;
-(void) youLose;
@property (weak, nonatomic) IBOutlet UILabel *infoLabel;
@property (weak, nonatomic) IBOutlet UILabel *topInfoLabel;

@end
