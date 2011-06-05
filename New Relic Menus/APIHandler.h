//
//  APIHandler.h
//  New Relic Menus
//
//  Created by Brit Gardner on 6/5/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface APIHandler : NSObject {
    
}
+ (APIHandler *)sharedInstance;

- (void)checkAPIKey:(NSString *)apikey delegate:(id)delegate
                                       callback:(SEL)callback;

@end
