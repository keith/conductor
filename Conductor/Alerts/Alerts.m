@import QuartzCore;
#import "Alerts.h"

@class AlertWindowController;

@protocol AlertDelegate <NSObject>

- (void)alertClosed:(AlertWindowController *)alert;

@end

@interface AlertWindowController : NSWindowController

@property (weak) id<AlertDelegate> delegate;

- (void)show:(NSString *)message duration:(CGFloat)duration YAdjustment:(CGFloat)adjustment;

@end

@interface Alerts () <AlertDelegate>

@property NSMutableArray *visibleAlerts;

@end

@implementation Alerts

+ (Alerts *)sharedAlerts {
    static Alerts *sharedAlerts;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedAlerts = [Alerts new];
        sharedAlerts.visibleAlerts = [NSMutableArray array];
    });
    return sharedAlerts;
}

+ (void)show:(NSString *)oneLineMsg duration:(CGFloat)duration {
    Alerts *alerts = [Alerts sharedAlerts];
    CGFloat absoluteTop;

    NSScreen *currentScreen = [NSScreen mainScreen];

    if ([alerts.visibleAlerts count] == 0) {
        CGRect screenRect = [currentScreen frame];
        absoluteTop = screenRect.size.height / 1.55;
    } else {
        AlertWindowController *ctrl = [alerts.visibleAlerts lastObject];
        absoluteTop = NSMinY([[ctrl window] frame]) - 3.0;
    }

    if (absoluteTop <= 0) {
        absoluteTop = NSMaxY([currentScreen visibleFrame]);
    }

    AlertWindowController *alert = [[AlertWindowController alloc] init];
    alert.delegate = alerts;
    [alert show:oneLineMsg duration:duration YAdjustment:absoluteTop];
    [alerts.visibleAlerts addObject:alert];
}

- (void)alertClosed:(AlertWindowController *)alert {
    [self.visibleAlerts removeObject:alert];
}

@end

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
    [NSAnimationContext runAnimationGroup:^(NSAnimationContext *context) {
        context.duration = 0.01;
        [[[self window] animator] setAlphaValue:1.0];
        [self useTitleAndResize:message];
        [self setFrameWithAdjustment:adjustment];
        [self showWindow:self];
    } completionHandler:^{
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW,
                                     (int64_t)(duration * NSEC_PER_SEC)),
                       dispatch_get_main_queue(), ^{
            [self fadeWindowOut];
        });
    }];
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
    [NSAnimationContext beginGrouping];
    [[NSAnimationContext currentContext] setDuration:0.15];
    [[[self window] animator] setAlphaValue:0.0];
    [NSAnimationContext endGrouping];

    [self performSelector:@selector(closeAndResetWindow) withObject:nil afterDelay:0.15];
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
