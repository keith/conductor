#import "AppDelegate.h"
#import "OpenAtLogin.h"
#import "UniversalAccessHelper.h"

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    [UniversalAccessHelper complainIfNeeded];

    [self setupStatusItem];

    self.configLoader = [[ConfigLoader alloc] init];
    [self.configLoader createConfigurationOrLoad];
}

- (void)setupStatusItem {
    NSImage *image = [NSImage imageNamed:NSImageNameColumnViewTemplate];
    [image setTemplate:YES];

    self.statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    self.statusItem.highlightMode = YES;
    self.statusItem.image = image;
    self.statusItem.menu = self.statusItemMenu;
}

- (void)menuNeedsUpdate:(NSMenu *)menu {
    NSCellStateValue state = NSOffState;
    if ([OpenAtLogin opensAtLogin]) {
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
    [OpenAtLogin setOpensAtLogin:openAtLogin];
}

@end
