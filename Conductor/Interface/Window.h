@class App;
@class Window;

@protocol WindowJSExport <JSExport>

+ (NSArray *)allWindows;
+ (NSArray *)visibleWindows;
+ (Window *)focusedWindow;
+ (NSArray *)visibleWindowsMostRecentFirst;
- (NSArray *)otherWindowsOnSameScreen;
- (NSArray *)otherWindowsOnAllScreens;

- (CGRect)frame;
- (CGPoint)topLeft;
- (CGSize)size;
- (void)setFrame:(CGRect)frame;
- (void)setTopLeft:(CGPoint)thePoint;
- (void)setSize:(CGSize)theSize;
- (void)maximize;
- (void)minimize;
- (void)unMinimize;

- (NSScreen *)screen;
- (App *)app;

- (BOOL)focusWindow;
- (NSArray *)windowsToWest;
- (NSArray *)windowsToEast;
- (NSArray *)windowsToNorth;
- (NSArray *)windowsToSouth;
- (void)focusWindowLeft;
- (void)focusWindowRight;
- (void)focusWindowUp;
- (void)focusWindowDown;

- (NSString *)title;
- (BOOL)isNormalWindow;
- (BOOL)isWindowMinimized;

@end

@interface Window : NSObject <WindowJSExport>

- (instancetype)initWithElement:(AXUIElementRef)win;

@end
