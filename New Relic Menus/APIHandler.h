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
}

@property (nonatomic, retain) NSString *currentAPIKey;

+ (APIHandler *)sharedInstance;

- (void)checkAPIKey:(NSString *)apikey delegate:(id)delegate
                                       callback:(SEL)callback;

- (void)getPrimaryAccount;
- (void)getPrimaryApplication;

- (void)getPrimaryMetrics;

@end
