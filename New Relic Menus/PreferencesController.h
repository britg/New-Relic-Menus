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

@property (nonatomic, strong) IBOutlet NSTextField *apiKeyLabel;
@property (nonatomic, strong) IBOutlet NSTextField *apiKeyField;
@property (nonatomic, strong) IBOutlet NSButton *confirmButton;
@property (nonatomic, strong) IBOutlet NSProgressIndicator *progressIndicator;

@property (nonatomic, strong) IBOutlet NSMenu *hiddenMenu;

@property (nonatomic, strong) IBOutlet NSToolbar *toolbar;
@property (nonatomic, strong) IBOutlet NSTabView *tabView;

@property (nonatomic, strong) IBOutlet NSButton *throughputButton;
@property (nonatomic, strong) IBOutlet NSButton *responseTimeButton;
@property (nonatomic, strong) IBOutlet NSButton *errorButton;
@property (nonatomic, strong) IBOutlet NSButton *apdexButton;
@property (nonatomic, strong) IBOutlet NSButton *startupButton;

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
