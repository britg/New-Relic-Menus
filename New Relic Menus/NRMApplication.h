//
//  NRMApplication.h
//  New Relic Menus
//
//  Created by Brit Gardner on 7/3/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NRMApplication : NSObject {
    
    NSString *name;
    int appId;
    
}

@property (nonatomic, strong) NSString *name;
@property (nonatomic) int appId;

- (id)initWithName:(NSString *)_name appId:(int)_appId;
- (NSString *)stringValue;

@end
