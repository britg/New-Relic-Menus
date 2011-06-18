//
//  APIHandler.h
//  New Relic Menus
//
//  Created by Brit Gardner on 6/5/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface APIHandler : NSObject {
    int primaryAccountId;
    int primaryApplicationId;
    
    NSString *currentAPIKey;
    
    NSNumber *apdex;
    NSNumber *errorPercent;
    NSNumber *throughput;
    NSNumber *cpu;
    NSNumber *responseTime;
}

@property (nonatomic, retain) NSString *currentAPIKey;

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

- (void)getPrimaryAccount;
- (void)parsePrimaryAccount:(NSData *)data;
- (void)getPrimaryApplication;
- (void)parsePrimaryApplication:(NSData *)data;

- (void)getPrimaryMetrics;
- (void)parsePrimaryMetrics:(NSData *)data;

@end
