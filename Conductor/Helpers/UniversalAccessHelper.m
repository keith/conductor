@import AppKit;
#import "UniversalAccessHelper.h"

@implementation UniversalAccessHelper

+ (void)complainIfNeeded {
    id key = (__bridge id)(kAXTrustedCheckOptionPrompt);
    CFDictionaryRef options = (__bridge CFDictionaryRef)@{key: @YES};
    Boolean enabled = AXIsProcessTrustedWithOptions(options);

    if (enabled) {
        return;
    }

    NSAlert *alert = [NSAlert new];
    alert.messageText = @"Enable Accessibility First";
    alert.informativeText = @"Find the system popup behind this one, click \"Open System Preferences\" and enable Conductor. Then launch Conductor again.";
    alert.alertStyle = NSAlertStyleCritical;
    [alert addButtonWithTitle:@"Quit"];
    [alert runModal];
    [NSApp terminate:self];
}

@end
