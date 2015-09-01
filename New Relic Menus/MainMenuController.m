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
#import "NRMAccount.h"
#import <KSReachability/KSReachability.h>

@interface MainMenuController()
@property (nonatomic, strong) KSReachability *reachability;
@end

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
        mainStatusItem = [[NSStatusBar systemStatusBar] 
                           statusItemWithLength:NSVariableStatusItemLength];
        [self listenForNotifications];
        [NSBundle loadNibNamed:@"MenuView" owner:self];
        DebugLog(@"menu view is %@", self.menuView);
    }
    
    return self;
}


- (void)addStatusItem {
    [self createMainMenu];
}

- (void)createMainMenu {
    NSZone *menuZone = [NSMenu menuZone];
	menu = [[NSMenu allocWithZone:menuZone] init];
    
    /* Create the Account switcher */
    NSMenuItem *accountSwitcherItem = [[NSMenuItem alloc] initWithTitle:@"Select Account" action:nil keyEquivalent:@"A"];
    accountSubMenu = [[NSMenu allocWithZone:menuZone] init];
    currentAccountMenuItem = [menu addItemWithTitle:@"Current Account" action:nil keyEquivalent:@""];
    [accountSwitcherItem setSubmenu:accountSubMenu];
    [accountSwitcherItem setToolTip:@"Switch accounts"];
    [accountSwitcherItem setTarget:self];
    [menu addItem:accountSwitcherItem];
    
    [menu addItem:[NSMenuItem separatorItem]];
    
    
    /* Create the Application switcher */
    NSMenuItem *appSwitcherItem = [[NSMenuItem alloc] initWithTitle:@"Select Application" action:nil keyEquivalent:@"a"];
    appSubMenu = [[NSMenu allocWithZone:menuZone] init];
    currentAppMenuItem = [menu addItemWithTitle:@"Current Application" action:nil keyEquivalent:@""];
    [appSwitcherItem setSubmenu:appSubMenu];
    [appSwitcherItem setToolTip:@"Switch applications"];
    [appSwitcherItem setTarget:self];
    [menu addItem:appSwitcherItem];
    
    [menu addItem:[NSMenuItem separatorItem]];
    
    /* Placeholders for stats */
    throughputMenuItem = [menu addItemWithTitle:@"Throughput: ..." action:nil keyEquivalent:@""];
    responseTimeMenuItem = [menu addItemWithTitle:@"Response Time: ..." action:nil keyEquivalent:@""];
    errorRateMenuItem = [menu addItemWithTitle:@"Errors: ..." action:nil keyEquivalent:@""];
    apdexMenuItem = [menu addItemWithTitle:@"Apdex: ..." action:nil keyEquivalent:@""];
    
    [menu addItem:[NSMenuItem separatorItem]];
    
    
    /* Create the miscellaneous actions */
    
    NSMenuItem *menuItem;
    
    menuItem = [menu addItemWithTitle:@"Dashboard" action:@selector(openNewRelicDashboard) keyEquivalent:@"o"];
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
                                             selector:@selector(accountsUpdated) 
                                                 name:ACCOUNT_OBTAINED_NOTIFICATION
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(showMainMenu) 
                                                 name:STATS_VIEW_CLICKED_NOTIFICATION
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(adjustLayout) 
                                                 name:DISPLAY_PREFERENCES_UPDATED
                                               object:nil];

    self.reachability = [KSReachability reachabilityToHost:RPM_DOMAIN];
    self.reachability.notificationName = @"kNewRelicReachabilityNotification";
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onReachabilityChanged:)
                                                 name:self.reachability.notificationName
                                               object:nil];
}

#pragma mark - States

- (void)ensureValidAPIKey {
    [[APIHandler sharedInstance] getPrimaryAccount];
}

- (void)setStateLoading {
    [mainStatusItem setTitle:@"Loading..."];
}

- (BOOL)stateForOption:(NSString *)option {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    DebugLog(@"default keys are %@: %@",option,  [defaults valueForKey:option]);
    
    if (![defaults valueForKey:option]) {
        return YES;
    }
    
    NSNumber *boolVal = [defaults valueForKey:option];
    return [boolVal boolValue];
}

- (void)statsUpdated {
    DebugLog(@"Stats updated!");
    NRMApplication *app = [[APIHandler sharedInstance] currentApplication];
    [currentAppMenuItem setTitle:app.name];
    [self.throughputLabel setStringValue:[[[APIHandler sharedInstance] throughput] stringValue]];
    [self.responseTimeLabel setStringValue:[NSString stringWithFormat:@"%.0f", [[[APIHandler sharedInstance] responseTime] floatValue]]];
    [self.errorRateLabel setStringValue:[NSString stringWithFormat:@"%.02f", [[[APIHandler sharedInstance] errorPercent] floatValue]]];
    [self.apdexLabel setStringValue:[NSString stringWithFormat:@"%.02f", [[[APIHandler sharedInstance] apdex] floatValue]]];
    
    [throughputMenuItem setTitle:[NSString stringWithFormat:@"Throughput: %@rpm",[[[APIHandler sharedInstance] throughput] stringValue]]];
    [responseTimeMenuItem setTitle:[NSString stringWithFormat:@"Response Time: %.0fms", [[[APIHandler sharedInstance] responseTime] floatValue]]];
    [errorRateMenuItem setTitle:[NSString stringWithFormat:@"Errors: %.02f%%", [[[APIHandler sharedInstance] errorPercent] floatValue]]];
    [apdexMenuItem setTitle:[NSString stringWithFormat:@"Apdex: %.02f", [[[APIHandler sharedInstance] apdex] floatValue]]];
    
    [self adjustLayout];
    
    [mainStatusItem setView:self.menuView];
}

- (void)adjustLayout {
    NSRect s;
    NSRect u;
    int offset = 26;
    
    BOOL throughputOn = [self stateForOption:@"throughput"];
    BOOL responseTimeOn = [self stateForOption:@"responseTime"];
    BOOL errorsOn = [self stateForOption:@"errors"];
    BOOL apdexOn = [self stateForOption:@"apdex"];
    
    DebugLog(@"Throughput on? %@", (throughputOn ? @"YES" : @"OFF"));
    DebugLog(@"responseTimeOn on? %@", (responseTimeOn ? @"YES" : @"OFF"));
    DebugLog(@"errorsOn on? %@", (errorsOn ? @"YES" : @"OFF"));
    DebugLog(@"apdexOn on? %@", (apdexOn ? @"YES" : @"OFF"));
    
    self.throughputLabel.hidden = YES;
    self.throughputUnits.hidden = YES;
    self.responseTimeLabel.hidden = YES;
    self.responseTimeUnits.hidden = YES;
    self.errorRateLabel.hidden = YES;
    self.errorRateUnits.hidden = YES;
    self.apdexLabel.hidden = YES;
    self.apdexLabel.hidden = YES;
    
    
    if (throughputOn) {
        self.throughputLabel.hidden = NO;
        self.throughputUnits.hidden = NO;
        
        [self.throughputLabel sizeToFit];
        s = self.throughputLabel.frame;
        offset = s.size.width + s.origin.x - 4;
        u = self.throughputUnits.frame;
        [self.throughputUnits setFrame:NSMakeRect(offset, u.origin.y, u.size.width, u.size.height)];
        u = self.throughputUnits.frame;
        offset = u.size.width + u.origin.x;
    }
    
    if (responseTimeOn) {
        self.responseTimeLabel.hidden = NO;
        self.responseTimeUnits.hidden = NO;
        
        [self.responseTimeLabel sizeToFit];
        s = self.responseTimeLabel.frame;
        [self.responseTimeLabel setFrame:NSMakeRect(offset, s.origin.y, s.size.width, s.size.height)];
        s = self.responseTimeLabel.frame;
        offset = s.size.width + s.origin.x - 4;
        u = self.responseTimeUnits.frame;
        [self.responseTimeUnits setFrame:NSMakeRect(offset, u.origin.y, u.size.width, u.size.height)];
        u = self.responseTimeUnits.frame;
        offset = u.size.width + u.origin.x;
    }
    
    if (errorsOn) {
        self.errorRateLabel.hidden = NO;
        self.errorRateUnits.hidden = NO;
        
        [self.errorRateLabel sizeToFit];
        s = self.errorRateLabel.frame;
        [self.errorRateLabel setFrame:NSMakeRect(offset, s.origin.y, s.size.width, s.size.height)];
        s = self.errorRateLabel.frame;
        offset = s.size.width + s.origin.x - 4;
        u = self.errorRateUnits.frame;
        [self.errorRateUnits setFrame:NSMakeRect(offset, u.origin.y, u.size.width, u.size.height)];
        u = self.errorRateUnits.frame;
        offset = u.size.width + u.origin.x;
    }
    
    if (apdexOn) {
        self.apdexLabel.hidden = NO;
        self.apdexUnits.hidden = NO;
        
        [self.apdexLabel sizeToFit];
        s = self.apdexLabel.frame;
        [self.apdexLabel setFrame:NSMakeRect(offset, s.origin.y, s.size.width, s.size.height)];
        s = self.apdexLabel.frame;
        offset = s.size.width + s.origin.x - 4;
        u = self.apdexUnits.frame;
        [self.apdexUnits setFrame:NSMakeRect(offset, u.origin.y, u.size.width, u.size.height)];
        u = self.apdexUnits.frame;
        offset = u.size.width + u.origin.x;
    }
    
    s = self.menuView.frame;
    [self.menuView setFrame:NSMakeRect(s.origin.x, s.origin.y, offset, s.size.height)];
}

- (void)applicationsUpdated {
    NSMenuItem *menuItem;
    NRMApplication *app;
    NSArray *apps = [[APIHandler sharedInstance] applications];
    [appSubMenu removeAllItems];
    

    for (int i = 0; i < apps.count; i++) {
        app = [apps objectAtIndex:i];
        menuItem = [appSubMenu addItemWithTitle:app.name 
                                         action:@selector(setCurrentApplication:) 
                                  keyEquivalent:[NSString stringWithFormat:@""]];
        [menuItem setToolTip:[NSString stringWithFormat:@"Set application to %@", app.name]];
        [menuItem setTarget:self];
        [menuItem setRepresentedObject:app];
    }
    
    
    NRMAccount *currentAccount = [[APIHandler sharedInstance] currentAccount];
    [currentAccountMenuItem setTitle:currentAccount.name];
}

- (void)accountsUpdated {
    NSMenuItem *menuItem;
    NRMAccount *account;
    NSArray *accounts = [[APIHandler sharedInstance] accounts];
    for (int i = 0; i < accounts.count; i++) {
        account = [accounts objectAtIndex:i];
        menuItem = [accountSubMenu addItemWithTitle:account.name 
                                         action:@selector(setCurrentAccount:) 
                                  keyEquivalent:[NSString stringWithFormat:@""]];
        [menuItem setToolTip:[NSString stringWithFormat:@"Set account to %@", account.name]];
        [menuItem setTarget:self];
        [menuItem setRepresentedObject:account];
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
    [timer invalidate];
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
    [[APIHandler sharedInstance] setApplication:app.appId];
}

- (void)setCurrentAccount:(NSMenuItem *)selectedMenuItem {
    NRMAccount *account = [selectedMenuItem representedObject];
    [[APIHandler sharedInstance] setAccount:account.accountId];
}

- (void)onReachabilityChanged:(NSNotification *)notification {
    KSReachability* reachability = (KSReachability*)notification.object;
    if (reachability.reachable) {
        [self coldStart];
    } else {
        [mainStatusItem setView:nil];
        [self setStateLoading];
    }
}

@end
