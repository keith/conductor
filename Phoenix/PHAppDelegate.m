//
//  PHAppDelegate.m
//  Phoenix
//
//  Created by Steven on 11/30/13.
//  Copyright (c) 2013 Steven. All rights reserved.
//

#import "PHAppDelegate.h"
#import "PHOpenAtLogin.h"
#import "PHUniversalAccessHelper.h"

@implementation PHAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    [PHUniversalAccessHelper complainIfNeeded];

    [self setupStatusItem];

    self.configLoader = [[PHConfigLoader alloc] init];
    [self.configLoader reload];
}

- (void)setupStatusItem {
    NSImage *img = [NSImage imageNamed:@"statusitem"];
    [img setTemplate:YES];

    self.statusItem = [[NSStatusBar systemStatusBar]
                       statusItemWithLength:NSVariableStatusItemLength];
    [self.statusItem setHighlightMode:YES];
    [self.statusItem setImage:img];
    [self.statusItem setMenu:self.statusItemMenu];
}

- (void)menuNeedsUpdate:(NSMenu *)menu {
    NSCellStateValue state = NSOffState;
    if ([PHOpenAtLogin opensAtLogin]) {
        state = NSOnState;
    }

    [[menu itemWithTitle:@"Open at Login"] setState:state];
}

#pragma mark - IBActions

- (IBAction)reloadConfig:(id)sender {
    [self.configLoader reload];
}

- (IBAction)showAboutPanel:(id)sender {
    [NSApp activateIgnoringOtherApps:YES];
    [NSApp orderFrontStandardAboutPanel:sender];
}

- (IBAction)toggleOpenAtLogin:(NSMenuItem *)sender {
    BOOL openAtLogin = sender.state == NSOffState;
    [PHOpenAtLogin setOpensAtLogin:openAtLogin];
}

@end
