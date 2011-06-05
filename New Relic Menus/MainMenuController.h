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
}

- (void)addStatusItem;
- (void)createMainMenu;

- (void)refresh;
- (void)notifyPreferencesAction;


@end
