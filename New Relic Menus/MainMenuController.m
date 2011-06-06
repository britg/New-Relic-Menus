//
//  MainMenuController.m
//  New Relic Menus
//
//  Created by Brit Gardner on 6/4/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MainMenuController.h"


@implementation MainMenuController

- (id)init
{
    self = [super init];
    if (self) {
        mainStatusItem = [[[NSStatusBar systemStatusBar] 
                           statusItemWithLength:NSSquareStatusItemLength] retain];    
    }
    
    return self;
}

- (void)dealloc
{
    [super dealloc];
}

- (void)addStatusItem {
    [self createMainMenu];
    [self refresh];
}

- (void)createMainMenu {
    NSZone *menuZone = [NSMenu menuZone];
	menu = [[NSMenu allocWithZone:menuZone] init];
    
    NSMenuItem *menuItem;
    
    menuItem = [menu addItemWithTitle:@"Preferences" action:@selector(notifyPreferencesAction) keyEquivalent:@"P"];
    [menuItem setToolTip:@"Change your API Key"];
    [menuItem setTarget:self];
}


- (void)notifyPreferencesAction {
    [[NSNotificationCenter defaultCenter] 
     postNotification:[NSNotification notificationWithName:SHOW_PREFERENCES object:nil]];
}

#pragma mark - Main Status Item

- (void)refresh {
    [mainStatusItem setMenu:menu];
    [mainStatusItem setLength:100];
    [mainStatusItem setHighlightMode:YES];
    [mainStatusItem setTitle:@"Loading..."];
    [mainStatusItem setToolTip:@"New Relic Menus"];
    [mainStatusItem setImage:[NSImage imageNamed:@"newrelic"]];
    [self getPrimaryMetrics];
}

- (void)getPrimaryMetrics {
    
}

@end
