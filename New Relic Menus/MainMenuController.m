//
//  MainMenuController.m
//  New Relic Menus
//
//  Created by Brit Gardner on 6/4/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MainMenuController.h"
#import "APIHandler.h"

@implementation MainMenuController

- (id)init
{
    self = [super init];
    if (self) {
        mainStatusItem = [[[NSStatusBar systemStatusBar] 
                           statusItemWithLength:NSVariableStatusItemLength] retain];
        [self listenForNotifications];
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
    
    [mainStatusItem setMenu:menu];
    [mainStatusItem setHighlightMode:YES];
    [mainStatusItem setToolTip:@"New Relic Menus"];
    [mainStatusItem setImage:[NSImage imageNamed:@"newrelic"]];
}

- (void)listenForNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(statsUpdated) 
                                                 name:METRICS_OBTAINED_NOTIFICATION
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(getPrimaryMetrics) 
                                                 name:APPLICATION_OBTAINED_NOTIFICATION
                                               object:nil];
}

#pragma mark - States

- (void)refresh {
    [self setStateLoading];
    [self ensureValidAPIKey];
}

- (void)ensureValidAPIKey {
    [[APIHandler sharedInstance] getPrimaryAccount];
}

- (void)setStateLoading {
    //[mainStatusItem setLength:100];
    [mainStatusItem setTitle:@"Loading..."];
}

- (void)statsUpdated {
    DebugLog(@"Status updated!");
    [mainStatusItem setTitle:[NSString stringWithFormat:@"%.00frpm %.0fms %.02ferr %.01fapdex", 
                              [[[APIHandler sharedInstance] throughput] floatValue],
                              [[[APIHandler sharedInstance] responseTime] floatValue],
                              [[[APIHandler sharedInstance] errorPercent] floatValue],
                              [[[APIHandler sharedInstance] apdex] floatValue]
                              ]];
}

#pragma mark - Actions

- (void)notifyPreferencesAction {
    [[NSNotificationCenter defaultCenter] 
     postNotification:[NSNotification notificationWithName:SHOW_PREFERENCES_NOTIFICATION object:nil]];
}

- (void)getPrimaryMetrics {
    DebugLog(@"Fetching primary metrics");
    [[APIHandler sharedInstance] getPrimaryMetrics];
}

@end
