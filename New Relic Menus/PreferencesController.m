//
//  PreferencesController.m
//  New Relic Menus
//
//  Created by Brit Gardner on 6/4/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "NRMenusAppDelegate.h"
#import "PreferencesController.h"
#import "APIHandler.h"
#import "AGKeychain.h"

@implementation PreferencesController

@synthesize apiKeyLabel;
@synthesize apiKeyField;
@synthesize confirmButton;
@synthesize progressIndicator;
@synthesize hiddenMenu;
@synthesize toolbar;
@synthesize tabView;
@synthesize throughputButton;
@synthesize responseTimeButton;
@synthesize errorButton;
@synthesize apdexButton;
@synthesize startupButton;


- (void)showWindow:(id)sender {
    DebugLog(@"Show window called");
    
    if (![self window]) {
        [NSBundle loadNibNamed:@"PreferencesWindow" owner:self];
        [NSApp setMainMenu:[self hiddenMenu]];
        [[self window] center];
    }
    [NSApp activateIgnoringOtherApps:YES];
    [self.apiKeyField setStringValue:[[APIHandler sharedInstance] storedAPIKey]];
    [[self window] setTitle:@"New Relic Preferences"];
    [[self window] makeKeyAndOrderFront:self];
    //[self.toolbar setSelectedItemIdentifier:@"AccountPreferences"];
    //[self showAccountPreferences:self];
    [self setDefaultStatesForOptions];
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    DebugLog(@"Window Did Load %@", self.window);
}

#pragma mark - Actions

- (IBAction)confirmButtonPressed:(id)sender {
    DebugLog(@"Confirm button pressed with value %@", [self.apiKeyField stringValue]);
    
    // Use API to determine if this is a valid API Key
    [self checkValidAPIKey:[self.apiKeyField stringValue]];
    
}

#pragma mark - API Key Check

- (void)checkValidAPIKey:(NSString *)apiKey {
    currentAPIKey = apiKey;
    
    [self.progressIndicator startAnimation:self];
    [[APIHandler sharedInstance] checkAPIKey:apiKey delegate:self 
                                    callback:@selector(apiKeyCheckDidReturn:)];
}

- (void)apiKeyCheckDidReturn:(NSNumber *)boolAsNumber {
    BOOL valid = [boolAsNumber boolValue];
    DebugLog(@"api key check returned %@", (valid ? @"valid" : @"not valid"));
    [self.progressIndicator stopAnimation:self];
    
    if (valid) {
        [self saveAPIKey:currentAPIKey];
        [[self window] close];
        [[NSNotificationCenter defaultCenter] 
         postNotification:[NSNotification notificationWithName:API_KEY_VALIDATED_NOTIFICATION object:nil]];
    } else {
        [self notifyInvalidAPIKey];
    }
}

- (void)saveAPIKey:(NSString *)apiKey {
    [self.apiKeyLabel setStringValue:@"Enter your New Relic API Key"];
    [self.apiKeyLabel setTextColor:[NSColor blackColor]];
    [[APIHandler sharedInstance] saveAPIKey:apiKey];
}

- (void)notifyInvalidAPIKey {
    [self.apiKeyLabel setStringValue:@"The API Key you entered is invalid. Please try again."];
    [self.apiKeyLabel setTextColor:[NSColor redColor]];
}

#pragma mark - NSToolbarDelegate

- (NSArray *)toolbarSelectableItemIdentifiers: (NSToolbar *)toolbar;
{
    DebugLog(@"Determining selectable item identifiers!");
    // Optional delegate method: Returns the identifiers of the subset of
    // toolbar items that are selectable. In our case, all of them
    return [NSArray arrayWithObjects:@"AccountPreferences",
            @"DisplayPreferences", nil];
}

- (IBAction)showAccountPreferences:(id)sender {
    DebugLog(@"Showing display preferences");
    [self.tabView selectTabViewItem:[[self.tabView tabViewItems] objectAtIndex:0]];
}

- (IBAction)showDisplayPreferences:(id)sender {
    DebugLog(@"Showing display preferences");
    [self.tabView selectTabViewItem:[[self.tabView tabViewItems] objectAtIndex:1]];
    
    [self setDefaultStatesForOptions];
}

#pragma mark - Options

- (IBAction)toggleThroughput:(id)sender {
    BOOL on = ([(NSButton *)sender state] == NSOnState);
    DebugLog(@"Toggling throughput %@", on ? @"ON" : @"OFF");
    [self rememberOption:@"throughput" state:on];
    
}

- (IBAction)toggleResponseTime:(id)sender {
    BOOL on = ([(NSButton *)sender state] == NSOnState);
    DebugLog(@"Toggling response time %@", on ? @"ON" : @"OFF");
    [self rememberOption:@"responseTime" state:on];
}

- (IBAction)toggleErrors:(id)sender {
    BOOL on = ([(NSButton *)sender state] == NSOnState);
    DebugLog(@"Toggling errors %@", on ? @"ON" : @"OFF");
    [self rememberOption:@"errors" state:on];
}

- (IBAction)toggleApdex:(id)sender {
    BOOL on = ([(NSButton *)sender state] == NSOnState);
    DebugLog(@"Toggling apdex %@", on ? @"ON" : @"OFF");
    [self rememberOption:@"apdex" state:on];
}

- (IBAction)toggleStartup:(id)sender {
    BOOL on = ([(NSButton *)sender state] == NSOnState);
    DebugLog(@"Toggling startup %@", on ? @"ON" : @"OFF");
    [self rememberOption:@"startup" state:on];
    
    // Get the LoginItems list.
    LSSharedFileListRef loginItemsRef = LSSharedFileListCreate(NULL, kLSSharedFileListSessionLoginItems, NULL);
    if (loginItemsRef == nil) return;
    if (on) {
        // Add the app to the LoginItems list.
        CFURLRef appUrl = (__bridge CFURLRef)[NSURL fileURLWithPath:[[NSBundle mainBundle] bundlePath]];
        LSSharedFileListItemRef itemRef = LSSharedFileListInsertItemURL(loginItemsRef, kLSSharedFileListItemLast, NULL, NULL, appUrl, NULL, NULL);
        if (itemRef) CFRelease(itemRef);
    }
    else {
        // Remove the app from the LoginItems list.
        LSSharedFileListItemRef itemRef = [self itemRefInLoginItems];
        if (itemRef) {
            LSSharedFileListItemRemove(loginItemsRef,itemRef);
            CFRelease(itemRef);
        }
    }
    CFRelease(loginItemsRef);
}

- (void)setDefaultStatesForOptions {
    DebugLog(@"Setting default states for options");
    NSArray *options = [NSArray arrayWithObjects:self.throughputButton, 
                                                 self.responseTimeButton, 
                                                 self.errorButton, 
                                                 self.apdexButton,
                                                 self.startupButton, nil];
    NSArray *optionNames = [NSArray arrayWithObjects:@"throughput",
                                                     @"responseTime",
                                                     @"errors",
                                                     @"apdex",
                                                     @"startup", nil];

    for (int i = 0; i < options.count; i++) {
        NSButton *opt = [options objectAtIndex:i];
        NSString *optName = [optionNames objectAtIndex:i];
        int state = [[NSNumber numberWithBool:[self stateForOption:optName]] intValue];
        DebugLog(@"Setting default state for %@ to %@", optName, (state ? @"ON" : @"OFF"));
        [opt setState:state];
    }
}

- (BOOL)stateForOption:(NSString *)option {
    if ([option isEqualToString:@"startup"]) {
        return [self isLaunchAtStartup];
    }
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    if (![defaults valueForKey:option]) {
        return YES;
    }
    
    NSNumber *boolVal = [defaults valueForKey:option];
    return [boolVal boolValue];
}

- (void)rememberOption:(NSString *)option state:(BOOL)state {
    DebugLog(@"Remembering option %@ state %@", option, (state ? @"ON" : @"OFF"));
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSNumber *boolVal = [NSNumber numberWithBool:state];
    [defaults setValue:boolVal forKey:option];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:DISPLAY_PREFERENCES_UPDATED object:nil];
}

#pragma mark - Launch on startup

// MIT license
- (BOOL)isLaunchAtStartup {
    // See if the app is currently in LoginItems.
    LSSharedFileListItemRef itemRef = [self itemRefInLoginItems];
    // Store away that boolean.
    BOOL isInList = itemRef != nil;
    // Release the reference if it exists.
    if (itemRef != nil) CFRelease(itemRef);
    
    return isInList;
}

- (LSSharedFileListItemRef)itemRefInLoginItems {
    LSSharedFileListItemRef itemRef = nil;
    CFURLRef *itemUrl = NULL;
    
    // Get the app's URL.
    NSURL *appUrl = [NSURL fileURLWithPath:[[NSBundle mainBundle] bundlePath]];
    // Get the LoginItems list.
    LSSharedFileListRef loginItemsRef = LSSharedFileListCreate(NULL, kLSSharedFileListSessionLoginItems, NULL);
    if (loginItemsRef == nil) return nil;
    // Iterate over the LoginItems.
    NSArray *loginItems = (NSArray *)CFBridgingRelease(LSSharedFileListCopySnapshot(loginItemsRef, nil));
    for (int currentIndex = 0; currentIndex < [loginItems count]; currentIndex++) {
        // Get the current LoginItem and resolve its URL.
        LSSharedFileListItemRef currentItemRef = (__bridge LSSharedFileListItemRef)[loginItems objectAtIndex:currentIndex];
        if (LSSharedFileListItemResolve(currentItemRef, 0, itemUrl, NULL) == noErr) {
            // Compare the URLs for the current LoginItem and the app.
            if (itemUrl != NULL && [(__bridge NSURL *)*itemUrl isEqual:appUrl]) {
                // Save the LoginItem reference.
                itemRef = currentItemRef;
            }
        }
    }
    // Retain the LoginItem reference.
    if (itemRef != nil) CFRetain(itemRef);
    // Release the LoginItems lists.
    CFRelease(loginItemsRef);
    
    return itemRef;
}

@end
