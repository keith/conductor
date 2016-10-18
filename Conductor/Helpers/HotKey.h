@import JavaScriptCore;

typedef BOOL(^CONHotKeyHandler)(void);
@class HotKey;

@protocol HotKeyJSExport <JSExport>

@property NSString *key;
@property NSArray *mods;
@property (copy) CONHotKeyHandler handler;

+ (HotKey *)withKey:(NSString *)key mods:(NSArray *)mods handler:(CONHotKeyHandler)handler;

- (BOOL)enable;
- (void)disable;

@end

@interface HotKey : NSObject <HotKeyJSExport>

@property NSString *key;
@property NSArray *mods;
@property (copy) CONHotKeyHandler handler;

@end
