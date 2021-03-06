@import AppKit;
@import JavaScriptCore;

@class App;

@protocol AppJSExport <JSExport>

@property (readonly) pid_t pid;

+ (NSArray *)runningApps;
+ (App *)frontmostApp;

- (NSArray *)allWindows;
- (NSArray *)visibleWindows;

- (NSString *)title;
- (BOOL)isHidden;
- (void)show;
- (void)hide;

- (void)kill;
- (void)kill9;

@end

@interface App : NSObject <AppJSExport>

- (instancetype)initWithPID:(pid_t)pid;
- (instancetype)initWithRunningApp:(NSRunningApplication *)app;

@property (readonly) pid_t pid;

@end
