#import "AppDelegate.h"
#import "Config.h"
#import "OpenAtLogin.h"
#import "UniversalAccessHelper.h"

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    [UniversalAccessHelper complainIfNeeded];

    self.configLoader = [[ConfigLoader alloc] init];
    [self.configLoader createConfigurationOrLoad];
    [self setupStatusItem];
}

- (BOOL)applicationShouldHandleReopen:(NSApplication *)sender hasVisibleWindows:(BOOL)flag {
    [sender orderFrontStandardAboutPanel:nil];
    return YES;
}

- (void)setupStatusItem {
    if ([Config sharedConfig].hideMenuBar) {
        return;
    }

    NSImage *image = [NSImage imageNamed:NSImageNameColumnViewTemplate];
    [image setTemplate:YES];

    self.statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    self.statusItem.highlightMode = YES;
    self.statusItem.image = image;
    self.statusItem.menu = self.statusItemMenu;
}

- (void)menuNeedsUpdate:(NSMenu *)menu {
    NSCellStateValue state = [OpenAtLogin opensAtLogin] ? NSOnState : NSOffState;
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
    [OpenAtLogin setOpensAtLogin:openAtLogin];
}

@end
