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
}

@property (nonatomic, retain) IBOutlet StatsView *menuView;
@property (nonatomic, retain) IBOutlet NSTextField *throughputLabel;
@property (nonatomic, retain) IBOutlet NSTextField *throughputUnits;
@property (nonatomic, retain) IBOutlet NSTextField *responseTimeLabel;
@property (nonatomic, retain) IBOutlet NSTextField *responseTimeUnits;
@property (nonatomic, retain) IBOutlet NSTextField *errorRateLabel;
@property (nonatomic, retain) IBOutlet NSTextField *errorRateUnits;
@property (nonatomic, retain) IBOutlet NSTextField *apdexLabel;
@property (nonatomic, retain) IBOutlet NSTextField *apdexUnits;

- (void)listenForNotifications;

- (void)addStatusItem;
- (void)createMainMenu;
- (void)ensureValidAPIKey;

// States

- (void)setStateLoading;

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

@end
