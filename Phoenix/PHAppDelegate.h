//
//  PHAppDelegate.h
//  Phoenix
//
//  Created by Steven on 11/30/13.
//  Copyright (c) 2013 Steven. All rights reserved.
//

#import "PHConfigLoader.h"

@interface PHAppDelegate : NSObject <NSApplicationDelegate>

@property (nonatomic) IBOutlet NSMenu *statusItemMenu;
@property (nonatomic) NSStatusItem *statusItem;
@property (nonatomic) PHConfigLoader *configLoader;

@end
