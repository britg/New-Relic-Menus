//
//  New_Relic_MenusAppDelegate.m
//  New Relic Menus
//
//  Created by Brit Gardner on 6/4/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "NRMenusAppDelegate.h"

@implementation NRMenusAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    mainMenu = [[MainMenuController alloc] init];
    [mainMenu addStatusItem];
}

@end