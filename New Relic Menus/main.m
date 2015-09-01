//
//  main.m
//  New Relic Menus
//
//  Created by Brit Gardner on 6/4/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "NRMenusAppDelegate.h"

int main(int argc, char *argv[]) {
    @autoreleasepool {
        [NSApplication sharedApplication];
	
        NRMenusAppDelegate *menu = [[NRMenusAppDelegate alloc] init];
        [NSApp setDelegate:menu];
        [NSApp run];
	
    }
    return EXIT_SUCCESS;
}
