//
//  PreferencesController.h
//  New Relic Menus
//
//  Created by Brit Gardner on 6/4/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface PreferencesController : NSWindowController <NSToolbarDelegate> {
    
    IBOutlet NSTextField *apiKeyLabel;
    IBOutlet NSTextField *apiKeyField;
    IBOutlet NSButton *confirmButton;
    IBOutlet NSProgressIndicator *progressIndicator;
    
    IBOutlet NSMenu *hiddenMenu;
    
    NSString *currentAPIKey;
    
    IBOutlet NSToolbar *toolbar;
    IBOutlet NSTabView *tabView;
    
    IBOutlet NSButton *throughputButton;
    IBOutlet NSButton *responseTimeButton;
    IBOutlet NSButton *errorButton;
    IBOutlet NSButton *apdexButton;
    IBOutlet NSButton *startupButton;
    
}

@property (nonatomic, retain) IBOutlet NSTextField *apiKeyLabel;
@property (nonatomic, retain) IBOutlet NSTextField *apiKeyField;
@property (nonatomic, retain) IBOutlet NSButton *confirmButton;
@property (nonatomic, retain) IBOutlet NSProgressIndicator *progressIndicator;

@property (nonatomic, retain) IBOutlet NSMenu *hiddenMenu;

@property (nonatomic, retain) IBOutlet NSToolbar *toolbar;
@property (nonatomic, retain) IBOutlet NSTabView *tabView;

@property (nonatomic, retain) IBOutlet NSButton *throughputButton;
@property (nonatomic, retain) IBOutlet NSButton *responseTimeButton;
@property (nonatomic, retain) IBOutlet NSButton *errorButton;
@property (nonatomic, retain) IBOutlet NSButton *apdexButton;
@property (nonatomic, retain) IBOutlet NSButton *startupButton;

- (IBAction)confirmButtonPressed:(id)sender;

- (void)checkValidAPIKey:(NSString *)apiKey;
- (void)apiKeyCheckDidReturn:(NSNumber *)boolAsNumber;

- (void)saveAPIKey:(NSString *)apiKey;
- (void)notifyInvalidAPIKey;

- (IBAction)showAccountPreferences:(id)sender;
- (IBAction)showDisplayPreferences:(id)sender;

- (IBAction)toggleThroughput:(id)sender;
- (IBAction)toggleResponseTime:(id)sender;
- (IBAction)toggleErrors:(id)sender;
- (IBAction)toggleApdex:(id)sender;
- (IBAction)toggleStartup:(id)sender;

- (void)rememberOption:(NSString *)option state:(BOOL)state;
- (void)setDefaultStatesForOptions;
- (BOOL)stateForOption:(NSString *)option;

- (LSSharedFileListItemRef)itemRefInLoginItems;
- (BOOL)isLaunchAtStartup;

@end
