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

- (void)dealloc
{
    [apiKeyField release];
    [confirmButton release];
    [progressIndicator release];
    [hiddenMenu release];
    [super dealloc];
}

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

@end
