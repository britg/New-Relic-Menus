//
//  APIHandler.m
//  New Relic Menus
//
//  Created by Brit Gardner on 6/5/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "APIHandler.h"
#import "SynthesizeSingleton.h"
#import "ASIHTTPRequest.h"
#import "AGKeychain.h"
#import "NRMApplication.h"

@implementation APIHandler
SYNTHESIZE_SINGLETON_FOR_CLASS(APIHandler);

@synthesize accounts;
@synthesize currentAccount;
@synthesize currentAPIKey;
@synthesize currentApplication;
@synthesize apdex;
@synthesize errorPercent;
@synthesize throughput;
@synthesize cpu;
@synthesize responseTime;
@synthesize applications;

#pragma mark - API Key

- (void)saveAPIKey:(NSString *)apiKey {
    if([AGKeychain checkForExistanceOfKeychainItem:kKeyString withItemKind:kKeyString forUsername:kKeyString]) {
		[AGKeychain modifyKeychainItem:kKeyString withItemKind:kKeyString forUsername:kKeyString withNewPassword:apiKey];
	} else {
		[AGKeychain addKeychainItem:kKeyString	withItemKind:kKeyString forUsername:kKeyString withPassword:apiKey];
	}
    currentAPIKey = apiKey;
}

- (NSString *)storedAPIKey {
    return currentAPIKey = [NSString stringWithString:[AGKeychain getPasswordFromKeychainItem:kKeyString
                                                                 withItemKind:kKeyString 
                                                                  forUsername:kKeyString]];
}

- (void)checkAPIKey:(NSString *)apiKey delegate:(id)delegate
                                       callback:(SEL)callback {
    
    DebugLog(@"Checking API key with %@", apiKey);
    
    NSString *checkAPIPath = [NSString stringWithFormat:@"/accounts.xml"];
    NSURL *checkAPIURL = [NSURL URLWithString:checkAPIPath relativeToURL:RPM_URL];
    
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:checkAPIURL];
    [request setDelegate:self];
    [request addRequestHeader:@"x-api-key" value:apiKey];
    
    [request setCompletionBlock:^{
        int status = [request responseStatusCode];

        BOOL valid = (status == 200);
        if ([delegate respondsToSelector:callback])
            [delegate performSelector:callback withObject:[NSNumber numberWithBool:valid]];
        
        NSData *responseData = [request responseData];
        [self parsePrimaryAccount:responseData];
    }];
    
    [request setFailedBlock:^{
        if ([delegate respondsToSelector:callback])
            [delegate performSelector:callback withObject:[NSNumber numberWithBool:NO]];
    }];
    
    [request startAsynchronous];
}

#pragma mark - Account & Application

- (NSURL *)dashboardURL {
    NSString *url = [NSString stringWithFormat:@"%@/accounts/%i/applications/%i", 
                     DASHBOARD_DOMAIN, primaryAccountId, primaryApplicationId];
    return [NSURL URLWithString:url];
}

- (void)getPrimaryAccount {
    
    NSString *accountsPath = [NSString stringWithFormat:@"/accounts.xml"];
    NSURL *accountsURL = [NSURL URLWithString:accountsPath relativeToURL:RPM_URL];
    
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:accountsURL];
    [request setDelegate:self];
    [request addRequestHeader:@"x-api-key" value:[self storedAPIKey]];
    
    [request setCompletionBlock:^{
        NSData *responseData = [request responseData];
        [self parsePrimaryAccount:responseData];
    }];
    
    [request setFailedBlock:^{
        [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:ACCOUNT_FAILED_NOTIFICATION object:nil]];
    }];
    
    [request startAsynchronous];
}

- (void)parsePrimaryAccount:(NSData *)data {
    NSError *error;
    NSXMLDocument *doc = [[NSXMLDocument alloc] initWithData:data options:0 error:&error];
    
    if (!doc) {
        DebugLog(@"There was an error parsing the data! %@", data);
        return;
    }
    
    //DebugLog(@"XML document for accounts %@", doc);
    
    NSArray *accountNodes = [doc nodesForXPath:@"//account" error:&error];
    NSXMLElement *firstAccountNode;
    NRMAccount *account;
    self.accounts = [NSMutableArray array];
    
    for (int i = 0; i < accountNodes.count; i++) {
        account = [[NRMAccount alloc] init];
        
        firstAccountNode = [accountNodes objectAtIndex:i];
        DebugLog(@"The first account node is %@", firstAccountNode);
        
        for (int j = 0; j < [[firstAccountNode children] count]; j++) {    
            NSXMLElement *attribute = [[firstAccountNode children] objectAtIndex:j];
            //DebugLog(@"The current attribute is %@", attribute);
            if ([@"id" compare:[attribute name] options:NSCaseInsensitiveSearch] == NSOrderedSame) {
                if (i == 0) {
                    primaryAccountId = [[attribute stringValue] intValue];
                }
                account.accountId = [[attribute stringValue] intValue];
            }
            
            if ([@"name" compare:[attribute name] options:NSCaseInsensitiveSearch] == NSOrderedSame) {
                account.name = [attribute stringValue];
            }
        }
        
        [self.accounts addObject:account];
    }
    
    DebugLog(@"The primary account id is %i", primaryAccountId);
    
    if (primaryAccountId) {
        [self setAccount:primaryAccountId];
        [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:ACCOUNT_OBTAINED_NOTIFICATION object:nil]];
    } else {
        [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:ACCOUNT_FAILED_NOTIFICATION object:nil]];
    }
    
    
}

- (void)getPrimaryApplication {
    NSString *appPath = [NSString stringWithFormat:@"/accounts/%i/applications.xml", primaryAccountId];
    NSURL *appURL = [NSURL URLWithString:appPath relativeToURL:RPM_URL];
    DebugLog(@"App url is %@", appURL);
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:appURL];
    [request setDelegate:self];
    [request addRequestHeader:@"x-api-key" value:[self storedAPIKey]];
    
    [request setCompletionBlock:^{
        NSData *responseData = [request responseData];
        [self parsePrimaryApplication:responseData];
    }];
    
    [request setFailedBlock:^{
        [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:APPLICATION_FAILED_NOTIFICATION object:nil]];
    }];
    
    [request startAsynchronous];
}

- (void)parsePrimaryApplication:(NSData *)data {
    NSError *error;
    NSXMLDocument *doc = [[NSXMLDocument alloc] initWithData:data options:0 error:&error];
    
    if (!doc) {
        DebugLog(@"There was an error parsing the data! %@", data);
        return;
    }
    BOOL hasStoredAppId = self.storedPreferredAppId != nil;

    //DebugLog(@"Application response XML is %@", doc);
    
    NSArray *appNodes = [doc nodesForXPath:@"//application" error:&error];
    NSXMLElement *firstAppNode;
    self.applications = [NSMutableArray array];
    NRMApplication *app;
    
    for (int i = 0; i < appNodes.count; i++) {
        app = [[NRMApplication alloc] init];
        firstAppNode = [appNodes objectAtIndex:i];
        DebugLog(@"The first account node is %@", firstAppNode);
        for (int j = 0; j < [[firstAppNode children] count]; j++) {
            NSXMLElement *attribute = [[firstAppNode children] objectAtIndex:j];
            DebugLog(@"The current attribute is %@", attribute);
            if ([@"id" compare:[attribute name] options:NSCaseInsensitiveSearch] == NSOrderedSame) {
                if (!hasStoredAppId && i == 0) {
                    primaryApplicationId = [[attribute stringValue] intValue];
                }
                
                app.appId = [[attribute stringValue] intValue];

                if (app.appId == self.storedPreferredAppId.integerValue) {
                    primaryApplicationId = app.appId;
                }
            }
            
            if ([@"name" compare:[attribute name] options:NSCaseInsensitiveSearch] == NSOrderedSame) {
                app.name = [attribute stringValue];
            }
        }
        
        
        [self.applications addObject:app];
    }
    if (primaryApplicationId == 0) {
        primaryApplicationId = [self.applications.firstObject appId];
    }
    
    DebugLog(@"Primary application id is %i", primaryApplicationId);
    DebugLog(@"Applications are %@", self.applications);
    
    NSString *note = (primaryApplicationId ? APPLICATION_OBTAINED_NOTIFICATION : APPLICATION_FAILED_NOTIFICATION);
    
    [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:note object:nil]];
    [self setApplication:primaryApplicationId];
}

#pragma mark - Metrics

- (void)getPrimaryMetrics {
    NSString *statsPath = [NSString stringWithFormat:@"/accounts/%i/applications/%i/threshold_values.xml", primaryAccountId, primaryApplicationId];
    NSURL *statsURL = [NSURL URLWithString:statsPath relativeToURL:RPM_URL];
    
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:statsURL];
    [request setDelegate:self];
    [request addRequestHeader:@"x-api-key" value:[self storedAPIKey]];
    
    [request setCompletionBlock:^{
        NSData *responseData = [request responseData];
        [self parsePrimaryMetrics:responseData];
    }];
    
    [request setFailedBlock:^{
        DebugLog(@"primary metrics failed!");
        [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:APPLICATION_FAILED_NOTIFICATION object:nil]];
    }];
    
    [request startAsynchronous];
}

- (void)parsePrimaryMetrics:(NSData *)data {
    NSError *error;
    NSXMLDocument *doc = [[NSXMLDocument alloc] initWithData:data options:0 error:&error];
    
    if (!doc) {
        DebugLog(@"There was an error parsing the data! %@", data);
        return;
    }
    
    //DebugLog(@"Metrics response XML is %@", doc);
    
    NSArray *statNodes = [doc nodesForXPath:@"//threshold_value" error:&error];
    for (int i = 0; i < statNodes.count; i++) {
        
        NSXMLElement *stat = [statNodes objectAtIndex:i];
        DebugLog(@"The current attribute is %@", stat);
        
        if ([@"Apdex" compare:[[stat attributeForName:@"name"] stringValue] options:NSCaseInsensitiveSearch] == NSOrderedSame) {
            self.apdex = [NSNumber numberWithFloat:[[[stat attributeForName:@"metric_value"] stringValue] floatValue]];
            DebugLog(@"Apdex is %@", self.apdex);
        }
        
        if ([@"Error Rate" compare:[[stat attributeForName:@"name"] stringValue] options:NSCaseInsensitiveSearch] == NSOrderedSame) {
            self.errorPercent = [NSNumber numberWithFloat:[[[stat attributeForName:@"metric_value"] stringValue] floatValue]];
            DebugLog(@"Error Rate is %@", self.errorPercent);
        }
        
        if ([@"Throughput" compare:[[stat attributeForName:@"name"] stringValue] options:NSCaseInsensitiveSearch] == NSOrderedSame) {
            self.throughput = [NSNumber numberWithFloat:[[[stat attributeForName:@"metric_value"] stringValue] integerValue]];
            DebugLog(@"Throughput is %@", self.throughput);
        }
        
        if ([@"Response Time" compare:[[stat attributeForName:@"name"] stringValue] options:NSCaseInsensitiveSearch] == NSOrderedSame) {
            self.responseTime = [NSNumber numberWithFloat:[[[stat attributeForName:@"metric_value"] stringValue] floatValue]];
            DebugLog(@"Response time is %@", self.responseTime);
        }
    }
    
    [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:METRICS_OBTAINED_NOTIFICATION object:nil]];
}

- (void)setAccount:(int)accountId {
    primaryAccountId = accountId;
    for (int i = 0; i < accounts.count; i++) {
        NRMAccount *account = [accounts objectAtIndex:i];
        if (accountId == account.accountId) {
            self.currentAccount = account;
            break;
        }
    }
    [self getPrimaryApplication];
}

- (void)setApplication:(int)appId {
    primaryApplicationId = appId;
    for (int i = 0; i < applications.count; i++) {
        NRMApplication *app = [applications objectAtIndex:i];
        if (appId == app.appId) {
            self.currentApplication = app;
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            [defaults setObject:@(app.appId)
                         forKey:kKeyPreferredAppId];
            [defaults synchronize];
            break;
        }
    }
    [self getPrimaryMetrics];
}

- (NSNumber *)storedPreferredAppId {
    return [[NSUserDefaults standardUserDefaults] objectForKey:kKeyPreferredAppId];
}

@end
