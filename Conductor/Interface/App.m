#import "App.h"
#import "Window.h"

@interface App()

@property AXUIElementRef app;
@property (readwrite) pid_t pid;

@property NSMutableArray *observers;

- (instancetype)initWithElement:(AXUIElementRef)element;

@end

@implementation App

+ (NSArray *)runningApps {
    NSMutableArray *apps = [NSMutableArray array];

    for (NSRunningApplication *runningApp in [[NSWorkspace sharedWorkspace] runningApplications]) {
        App *app = [[App alloc] initWithPID:[runningApp processIdentifier]];
        [apps addObject:app];
    }

    return apps;
}

+ (App *)frontmostApp {
    pid_t pid = [[[NSWorkspace sharedWorkspace] frontmostApplication] processIdentifier];
    return [[App alloc] initWithPID:pid];
}

- (instancetype)initWithElement:(AXUIElementRef)element {
    pid_t pid;
    AXUIElementGetPid(element, &pid);
    return [self initWithPID:pid];
}

- (instancetype)initWithRunningApp:(NSRunningApplication *)app {
    return [self initWithPID:[app processIdentifier]];
}

- (instancetype)initWithPID:(pid_t)pid {
    self = [super init];
    if (!self) return nil;

    self.observers = [NSMutableArray array];
    self.pid = pid;
    self.app = AXUIElementCreateApplication(pid);

    return self;
}

- (void)dealloc {
    self.observers = nil; // this will make them un-observe

    if (self.app) {
        CFRelease(self.app);
    }
}

- (BOOL)isEqual:(App *)object {
    return ([object isKindOfClass:[App class]] && self.pid == object.pid);
}

- (NSUInteger)hash {
    return (NSUInteger)self.pid;
}

- (NSArray *)visibleWindows {
    return [[self allWindows] filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(Window *window, __unused NSDictionary *bindings) {
        return ![[window app] isHidden] && ![window isWindowMinimized] && [window isNormalWindow];
    }]];
}

- (NSArray *)allWindows {
    NSMutableArray *windows = [NSMutableArray array];

    CFArrayRef _windows;
    AXError result = AXUIElementCopyAttributeValues(self.app, kAXWindowsAttribute, 0, 100, &_windows);
    if (result == kAXErrorSuccess) {
        for (NSInteger i = 0; i < CFArrayGetCount(_windows); i++) {
            AXUIElementRef win = CFArrayGetValueAtIndex(_windows, i);

            Window *window = [[Window alloc] initWithElement:win];
            [windows addObject:window];
        }
        CFRelease(_windows);
    }

    return windows;
}

- (BOOL)isHidden {
    CFTypeRef _isHidden;
    NSNumber *isHidden = @NO;
    if (AXUIElementCopyAttributeValue(self.app, (CFStringRef)NSAccessibilityHiddenAttribute, (CFTypeRef *)&_isHidden) == kAXErrorSuccess) {
        isHidden = CFBridgingRelease(_isHidden);
    }
    return [isHidden boolValue];
}

- (void)show {
    [self setAppProperty:NSAccessibilityHiddenAttribute withValue:@NO];
}

- (void)hide {
    [self setAppProperty:NSAccessibilityHiddenAttribute withValue:@YES];
}

- (NSString *)title {
    return [[NSRunningApplication runningApplicationWithProcessIdentifier:self.pid] localizedName];
}

- (void)kill {
    [[NSRunningApplication runningApplicationWithProcessIdentifier:self.pid] terminate];
}

- (void)kill9 {
    [[NSRunningApplication runningApplicationWithProcessIdentifier:self.pid] forceTerminate];
}

- (id)getAppProperty:(NSString *)propType withDefaultValue:(id)defaultValue {
    CFTypeRef _someProperty;
    if (AXUIElementCopyAttributeValue(self.app, (__bridge CFStringRef)propType, &_someProperty) == kAXErrorSuccess)
        return CFBridgingRelease(_someProperty);

    return defaultValue;
}

- (BOOL)setAppProperty:(NSString *)propType withValue:(id)value {
    AXError result = AXUIElementSetAttributeValue(self.app, (__bridge CFStringRef)(propType), (__bridge CFTypeRef)(value));
    return result == kAXErrorSuccess;
}

@end
