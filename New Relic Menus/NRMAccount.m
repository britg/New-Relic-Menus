//
//  NRMAccount.m
//  New Relic Menus
//
//  Created by Brit Gardner on 7/4/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "NRMAccount.h"

@implementation NRMAccount

@synthesize name;
@synthesize accountId;

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (id)initWithName:(NSString *)_name accountId:(int)_accountId {
    self = [self init];
    
    if (self) {
        self.name = _name;
        self.accountId = _accountId;
    }
    
    return self;
}

@end
