//
//  NRMAccount.h
//  New Relic Menus
//
//  Created by Brit Gardner on 7/4/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NRMAccount : NSObject {
    NSString *name;
    int accountId;
}

@property (nonatomic, strong) NSString *name;
@property (nonatomic) int accountId;

- (id)initWithName:(NSString *)_name accountId:(int)_accountId;

@end
