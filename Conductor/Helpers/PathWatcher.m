#import "PathWatcher.h"

@interface PathWatcher ()

@property (nonatomic) dispatch_source_t source;
@property (nonatomic) NSString *path;
@property (nonatomic, copy) dispatch_block_t handler;

@end

@implementation PathWatcher

- (instancetype)initWithPath:(NSString *)path handler:(dispatch_block_t)handler {
    self = [super init];
    if (!self) return nil;

    self.path = path;
    self.handler = handler;

    [self setupWithPath:path handler:handler];

    return self;
}


- (void)setupWithPath:(NSString *)path handler:(dispatch_block_t)handler {
    uintptr_t file = (uintptr_t)open(path.UTF8String, O_RDONLY);
    dispatch_source_t source = dispatch_source_create(DISPATCH_SOURCE_TYPE_VNODE, file,
                                                      DISPATCH_VNODE_DELETE | DISPATCH_VNODE_WRITE |
                                                      DISPATCH_VNODE_EXTEND | DISPATCH_VNODE_ATTRIB |
                                                      DISPATCH_VNODE_LINK | DISPATCH_VNODE_RENAME |
                                                      DISPATCH_VNODE_REVOKE,
                                                      dispatch_get_main_queue());
    dispatch_source_set_event_handler(source, handler);
    dispatch_source_set_cancel_handler(source, ^{ close((int)file); });
    dispatch_resume(source);
    self.source = source;
}

- (void)dealloc {
    dispatch_source_cancel(self.source);
}

@end
