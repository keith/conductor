@protocol ConfigJSExport <JSExport>

+ (void)hideMenuBar;

@end

@interface Config : NSObject <ConfigJSExport>

@property (nonatomic) BOOL hideMenuBar;

+ (instancetype)sharedConfig;

@end
