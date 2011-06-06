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

@implementation APIHandler

@synthesize currentAPIKey;

SYNTHESIZE_SINGLETON_FOR_CLASS(APIHandler);

- (void)dealloc
{
    [super dealloc];
}

#pragma mark - Check API Key

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
    }];
    [request setFailedBlock:^{
        if ([delegate respondsToSelector:callback])
            [delegate performSelector:callback withObject:[NSNumber numberWithBool:NO]];
    }];
    
    [request startAsynchronous];
}

#pragma mark - Account & Application

- (void)getPrimaryAccount {
    
}

- (void)getPrimaryApplication {
    
}

#pragma mark - Metrics

- (void)getPrimaryMetrics {
    
}

@end
