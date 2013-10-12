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
}

@property (strong, nonatomic) NSMutableArray *buttonArray;
@property (strong, nonatomic) NSTimer *theTimer;
-(IBAction) selectedTile: (id) sender;
-(void) makePlayForRules: (NSMutableArray *) buttonArray forX: (int) x andY: (int) y;
- (IBAction)reset:(id)sender;

@end
