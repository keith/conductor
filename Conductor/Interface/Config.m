#import "Config.h"

@implementation Config

- (instancetype)init {
    self = [super init];
    if (!self) return nil;

    self.hideMenuBar = false;

    return self;
}

+ (instancetype)sharedConfig {
    static Config *shared = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shared = [Config new];
    });

    return shared;
}

+ (void)hideMenuBar {
    [Config sharedConfig].hideMenuBar = true;
}

@end
