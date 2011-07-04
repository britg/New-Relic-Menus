//
//  MainMenuController.m
//  New Relic Menus
//
//  Created by Brit Gardner on 6/4/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MainMenuController.h"
#import "APIHandler.h"
#import "NRMApplication.h"

@implementation MainMenuController

@synthesize menuView;
@synthesize throughputLabel;
@synthesize throughputUnits;
@synthesize responseTimeLabel;
@synthesize responseTimeUnits;
@synthesize errorRateLabel;
@synthesize errorRateUnits;
@synthesize apdexLabel;
@synthesize apdexUnits;

- (id)init
{
    self = [super init];
    if (self) {
        mainStatusItem = [[[NSStatusBar systemStatusBar] 
                           statusItemWithLength:NSVariableStatusItemLength] retain];
        [self listenForNotifications];
        [NSBundle loadNibNamed:@"MenuView" owner:self];
        DebugLog(@"menu view is %@", self.menuView);
    }
    
    return self;
}

- (void)dealloc
{
    [super dealloc];
}

- (void)addStatusItem {
    [self createMainMenu];
    [self coldStart];
}

- (void)createMainMenu {
    NSZone *menuZone = [NSMenu menuZone];
	menu = [[NSMenu allocWithZone:menuZone] init];
    
    /* Create the Application switcher */
    NSMenuItem *appSwitcherItem = [[NSMenuItem alloc] initWithTitle:@"Select Application" action:nil keyEquivalent:@"a"];
    appSubMenu = [[NSMenu allocWithZone:menuZone] init];
    
    [appSwitcherItem setSubmenu:appSubMenu];
    [appSwitcherItem setToolTip:@"Switch applications"];
    [appSwitcherItem setTarget:self];
    [menu addItem:appSwitcherItem];
    
    [menu addItem:[NSMenuItem separatorItem]];
    
    NSMenuItem *menuItem;
    
    menuItem = [menu addItemWithTitle:@"New Relic Dashboard" action:@selector(openNewRelicDashboard) keyEquivalent:@"o"];
    [menuItem setToolTip:@"Open Your New Relic Dashboard"];
    [menuItem setTarget:self];
    
    menuItem = [menu addItemWithTitle:@"Preferences" action:@selector(notifyPreferencesAction) keyEquivalent:@"p"];
    [menuItem setToolTip:@"Change your API Key"];
    [menuItem setTarget:self];
    
    menuItem = [menu addItemWithTitle:@"Quit" action:@selector(notifyQuit) keyEquivalent:@"q"];
    [menuItem setToolTip:@"Quit New Relic Menus"];
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
                                             selector:@selector(applicationsUpdated) 
                                                 name:APPLICATION_OBTAINED_NOTIFICATION
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(getPrimaryMetrics) 
                                                 name:APPLICATION_OBTAINED_NOTIFICATION
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(showMainMenu) 
                                                 name:STATS_VIEW_CLICKED_NOTIFICATION
                                               object:nil];
}

#pragma mark - States

- (void)ensureValidAPIKey {
    [[APIHandler sharedInstance] getPrimaryAccount];
}

- (void)setStateLoading {
    [mainStatusItem setTitle:@"Loading..."];
}

- (void)statsUpdated {
    DebugLog(@"Stats updated!");
    
    [self.throughputLabel setStringValue:[[[APIHandler sharedInstance] throughput] stringValue]];
    [self.responseTimeLabel setStringValue:[NSString stringWithFormat:@"%.0f", [[[APIHandler sharedInstance] responseTime] floatValue]]];
    [self.errorRateLabel setStringValue:[NSString stringWithFormat:@"%.02f", [[[APIHandler sharedInstance] errorPercent] floatValue]]];
    [self.apdexLabel setStringValue:[NSString stringWithFormat:@"%.02f", [[[APIHandler sharedInstance] apdex] floatValue]]];
    
    [self adjustLayout];
    
    [mainStatusItem setView:self.menuView];
}

- (void)adjustLayout {
    NSRect s;
    NSRect u;
    int offset;
    
    [self.throughputLabel sizeToFit];
    
    s = self.throughputLabel.frame;
    offset = s.size.width + s.origin.x - 4;
    u = self.throughputUnits.frame;
    
    [self.throughputUnits setFrame:NSMakeRect(offset, u.origin.y, u.size.width, u.size.height)];
    
    u = self.throughputUnits.frame;
    offset = u.size.width + u.origin.x;
    
    
    
    [self.responseTimeLabel sizeToFit];
    s = self.responseTimeLabel.frame;
    [self.responseTimeLabel setFrame:NSMakeRect(offset, s.origin.y, s.size.width, s.size.height)];
    
    s = self.responseTimeLabel.frame;
    offset = s.size.width + s.origin.x - 4;
    u = self.responseTimeUnits.frame;
    
    [self.responseTimeUnits setFrame:NSMakeRect(offset, u.origin.y, u.size.width, u.size.height)];
    
    u = self.responseTimeUnits.frame;
    offset = u.size.width + u.origin.x;
    
    
    [self.errorRateLabel sizeToFit];
    s = self.errorRateLabel.frame;
    [self.errorRateLabel setFrame:NSMakeRect(offset, s.origin.y, s.size.width, s.size.height)];
    
    s = self.errorRateLabel.frame;
    offset = s.size.width + s.origin.x - 4;
    u = self.errorRateUnits.frame;
    
    [self.errorRateUnits setFrame:NSMakeRect(offset, u.origin.y, u.size.width, u.size.height)];
    
    u = self.errorRateUnits.frame;
    offset = u.size.width + u.origin.x;
    
    
    [self.apdexLabel sizeToFit];
    s = self.apdexLabel.frame;
    [self.apdexLabel setFrame:NSMakeRect(offset, s.origin.y, s.size.width, s.size.height)];
    
    s = self.apdexLabel.frame;
    offset = s.size.width + s.origin.x - 4;
    u = self.apdexUnits.frame;
    
    [self.apdexUnits setFrame:NSMakeRect(offset, u.origin.y, u.size.width, u.size.height)];
    
    u = self.apdexUnits.frame;
    offset = u.size.width + u.origin.x;
    s = self.menuView.frame;
    
    [self.menuView setFrame:NSMakeRect(s.origin.x, s.origin.y, offset, s.size.height)];
}

- (void)applicationsUpdated {
    NSMenuItem *menuItem;
    NRMApplication *app;
    NSArray *apps = [[APIHandler sharedInstance] applications];
    for (int i = 0; i < apps.count; i++) {
        app = [apps objectAtIndex:i];
        menuItem = [appSubMenu addItemWithTitle:app.name 
                                         action:@selector(setCurrentApplication:) 
                                  keyEquivalent:[NSString stringWithFormat:@"%i", i]];
        [menuItem setToolTip:[NSString stringWithFormat:@"Set application to %@", app.name]];
        [menuItem setTarget:self];
        [menuItem setRepresentedObject:app];
    }
}

#pragma mark - Actions

- (void)coldStart {
    [self setStateLoading];
    [self ensureValidAPIKey];
    [self beginTimer];
}

- (void)refresh {
    [self getPrimaryMetrics];
}

- (void)beginTimer {
    timer = [NSTimer scheduledTimerWithTimeInterval: 60
											 target: self
										   selector: @selector(refresh)
										   userInfo: nil
											repeats: YES];
}

- (void)openNewRelicDashboard {
    [[NSWorkspace sharedWorkspace] openURL:[[APIHandler sharedInstance] dashboardURL]];
}

- (void)notifyPreferencesAction {
    [[NSNotificationCenter defaultCenter] 
     postNotification:[NSNotification notificationWithName:SHOW_PREFERENCES_NOTIFICATION object:nil]];
}

- (void)notifyQuit {
    [NSApp terminate:nil];
}

- (void)getPrimaryMetrics {
    DebugLog(@"Fetching primary metrics");
    [[APIHandler sharedInstance] getPrimaryMetrics];
}

- (void)showMainMenu {
    [mainStatusItem popUpStatusItemMenu:menu];
}

- (void)setCurrentApplication:(NSMenuItem *)selectedMenuItem {
    NRMApplication *app = [selectedMenuItem representedObject];
    [[APIHandler sharedInstance] setCurrentApplication:app.appId];
}

@end
