@import QuartzCore;
#import "Alerts.h"

@class AlertWindowController;

@protocol AlertDelegate <NSObject>

- (void)alertClosed:(AlertWindowController *)alert;

@end

@protocol PHAlertHoraMortisNostraeDelegate <NSObject>

- (void)oraPro:(id)nobis;

@end

@interface AlertWindowController : NSWindowController

@property (weak) id<AlertDelegate> delegate;

- (void)show:(NSString *)oneLineMsg duration:(CGFloat)duration pushDownBy:(CGFloat)adjustment;

@end

@interface Alerts () <AlertDelegate>

@property NSMutableArray *visibleAlerts;

@end

@implementation Alerts

+ (Alerts *)sharedAlerts {
    static Alerts *sharedAlerts;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedAlerts = [[Alerts alloc] init];
    });
    return sharedAlerts;
}

- (id)init
{
    self = [super init];
    if (!self) {
        return nil;
    }

    self.alertDisappearDelay = 1.0;
    self.visibleAlerts = [NSMutableArray array];

    return self;
}

- (void)show:(NSString *)oneLineMsg {
    [self show:oneLineMsg duration:self.alertDisappearDelay];
}

- (void)show:(NSString *)oneLineMsg duration:(CGFloat)duration {
    CGFloat absoluteTop;

    NSScreen *currentScreen = [NSScreen mainScreen];

    if ([self.visibleAlerts count] == 0) {
        CGRect screenRect = [currentScreen frame];
        absoluteTop = screenRect.size.height / 1.55;
    } else {
        AlertWindowController *ctrl = [self.visibleAlerts lastObject];
        absoluteTop = NSMinY([[ctrl window] frame]) - 3.0;
    }

    if (absoluteTop <= 0) {
        absoluteTop = NSMaxY([currentScreen visibleFrame]);
    }

    AlertWindowController *alert = [[AlertWindowController alloc] init];
    alert.delegate = self;
    [alert show:oneLineMsg duration:duration pushDownBy:absoluteTop];
    [self.visibleAlerts addObject:alert];
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

- (void)show:(NSString *)oneLineMsg duration:(CGFloat)duration pushDownBy:(CGFloat)adjustment {
    NSDisableScreenUpdates();

    [NSAnimationContext beginGrouping];
    [[NSAnimationContext currentContext] setDuration:0.01];
    [[[self window] animator] setAlphaValue:1.0];
    [NSAnimationContext endGrouping];

    [self useTitleAndResize:[oneLineMsg description]];
    [self setFrameWithAdjustment:adjustment];
    [self showWindow:self];
    [self performSelector:@selector(fadeWindowOut) withObject:nil afterDelay:duration];

    NSEnableScreenUpdates();
}

- (void)setFrameWithAdjustment:(CGFloat)pushDownBy {
    NSScreen *currentScreen = [NSScreen mainScreen];
    CGRect screenRect = [currentScreen frame];
    CGRect winRect = [[self window] frame];

    winRect.origin.x = (screenRect.size.width / 2.0) - (winRect.size.width / 2.0);
    winRect.origin.y = pushDownBy - winRect.size.height;

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
    [[self window] setAlphaValue:1.0];

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
