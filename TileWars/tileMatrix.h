//
//  tileMatrix.h
//  tileMatrix
//
//  Created by Tyler McAtee on 10/20/13.
//  Copyright (c) 2013 Tyler McAtee. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface tileMatrix : UIView {
    @private
    int size_of_tileMatrix;
}

/** An array of arrays that stores all N^2 tiles that this 
  * matrix represents. Should not be accessed directly. */
@property (strong, nonatomic) NSMutableArray *buttonArray;

/** Initializes a NxN tile matrix, centered in the correct position
 * on the screen. Requires N to be in the range [1, 6]. 
 * Throws InvalidArgumentException. */
-(id) initWithSize: (int) N;

/** Returns the button in row x and column y of tileMatrix.
  * Requires x and y to both be in the range [0, N - 1].
  * Throws InvalidArgumentException. */
-(UIButton *) getButtonAtX: (int) x andY: (int) y;

/** Changes the color of the button in row x and column y
  * to the UIColor specified. Calls getButtonAtX. */
-(void) changeColorTo: (UIColor *) color atX: (int) x andY: (int) y;

/** Returns the color of the button in row x and column y.
  * Calls getButtonAtX. */
-(UIColor *) colorAtX: (int) x andY: (int) y;

/** Returns true if the color of the button in row x and column y
  * is gray, returns false otherwise. Calls getButtonAtX. */
-(BOOL) isGrayAtX: (int) x andY: (int) y;

/** Sets the title of the button in row x and column y to the 
  * title specified by TITLE. Calls getButtonAtX. */
-(void) setTitle: (NSString *) title atX: (int) x andY: (int) y;

/** Flips the button in row x and column y right for duration DURATION. 
  * Calls getButtonAtX. */
-(void) flipRightAtX: (int) x andY: (int) y forDuration: (float) duration;

/** Flips the button in row x and column y left for duration DURATION.
 * Calls getButtonAtX. */
-(void) flipLeftAtX: (int) x andY: (int) y forDuration: (float) duration;

/** Sets all of the tiles to gray color and no title. Calls changeColorTo 
  * and setTitle. */
-(void) resetToGray;

/** Makes every tile in tileMatrix non-clickable. */
-(void) makeTilesNonclickable;

/** Makes every tile in tileMatrix clickable. */
-(void) makeTilesClickable;

/** Swaps the position of a tile "A" at row x1 and column y1 with
  * the position of a tile "B" at row x2 and column y2. Animates this 
  * swap over the course of 0.5 seconds. calls getButtonAtX. */
-(void) swapFirstX: (int) x1 firstY: (int) y1 secondX: (int) x2 secondY: (int) y2;

@end
