#import "PHAppDelegate.h"
#import "PHOpenAtLogin.h"
#import "PHUniversalAccessHelper.h"

@implementation PHAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    [PHUniversalAccessHelper complainIfNeeded];

    [self setupStatusItem];

    self.configLoader = [[PHConfigLoader alloc] init];
    [self.configLoader createConfigiurationIfNeeded];
}

- (void)setupStatusItem {
    NSImage *image = [NSImage imageNamed:@"statusitem"];
    [image setTemplate:YES];

    self.statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    self.statusItem.highlightMode = YES;
    self.statusItem.image = image;
    self.statusItem.menu = self.statusItemMenu;
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
