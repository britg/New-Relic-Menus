//
//  PreferencesController.m
//  New Relic Menus
//
//  Created by Brit Gardner on 6/4/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "PreferencesController.h"


@implementation PreferencesController

@synthesize apiKeyField;
@synthesize confirmButton;
@synthesize progressIndicator;

- (void)dealloc
{
    [apiKeyField release];
    [confirmButton release];
    [progressIndicator release];
    [super dealloc];
}

- (void)showWindow:(id)sender {
    DebugLog(@"Show window called");
    
    if (![self window]) {
        [NSBundle loadNibNamed:@"PreferencesWindow" owner:self];
        [[self window] center];
    }
    [NSApp activateIgnoringOtherApps:YES];
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
    DebugLog(@"Confirm button pressed");
    
    // Use API to determine if this is a valid API Key
    [self checkValidAPIKey:[self.apiKeyField value]];
    
}

#pragma mark - API Key Check

- (void)checkValidAPIKey:(NSString *)apiKey {
    [self.progressIndicator startAnimation:self];
}

- (void)apiKeyCheckDidReturn:(BOOL)valid {
    [self.progressIndicator stopAnimation:self];
}

@end
