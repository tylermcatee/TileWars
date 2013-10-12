//
//  PlayViewController.h
//  TileWars
//
//  Created by Tyler McAtee on 10/11/13.
//  Copyright (c) 2013 Tyler McAtee. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PlayViewController : UIViewController {
    BOOL isPushed;
}

@property (strong, nonatomic) NSMutableArray *buttonArray;
-(IBAction) selectedTile: (id) sender;

@end
