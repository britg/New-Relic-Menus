//
//  New_Relic_MenusAppDelegate.m
//  New Relic Menus
//
//  Created by Brit Gardner on 6/4/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "NRMenusAppDelegate.h"
#import "AGKeychain.h"

@implementation NRMenusAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    [self showMenuOrPreferences];
    [self listenForNotifications];
}

- (void)showMenuOrPreferences {
    // check for existence of new_relic_api_key
    if (![self hasAPIKey]) {
        // present a window asking for API Key
        [self presentPreferencesWindow];
        return;
    }
    
    if (!mainMenu) {
        mainMenu = [[MainMenuController alloc] init];
        [mainMenu addStatusItem];
    } else {
        [mainMenu refresh];
    }
}

- (BOOL)hasAPIKey {
    return [AGKeychain checkForExistanceOfKeychainItem:kKeyString 
                                          withItemKind:kKeyString 
                                           forUsername:kKeyString];
}

- (void)presentPreferencesWindow {
    if (!preferences) {
        DebugLog(@"Preferences doesn't exist. Creating!");
        preferences = [[PreferencesController alloc] init];
    }
    
    [preferences showWindow:self];
    [preferences showAccountPreferences:self];
}

- (void)listenForNotifications {
    // Show preferences window
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(presentPreferencesWindow) 
                                                 name:SHOW_PREFERENCES_NOTIFICATION
                                               object:nil];
    
    // api key added
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(showMenuOrPreferences) 
                                                 name:API_KEY_VALIDATED_NOTIFICATION
                                               object:nil];
}

@end