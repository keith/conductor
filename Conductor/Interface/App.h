@protocol AppJSExport <JSExport>

@property (readonly) pid_t pid;

+ (NSArray *)runningApps;

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

- (id)initWithPID:(pid_t)pid;
- (id)initWithRunningApp:(NSRunningApplication *)app;

@property (readonly) pid_t pid;

@end
