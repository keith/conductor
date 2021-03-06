@import AppKit;
@import JavaScriptCore;

@protocol NSScreenJSExport <JSExport>

+ (float)getBrightness;
+ (void)setBrightness:(float)brightness;

- (CGRect)frameIncludingDockAndMenu;
- (CGRect)frameWithoutDockOrMenu;

- (NSScreen *)nextScreen;
- (NSScreen *)previousScreen;

@end

@interface NSScreen (JSInterface) <NSScreenJSExport>
@end
