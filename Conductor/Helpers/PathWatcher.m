#import "PathWatcher.h"

@interface PathWatcher ()

@property (nonatomic) FSEventStreamRef stream;
@property (nonatomic) NSString *path;
@property (nonatomic, copy) void(^handler)();

@end

@implementation PathWatcher

void fsEventsCallback(ConstFSEventStreamRef streamRef,
                      void *clientCallBackInfo,
                      size_t numEvents,
                      void *eventPaths,
                      const FSEventStreamEventFlags eventFlags[],
                      const FSEventStreamEventId eventIds[])
{
    PathWatcher *watcher = (__bridge PathWatcher *)clientCallBackInfo;
    [watcher fileChanged];
}

+ (PathWatcher *)watcherFor:(NSString *)path handler:(void(^)())handler {
    PathWatcher *watcher = [[PathWatcher alloc] init];
    watcher.handler = handler;
    watcher.path = path;
    [watcher setup];
    return watcher;
}

- (void)dealloc {
    if (self.stream) {
        FSEventStreamStop(self.stream);
        FSEventStreamInvalidate(self.stream);
        FSEventStreamRelease(self.stream);
    }
}

- (void)setup {
    FSEventStreamContext context;
    context.info = (__bridge void *)self;
    context.version = 0;
    context.retain = NULL;
    context.release = NULL;
    context.copyDescription = NULL;
    self.stream = FSEventStreamCreate(NULL,
                                      fsEventsCallback,
                                      &context,
                                      (__bridge CFArrayRef)@[[self.path stringByStandardizingPath]],
                                      kFSEventStreamEventIdSinceNow,
                                      0.4,
                                      kFSEventStreamCreateFlagWatchRoot | kFSEventStreamCreateFlagNoDefer | kFSEventStreamCreateFlagFileEvents);
    FSEventStreamScheduleWithRunLoop(self.stream, CFRunLoopGetCurrent(), kCFRunLoopDefaultMode);
    FSEventStreamStart(self.stream);
}

- (void)fileChanged {
    self.handler();
}

@end
