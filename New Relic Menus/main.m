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
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    [NSApplication sharedApplication];
	
    NRMenusAppDelegate *menu = [[NRMenusAppDelegate alloc] init];
    [NSApp setDelegate:menu];
    [NSApp run];
	
    [pool release];
    return EXIT_SUCCESS;
}
