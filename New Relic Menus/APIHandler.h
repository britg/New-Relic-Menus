//
//  APIHandler.h
//  New Relic Menus
//
//  Created by Brit Gardner on 6/5/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NRMApplication.h"
#import "NRMAccount.h"

@interface APIHandler : NSObject {
    int primaryAccountId;
    int primaryApplicationId;
    
    NSMutableArray *accounts;
    NRMAccount *currentAccount;
    
    NSMutableArray *applications;
    NRMApplication *currentApplication;
    
    NSString *currentAPIKey;
    
    NSNumber *apdex;
    NSNumber *errorPercent;
    NSNumber *throughput;
    NSNumber *cpu;
    NSNumber *responseTime;
}

@property (nonatomic, retain) NSString *currentAPIKey;
@property (nonatomic, retain) NSMutableArray *accounts;
@property (nonatomic, retain) NRMAccount *currentAccount;
@property (nonatomic, retain) NSMutableArray *applications;
@property (nonatomic, retain) NRMApplication *currentApplication;
@property (nonatomic, retain) NSNumber *apdex;
@property (nonatomic, retain) NSNumber *errorPercent;
@property (nonatomic, retain) NSNumber *throughput;
@property (nonatomic, retain) NSNumber *cpu;
@property (nonatomic, retain) NSNumber *responseTime;

+ (APIHandler *)sharedInstance;

- (void)saveAPIKey:(NSString *)apiKey;
- (NSString *)storedAPIKey;
- (void)checkAPIKey:(NSString *)apikey delegate:(id)delegate
                                       callback:(SEL)callback;

- (NSURL *)dashboardURL;

- (void)getPrimaryAccount;
- (void)parsePrimaryAccount:(NSData *)data;
- (void)getPrimaryApplication;
- (void)parsePrimaryApplication:(NSData *)data;

- (void)getPrimaryMetrics;
- (void)parsePrimaryMetrics:(NSData *)data;

- (void)setApplication:(int)appId;
- (void)setAccount:(int)accountId;

@end
