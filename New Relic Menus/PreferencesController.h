//
//  PreferencesController.h
//  New Relic Menus
//
//  Created by Brit Gardner on 6/4/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface PreferencesController : NSWindowController {
    IBOutlet NSTextField *apiKeyField;
    IBOutlet NSButton *confirmButton;
    IBOutlet NSProgressIndicator *progressIndicator;
}

@property (nonatomic, retain) IBOutlet NSTextField *apiKeyField;
@property (nonatomic, retain) IBOutlet NSButton *confirmButton;
@property (nonatomic, retain) IBOutlet NSProgressIndicator *progressIndicator;

- (IBAction)confirmButtonPressed:(id)sender;

- (void)checkValidAPIKey:(NSString *)apiKey;
- (void)apiKeyCheckDidReturn:(BOOL)valid;

@end
