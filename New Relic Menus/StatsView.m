//
//  StatsView.m
//  New Relic Menus
//
//  Created by Brit Gardner on 6/18/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "StatsView.h"

@implementation StatsView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
    // Drawing code here.
}

- (BOOL)acceptsTouchEvents {
    return YES;
}

- (IBAction)mouseDown:(NSEvent *)theEvent {
    DebugLog(@"Mouse Down!!!");
    [[NSNotificationCenter defaultCenter] 
     postNotification:[NSNotification notificationWithName:STATS_VIEW_CLICKED_NOTIFICATION object:nil]];
}

@end
