#import "Alerts.h"
#import "AlertWindowController.h"

@interface Alerts () <AlertDelegate>

@property (nonatomic) NSMutableArray *visibleAlerts;

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
