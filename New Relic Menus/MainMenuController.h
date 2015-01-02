//
//  MainMenuController.h
//  New Relic Menus
//
//  Created by Brit Gardner on 6/4/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "StatsView.h"

@interface MainMenuController : NSObject {
    NSStatusItem *mainStatusItem;
    NSMenu *menu;
    NSMenu *appSubMenu;
    NSMenu *accountSubMenu;
    NSTimer *timer;
    
    IBOutlet StatsView *menuView;
    IBOutlet NSTextField *throughputLabel;
    IBOutlet NSTextField *throughputUnits;
    IBOutlet NSTextField *responseTimeLabel;
    IBOutlet NSTextField *responseTimeUnits;
    IBOutlet NSTextField *errorRateLabel;
    IBOutlet NSTextField *errorRateUnits;
    IBOutlet NSTextField *apdexLabel;
    IBOutlet NSTextField *apdexUnits;
    
    NSMenuItem *currentAppMenuItem;
    NSMenuItem *currentAccountMenuItem;
    
    NSMenuItem *throughputMenuItem;
    NSMenuItem *responseTimeMenuItem;
    NSMenuItem *errorRateMenuItem;
    NSMenuItem *apdexMenuItem;
}

@property (nonatomic, strong) IBOutlet StatsView *menuView;
@property (nonatomic, strong) IBOutlet NSTextField *throughputLabel;
@property (nonatomic, strong) IBOutlet NSTextField *throughputUnits;
@property (nonatomic, strong) IBOutlet NSTextField *responseTimeLabel;
@property (nonatomic, strong) IBOutlet NSTextField *responseTimeUnits;
@property (nonatomic, strong) IBOutlet NSTextField *errorRateLabel;
@property (nonatomic, strong) IBOutlet NSTextField *errorRateUnits;
@property (nonatomic, strong) IBOutlet NSTextField *apdexLabel;
@property (nonatomic, strong) IBOutlet NSTextField *apdexUnits;

- (void)listenForNotifications;

- (void)addStatusItem;
- (void)createMainMenu;
- (void)ensureValidAPIKey;

// States

- (void)setStateLoading;
- (BOOL)stateForOption:(NSString *)option;

// Actions
- (void)coldStart;
- (void)refresh;
- (void)beginTimer;
- (void)openNewRelicDashboard;
- (void)notifyPreferencesAction;
- (void)getPrimaryMetrics;
- (void)showMainMenu;
- (void)notifyQuit;
- (void)adjustLayout;
- (void)setCurrentApplication:(NSMenuItem *)selectedMenuItem;
- (void)setCurrentAccount:(NSMenuItem *)selectedMenuItem;
@end
