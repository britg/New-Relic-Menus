//
//  New_Relic_MenusAppDelegate.h
//  New Relic Menus
//
//  Created by Brit Gardner on 6/4/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MainMenuController.h"
#import "PreferencesController.h"

@interface NRMenusAppDelegate : NSObject {
    MainMenuController *mainMenu;
    PreferencesController *preferences;
}

- (void)showMenuOrPreferences;
- (BOOL)hasAPIKey;
- (void)presentPreferencesWindow;

@end
