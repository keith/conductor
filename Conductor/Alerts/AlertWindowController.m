#import "AlertWindowController.h"

@interface AlertWindowController ()

@property (nonatomic) IBOutlet NSTextField *textField;
@property (nonatomic) IBOutlet NSBox *box;

@end

@implementation AlertWindowController

- (NSString *)windowNibName {
    return @"AlertWindow";
}

- (void)windowDidLoad {
    self.window.backgroundColor = [NSColor clearColor];
    self.window.opaque = NO;
    self.window.level = NSFloatingWindowLevel;
    self.window.ignoresMouseEvents = YES;
}

- (void)show:(NSString *)message duration:(CGFloat)duration YAdjustment:(CGFloat)adjustment {
    [self useTitleAndResize:message];
    [self setFrameWithAdjustment:adjustment];
    [self showWindow:self];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(duration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self fadeWindowOut];
    });
}

- (void)setFrameWithAdjustment:(CGFloat)adjustment {
    NSScreen *currentScreen = [NSScreen mainScreen];
    CGRect screenRect = [currentScreen frame];
    CGRect winRect = [[self window] frame];

    winRect.origin.x = (screenRect.size.width / 2.0) - (winRect.size.width / 2.0);
    winRect.origin.y = adjustment - winRect.size.height;

    [self.window setFrame:winRect display:NO];
}

- (void)fadeWindowOut {
    [NSAnimationContext runAnimationGroup:^(NSAnimationContext *context) {
        context.duration = 0.15f;
        [[[self window] animator] setAlphaValue:0.0];
    } completionHandler:^{
        [self closeAndResetWindow];
    }];
}

- (void)closeAndResetWindow {
    [[self window] orderOut:nil];
    [self.delegate alertClosed:self];
}

- (void)useTitleAndResize:(NSString *)title {
    [self window]; // sigh; required in case nib hasnt loaded yet

    self.textField.stringValue = title;
    [self.textField sizeToFit];

	NSRect windowFrame = [[self window] frame];
	windowFrame.size.width = [self.textField frame].size.width + 32.0;
	windowFrame.size.height = [self.textField frame].size.height + 24.0;
	[[self window] setFrame:windowFrame display:YES];
}

@end
