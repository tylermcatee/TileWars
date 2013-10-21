//
//  tileMatrix.m
//  tileMatrix
//
//  Created by Tyler McAtee on 10/20/13.
//  Copyright (c) 2013 Tyler McAtee. All rights reserved.
//
//  Please examine header file for information on how to use this class.

#import "tileMatrix.h"

@implementation tileMatrix

- (id) initWithSize: (int) N {
    if (N < 1 | N > 6) {
        NSException *e = [NSException exceptionWithName:@"InvalidArgumentException" reason:@"N must be in range [1, 6]" userInfo:nil];
        @throw e;
    }
    
    size_of_tileMatrix = N;
    _buttonArray = [[NSMutableArray alloc] init];
    
    CGRect screen = [[UIScreen mainScreen] bounds];
    self = [super initWithFrame:CGRectMake(screen.origin.x, screen.origin.y, screen.size.width, screen.size.height - 100)];
    int matrixWidth = 40 + 50*(N - 1);
    int x_origin = 15;
    int y_origin = (screen.size.height == 480) ? 30 : 90;
    int max_matrixWidth = screen.size.width - 2*x_origin;
    x_origin = x_origin + max_matrixWidth/2 - matrixWidth/2;
    y_origin = y_origin + max_matrixWidth/2 - matrixWidth/2;
    NSLog(@"x_origin: %d, y_origin: %d", x_origin, y_origin);
    
    int row = 0;
    int column;
    for (int i = x_origin; i < x_origin + N*50; i += 50) {
        NSMutableArray *columnArray = [[NSMutableArray alloc] init];
        column = 0;
        for (int j = y_origin; j < y_origin + N*50; j += 50) {
            UIButton *button = [self makeButton];
            CGRect newFrame = button.frame;
            newFrame.origin.x = (CGFloat) i;
            newFrame.origin.y = (CGFloat) j;
            button.frame = newFrame;
            button.tag = row*10 + column;
            [columnArray addObject:button];
            [self addSubview:button];
            column += 1;
        }
        [_buttonArray addObject:columnArray];
        row += 1;
    }
    
    return self;
}

-(UIButton *) makeButton
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    button.backgroundColor = [UIColor grayColor];
    [button addTarget:self
               action:nil
     forControlEvents:UIControlEventTouchDown];
    button.frame = CGRectMake(0.0, 0.0, 40.0, 40.0);
    return button;
}

-(UIButton *) getButtonAtX: (int) x andY: (int) y {
    if (x < 0 | x >= size_of_tileMatrix) {
        NSException *e = [NSException exceptionWithName:@"InvalidArgumentException" reason:@"x must be in range [0, N - 1]" userInfo:nil];
        @throw e;
    }
    if (y < 0 | y >= size_of_tileMatrix) {
        NSException *e = [NSException exceptionWithName:@"InvalidArgumentException" reason:@"y must be in range [0, N - 1]" userInfo:nil];
        @throw e;
    }
    return [[_buttonArray objectAtIndex: x] objectAtIndex: y];
}

-(void) changeColorTo: (UIColor *) color atX: (int) x andY: (int) y {
    UIButton *refButton = [self getButtonAtX:x andY:y];
    [refButton setBackgroundColor:color];
}

-(UIColor *) colorAtX:(int)x andY:(int)y {
    UIButton *refButton = [self getButtonAtX:x andY:y];
    return refButton.backgroundColor;
}

-(BOOL) isGrayAtX:(int)x andY:(int)y {
    return [[self colorAtX:x andY:y] isEqual: [UIColor grayColor]];
}

-(void) setTitle: (NSString *) title atX: (int) x andY: (int) y {
    UIButton *refButton = [self getButtonAtX:x andY:y];
    [refButton setTitle:title forState:UIControlStateNormal];
}

-(void) flipRightAtX: (int) x andY: (int) y forDuration: (float) duration {
    UIButton *refButton = [self getButtonAtX:x andY:y];
    [UIView beginAnimations:@"Flip" context:NULL];
    [UIView setAnimationDuration:duration];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromRight forView:refButton cache:NO];
    [UIView setAnimationDelegate:self];
    [UIView commitAnimations];

}

-(void) flipLeftAtX: (int) x andY: (int) y forDuration: (float) duration {
    UIButton *refButton = [self getButtonAtX:x andY:y];
    [UIView beginAnimations:@"Flip" context:NULL];
    [UIView setAnimationDuration:duration];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft forView:refButton cache:NO];
    [UIView setAnimationDelegate:self];
    [UIView commitAnimations];
}

-(void) resetToGray {
    for (int i = 0; i < size_of_tileMatrix; i++) {
        for (int j = 0; j < size_of_tileMatrix; j++) {
            [self changeColorTo:[UIColor grayColor] atX:i andY:j];
            [self setTitle:@"" atX:i andY:j];
        }
    }
}

-(void) makeTilesNonclickable {
    UIButton* thisButton;
    for (int i = 0; i < size_of_tileMatrix; i++) {
        for (int j = 0; j < size_of_tileMatrix; j++) {
            thisButton = [self getButtonAtX:i andY:j];
            thisButton.userInteractionEnabled = false;
        }
    }
}

-(void) makeTilesClickable {
    UIButton* thisButton;
    for (int i = 0; i < size_of_tileMatrix; i++) {
        for (int j = 0; j < size_of_tileMatrix; j++) {
            thisButton = [self getButtonAtX:i andY:j];
            thisButton.userInteractionEnabled = true;
        }
    }
}

-(void) swapFirstX: (int) x1 firstY: (int) y1 secondX: (int) x2 secondY: (int) y2 {
    UIButton* buttonA = [self getButtonAtX:x1 andY:y1];
    UIButton* buttonB = [self getButtonAtX:x2 andY:y2];
    int Atag = [buttonA tag];
    int Btag = [buttonB tag];
    buttonA.tag = Btag;
    buttonB.tag = Atag;
    
    [[_buttonArray objectAtIndex:x1] replaceObjectAtIndex:y1 withObject:buttonB];
    [[_buttonArray objectAtIndex:x2] replaceObjectAtIndex:y2 withObject:buttonA];
    
    CGRect frameA = buttonA.frame;
    CGRect frameB = buttonB.frame;
    [UIView animateWithDuration:0.5 animations:^{
        buttonA.frame = frameB;
        buttonB.frame = frameA;
    }];
}


@end
