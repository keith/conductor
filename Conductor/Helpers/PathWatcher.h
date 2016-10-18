@import Foundation;

@interface PathWatcher : NSObject

- (instancetype)initWithPath:(NSString *)path handler:(dispatch_block_t)handler;

- (NSString *)path;

@end
