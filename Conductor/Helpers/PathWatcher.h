@interface PathWatcher : NSObject

+ (PathWatcher *)watcherFor:(NSString *)path handler:(void(^)())handler;

- (NSString *)path;

@end
