@protocol PHAppJSExport <JSExport>

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

@interface PHApp : NSObject <PHAppJSExport>

- (id)initWithPID:(pid_t)pid;
- (id)initWithRunningApp:(NSRunningApplication *)app;

@property (readonly) pid_t pid;

@end
