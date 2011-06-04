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
    NSMenu *menu = [self createMainMenu];
    [mainStatusItem setMenu:menu];
    [mainStatusItem setLength:100];
    [mainStatusItem setHighlightMode:YES];
    [mainStatusItem setTitle:@"Loading..."];
    [mainStatusItem setToolTip:@"New Relic Menus"];
    [mainStatusItem setImage:[NSImage imageNamed:@"newrelic"]];
    
}

- (NSMenu *)createMainMenu {
    NSZone *menuZone = [NSMenu menuZone];
	NSMenu *menu = [[NSMenu allocWithZone:menuZone] init];
    
    return menu;
}

@end
