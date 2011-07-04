//
//  NRMApplication.m
//  New Relic Menus
//
//  Created by Brit Gardner on 7/3/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "NRMApplication.h"

@implementation NRMApplication

@synthesize name;
@synthesize appId;

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (id)initWithName:(NSString *)_name appId:(int)_appId {
    self = [self init];
    
    if (self) {
        self.name = _name;
        self.appId = _appId;
    }
    
    return self;
}

- (NSString *)stringValue {
    return self.name;
}

@end
