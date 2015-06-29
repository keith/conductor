@interface PHPathWatcher : NSObject

+ (PHPathWatcher *)watcherFor:(NSString *)path handler:(void(^)())handler;

- (NSString *)path;

@end
