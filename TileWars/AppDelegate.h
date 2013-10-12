//
//  AppDelegate.h
//  TileWars
//
//  Created by Tyler McAtee on 10/11/13.
//  Copyright (c) 2013 Tyler McAtee. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) NSString *playmode;

-(void) updatePlayMode: (NSString *) newMode;

@end
