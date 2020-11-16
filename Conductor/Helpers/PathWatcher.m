#import "PathWatcher.h"

@interface PathWatcher ()

@property (nonatomic) FSEventStreamRef eventStream;
@property (nonatomic, nonnull) NSString *path;
@property (nonatomic, copy, nonnull) dispatch_block_t handler;

@end

static void callback(__unused ConstFSEventStreamRef streamRef,
                     void *clientCallBackInfo,
                     __unused size_t numEvents,
                     __unused void *eventPaths,
                     __unused const FSEventStreamEventFlags eventFlags[],
                     __unused const FSEventStreamEventId eventIds[])
{
    PathWatcher *watcher = (__bridge id)(clientCallBackInfo);
    assert(watcher != nil);
    watcher.handler();
}

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
    FSEventStreamContext context;
    memset(&context, 0, sizeof(context));
    context.info = (__bridge void * _Nullable)(self);

    self.eventStream = FSEventStreamCreate(NULL,
                                           callback,
                                           &context,
                                           (__bridge CFArrayRef)@[path],
                                           kFSEventStreamEventIdSinceNow,
                                           1.0,
                                           kFSEventStreamCreateFlagWatchRoot | kFSEventStreamCreateFlagIgnoreSelf);
    FSEventStreamScheduleWithRunLoop(self.eventStream, CFRunLoopGetCurrent(), kCFRunLoopDefaultMode);
    FSEventStreamStart(self.eventStream);
}

- (void)dealloc {
    FSEventStreamStop(self.eventStream);
    FSEventStreamInvalidate(self.eventStream);
}

@end
