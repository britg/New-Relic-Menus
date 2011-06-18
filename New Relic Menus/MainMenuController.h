//
//  MainMenuController.h
//  New Relic Menus
//
//  Created by Brit Gardner on 6/4/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface MainMenuController : NSObject {
    NSStatusItem *mainStatusItem;
    NSMenu *menu;
    NSTimer *timer;
}

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


@end
