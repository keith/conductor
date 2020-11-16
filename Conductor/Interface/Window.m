#import "NSScreen+JSInterface.h"
#import "App.h"
#import "Window.h"

@interface Window ()

@property CFTypeRef window;

@end

@implementation Window

- (instancetype)initWithElement:(AXUIElementRef)win {
    self = [super init];
    if (!self) return nil;

    self.window = CFRetain(win);

    return self;
}

- (void)dealloc {
    if (self.window) {
        CFRelease(self.window);
    }
}

- (BOOL)isEqual:(id)other {
    return [other isKindOfClass:[Window class]] && CFEqual(self.window, [(Window *)other window]);
}

- (NSUInteger)hash {
    return CFHash(self.window);
}

+ (NSArray *)allWindows {
    NSMutableArray *windows = [NSMutableArray array];

    for (App *app in [App runningApps]) {
        [windows addObjectsFromArray:[app allWindows]];
    }

    return windows;
}

- (BOOL)isNormalWindow {
    return [[self subrole] isEqualToString:(__bridge NSString *)kAXStandardWindowSubrole];
}

+ (NSArray *)visibleWindows {
    return [[self allWindows] filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(Window *window, __unused NSDictionary *bindings) {
        return ![[window app] isHidden] && ![window isWindowMinimized] && [window isNormalWindow];
    }]];
}

// XXX: undocumented API.  We need this to match dictionary entries returned by CGWindowListCopyWindowInfo (which
// appears to be the *only* way to get a list of all windows on the system in "most-recently-used first" order) against
// AXUIElementRef's returned by AXUIElementCopyAttributeValues
AXError _AXUIElementGetWindow(AXUIElementRef, CGWindowID *out);

+ (NSArray *)visibleWindowsMostRecentFirst {
    // This gets windows sorted by most-recently-used criteria.  The
    // first one will be the active window.
    CFArrayRef visible_win_info = CGWindowListCopyWindowInfo(
        kCGWindowListOptionOnScreenOnly | kCGWindowListExcludeDesktopElements,
        kCGNullWindowID);

    // But we only got some dictionaries containing info.  Need to get
    // the actual AXUIMyHeadHurts for each of them and create SDWindow-s.
    NSMutableArray *windows = [NSMutableArray array];
    for (NSMutableDictionary *entry in (__bridge NSArray *)visible_win_info) {
        // Tricky...  for Google Chrome we get one hidden window for
        // each visible window, so we need to check alpha > 0.
        int alpha = [[entry objectForKey:(id)kCGWindowAlpha] intValue];
        int layer = [[entry objectForKey:(id)kCGWindowLayer] intValue];

        if (layer == 0 && alpha > 0) {
            CGWindowID win_id = [[entry objectForKey:(id)kCGWindowNumber] unsignedIntValue];

            // some AXUIElementCreateByWindowNumber would be soooo nice.  but nope, we have to take the pain below.

            int pid = [[entry objectForKey:(id)kCGWindowOwnerPID] intValue];
            AXUIElementRef app = AXUIElementCreateApplication(pid);
            CFArrayRef appWindows;
            AXUIElementCopyAttributeValues(app, kAXWindowsAttribute, 0, 1000, &appWindows);
            if (appWindows) {
                // looks like appWindows can be NULL when this function is called during the
                // switch-workspaces animation
                for (id w in (__bridge NSArray *)appWindows) {
                    AXUIElementRef win = (__bridge AXUIElementRef)w;
                    CGWindowID tmp;
                    _AXUIElementGetWindow(win, &tmp); // XXX: undocumented API.  but the alternative is horrifying.
                    if (tmp == win_id) {
                        // finally got it, insert in the result array.
                        [windows addObject:[[Window alloc] initWithElement:win]];
                        break;
                    }
                }
                CFRelease(appWindows);
            }
            CFRelease(app);
        }
    }
    CFRelease(visible_win_info);

    return windows;
}

- (NSArray *)otherWindowsOnSameScreen {
    return [[Window visibleWindows] filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(Window *win, __unused NSDictionary *bindings) {
        return !CFEqual(self.window, win.window) && [[self screen] isEqual: [win screen]];
    }]];
}

- (NSArray *)otherWindowsOnAllScreens {
    return [[Window visibleWindows] filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(Window *win, __unused NSDictionary *bindings) {
        return !CFEqual(self.window, win.window);
    }]];
}

+ (AXUIElementRef)systemWideElement {
    static AXUIElementRef systemWideElement;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        systemWideElement = AXUIElementCreateSystemWide();
    });

    return systemWideElement;
}

+ (Window *)focusedWindow {
    CFTypeRef app;
    AXUIElementCopyAttributeValue([self systemWideElement], kAXFocusedApplicationAttribute, &app);
    if (!app) {
        return nil;
    }

    CFTypeRef win;
    AXError result = AXUIElementCopyAttributeValue(app,
                                                   (CFStringRef)NSAccessibilityFocusedWindowAttribute,
                                                   &win);

    CFRelease(app);

    if (result == kAXErrorSuccess) {
        Window *window = [[Window alloc] init];
        window.window = win;
        return window;
    }

    return nil;
}

- (CGRect)frame {
    CGRect r;
    r.origin = [self topLeft];
    r.size = [self size];
    return r;
}

- (void)setFrame:(CGRect)frame {
    [self setSize:frame.size];
    [self setTopLeft:frame.origin];
    [self setSize:frame.size];
}

- (CGPoint)topLeft {
    CFTypeRef positionStorage;
    AXError result = AXUIElementCopyAttributeValue(self.window, (CFStringRef)NSAccessibilityPositionAttribute, &positionStorage);

    CGPoint topLeft = CGPointZero;
    if (result == kAXErrorSuccess) {
        if (!AXValueGetValue(positionStorage, kAXValueCGPointType, (void *)&topLeft)) {
            topLeft = CGPointZero;
        }
    }

    if (positionStorage) {
        CFRelease(positionStorage);
    }

    return topLeft;
}

- (CGSize)size {
    CFTypeRef sizeStorage;
    AXError result = AXUIElementCopyAttributeValue(self.window, (CFStringRef)NSAccessibilitySizeAttribute, &sizeStorage);

    CGSize size = CGSizeZero;
    if (result == kAXErrorSuccess) {
        if (!AXValueGetValue(sizeStorage, kAXValueCGSizeType, (void *)&size)) {
            size = CGSizeZero;
        }
    }

    if (sizeStorage) {
        CFRelease(sizeStorage);
    }

    return size;
}

- (void)setTopLeft:(CGPoint)thePoint {
    CFTypeRef positionStorage = (CFTypeRef)(AXValueCreate(kAXValueCGPointType, (const void *)&thePoint));
    AXUIElementSetAttributeValue(self.window, (CFStringRef)NSAccessibilityPositionAttribute, positionStorage);
    if (positionStorage) {
        CFRelease(positionStorage);
    }
}

- (void)setSize:(CGSize)theSize {
    CFTypeRef sizeStorage = (CFTypeRef)(AXValueCreate(kAXValueCGSizeType, (const void *)&theSize));
    AXUIElementSetAttributeValue(self.window, (CFStringRef)NSAccessibilitySizeAttribute, sizeStorage);
    if (sizeStorage) {
        CFRelease(sizeStorage);
    }
}

- (NSScreen *)screen {
    CGRect windowFrame = [self frame];

    CGFloat lastVolume = 0;
    NSScreen *lastScreen = nil;

    for (NSScreen *screen in [NSScreen screens]) {
        CGRect screenFrame = [screen frameIncludingDockAndMenu];
        CGRect intersection = CGRectIntersection(windowFrame, screenFrame);
        CGFloat volume = intersection.size.width * intersection.size.height;

        if (volume > lastVolume) {
            lastVolume = volume;
            lastScreen = screen;
        }
    }

    return lastScreen;
}

- (void)maximize {
    CGRect screenRect = [[self screen] frameWithoutDockOrMenu];
    [self setFrame: screenRect];
}

- (void)minimize {
    [self setWindowMinimized:YES];
}

- (void)unMinimize {
    [self setWindowMinimized:NO];
}

- (BOOL)focusWindow {
    AXError changedMainWindowResult = AXUIElementSetAttributeValue(self.window, (CFStringRef)NSAccessibilityMainAttribute, kCFBooleanTrue);
    if (changedMainWindowResult != kAXErrorSuccess) {
        NSLog(@"ERROR: Could not change focus to window");
        return NO;
    }

    NSRunningApplication *app = [NSRunningApplication runningApplicationWithProcessIdentifier:[self processIdentifier]];
    return [app activateWithOptions:NSApplicationActivateIgnoringOtherApps];
}

- (pid_t)processIdentifier {
    pid_t pid = 0;
    AXError result = AXUIElementGetPid(self.window, &pid);
    if (result == kAXErrorSuccess) {
        return pid;
    } else {
        return 0;
    }
}

- (App *)app {
    return [[App alloc] initWithPID:[self processIdentifier]];
}

- (id)getWindowProperty:(NSString *)propType withDefaultValue:(id)defaultValue {
    CFTypeRef _someProperty;
    if (AXUIElementCopyAttributeValue(self.window,
                                      (__bridge CFStringRef)propType,
                                      &_someProperty) == kAXErrorSuccess)
    {
        return CFBridgingRelease(_someProperty);
    }

    return defaultValue;
}

- (BOOL)setWindowProperty:(NSString *)propType withValue:(id)value {
    if (![value isKindOfClass:[NSNumber class]]) {
        return NO;
    }

    AXError result = AXUIElementSetAttributeValue(self.window,
                                                  (__bridge CFStringRef)(propType),
                                                  (__bridge CFTypeRef)(value));
    return result == kAXErrorSuccess;
}

- (NSString *)title {
    return [self getWindowProperty:NSAccessibilityTitleAttribute withDefaultValue:@""];
}

- (NSString *)role {
    return [self getWindowProperty:NSAccessibilityRoleAttribute withDefaultValue:@""];
}

- (NSString *)subrole {
    return [self getWindowProperty:NSAccessibilitySubroleAttribute withDefaultValue:@""];
}

- (BOOL)isWindowMinimized {
    return [[self getWindowProperty:NSAccessibilityMinimizedAttribute withDefaultValue:@(NO)] boolValue];
}

- (void)setWindowMinimized:(BOOL)flag {
    [self setWindowProperty:NSAccessibilityMinimizedAttribute withValue:[NSNumber numberWithLong:flag]];
}

// focus

NSPoint SDMidpoint(NSRect r) {
    return NSMakePoint(NSMidX(r), NSMidY(r));
}

- (NSArray *)windowsInDirectionFn:(double(^)(double angle))whichDirectionFn
                shouldDisregardFn:(BOOL(^)(double deltaX, double deltaY))shouldDisregardFn
{
    Window *thisWindow = [Window focusedWindow];
    NSPoint startingPoint = SDMidpoint([thisWindow frame]);

    NSArray *otherWindows = [thisWindow otherWindowsOnAllScreens];
    NSMutableArray *closestOtherWindows = [NSMutableArray arrayWithCapacity:[otherWindows count]];

    for (Window *window in otherWindows) {
        NSPoint otherPoint = SDMidpoint([window frame]);

        double deltaX = otherPoint.x - startingPoint.x;
        double deltaY = otherPoint.y - startingPoint.y;

        if (shouldDisregardFn(deltaX, deltaY)) {
            continue;
        }

        double angle = atan2(deltaY, deltaX);
        double distance = hypot(deltaX, deltaY);

        double angleDifference = whichDirectionFn(angle);

        double score = distance / cos(angleDifference / 2.0);

        [closestOtherWindows addObject:@{
            @"score": @(score),
            @"win": window,
        }];
    }

    NSArray *sortedOtherWindows = [closestOtherWindows sortedArrayUsingComparator:^NSComparisonResult(NSDictionary *pair1, NSDictionary *pair2) {
        return [[pair1 objectForKey:@"score"] compare:[pair2 objectForKey:@"score"]];
    }];

    return sortedOtherWindows;
}

- (void)focusFirstValidWindowIn:(NSArray *)closestWindows {
    for (Window *window in closestWindows) {
        if ([window focusWindow]) {
            break;
        }
    }
}

- (NSArray *)windowsToWest {
    return [[self windowsInDirectionFn:^double(double angle) { return M_PI - abs((int)angle); }
                     shouldDisregardFn:^BOOL(double deltaX, __unused double deltaY) { return (deltaX >= 0); }] valueForKeyPath:@"win"];
}

- (NSArray *)windowsToEast {
    return [[self windowsInDirectionFn:^double(double angle) { return 0.0 - angle; }
                     shouldDisregardFn:^BOOL(double deltaX, __unused double deltaY) { return (deltaX <= 0); }] valueForKeyPath:@"win"];
}

- (NSArray *)windowsToNorth {
    return [[self windowsInDirectionFn:^double(double angle) { return -M_PI_2 - angle; }
                     shouldDisregardFn:^BOOL(__unused double deltaX, double deltaY) { return (deltaY >= 0); }] valueForKeyPath:@"win"];
}

- (NSArray *)windowsToSouth {
    return [[self windowsInDirectionFn:^double(double angle) { return M_PI_2 - angle; }
                     shouldDisregardFn:^BOOL(__unused double deltaX, double deltaY) { return (deltaY <= 0); }] valueForKeyPath:@"win"];
}

- (void)focusWindowLeft {
    [self focusFirstValidWindowIn:[self windowsToWest]];
}

- (void)focusWindowRight {
    [self focusFirstValidWindowIn:[self windowsToEast]];
}

- (void)focusWindowUp {
    [self focusFirstValidWindowIn:[self windowsToNorth]];
}

- (void)focusWindowDown {
    [self focusFirstValidWindowIn:[self windowsToSouth]];
}

@end
