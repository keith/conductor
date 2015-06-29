#import "NSScreen+JSInterface.h"
#import "Alerts.h"
#import "App.h"
#import "ConfigLoader.h"
#import "HotKey.h"
#import "MousePosition.h"
#import "PathWatcher.h"
#import "Window.h"

@interface ConfigLoader ()

@property NSMutableArray *hotkeys;
@property NSMutableArray *watchers;

@end

static NSString *const ConfigPath = @"~/.conductor.js";

@implementation ConfigLoader

- (id)init {
    self = [super init];
    if (!self) {
        return nil;
    }

    self.watchers = [NSMutableArray array];
    [self resetConfigListeners];

    return self;
}

- (void)addConfigListener:(NSString *)path {
    for (PathWatcher *watcher in self.watchers) {
        if ([watcher.path isEqualToString:path]) {
            return;
        }
    }

    PathWatcher *watcher = [PathWatcher watcherFor:path handler:^{
        [[self class] cancelPreviousPerformRequestsWithTarget:self selector:@selector(reload) object:nil];
        [self performSelector:@selector(reload) withObject:nil afterDelay:0.25];
    }];

    [self.watchers addObject:watcher];
}

- (void)resetConfigListeners {
    [self.watchers removeAllObjects];
    [self addConfigListener:ConfigPath];
}

- (void)createConfigInFile:(NSString *)filename {
    [[NSFileManager defaultManager] createFileAtPath:filename
                                            contents:[@"" dataUsingEncoding:NSUTF8StringEncoding]
                                          attributes:nil];
    NSString *message = [NSString stringWithFormat:@"I just created %@ for you :)", filename];
    [Alerts show:message duration:5.0f];
}

- (void)createConfigurationOrLoad {
    NSString *filename = [ConfigPath stringByStandardizingPath];
    BOOL exists = [[NSFileManager defaultManager] fileExistsAtPath:filename];
    if (exists) {
        [self reload];
    } else {
        [self createConfigInFile:filename];
    }
}

- (void)reload {
    [self resetConfigListeners];

    NSString *filename = [ConfigPath stringByStandardizingPath];
    NSString *config = [NSString stringWithContentsOfFile:filename
                                                 encoding:NSUTF8StringEncoding
                                                    error:NULL];

    if (!config) {
        NSString *message = [NSString stringWithFormat:@"No configuration found at %@\nRelaunch to create one automatically", filename];
        [Alerts show:message duration:5.0f];
        return;
    }

    [self.hotkeys makeObjectsPerformSelector:@selector(disable)];
    self.hotkeys = [NSMutableArray array];

    JSContext *ctx = [[JSContext alloc] initWithVirtualMachine:[[JSVirtualMachine alloc] init]];

    ctx.exceptionHandler = ^(JSContext *context, JSValue *val) {
        [Alerts show:[NSString stringWithFormat:@"[js exception] %@", val] duration:3.0f];
    };

    NSURL *_jsURL = [[NSBundle mainBundle] URLForResource:@"underscore-min" withExtension:@"js"];
    NSString *_js = [NSString stringWithContentsOfURL:_jsURL
                                             encoding:NSUTF8StringEncoding
                                                error:NULL];
    [ctx evaluateScript:_js];
    [self setupAPI:ctx];

    [ctx evaluateScript:config];
    [Alerts show:@"Conductor config loaded" duration:1.3f];
}

- (void)setupAPI:(JSContext *)ctx {
    JSValue *api = [JSValue valueWithNewObjectInContext:ctx];
    ctx[@"api"] = api;

    api[@"reload"] = ^(NSString *str) {
        [self reload];
    };

    api[@"launch"] = ^(NSString *appName) {
        [[NSWorkspace sharedWorkspace] launchApplication:appName];
    };

    api[@"alert"] = ^(NSString *str, CGFloat duration) {
        if (isnan(duration)) { duration = 2.0f; }
        [Alerts show:str duration:duration];
    };

    api[@"log"] = ^(NSString *msg) {
        NSLog(@"%@", msg);
    };

    api[@"bind"] = ^(NSString *key, NSArray *mods, JSValue *handler) {
        HotKey *hotkey = [HotKey withKey:key mods:mods handler:^BOOL{
            return [[handler callWithArguments:@[]] toBool];
        }];
        [self.hotkeys addObject:hotkey];
        [hotkey enable];
        return hotkey;
    };

    api[@"runCommand"] = ^(NSString *path, NSArray *args) {
        NSTask *task = [[NSTask alloc] init];

        [task setArguments:args];
        [task setLaunchPath:path];
        [task launch];

        while([task isRunning]);
    };

    api[@"setTint"] = ^(NSArray *red, NSArray *green, NSArray *blue) {
        CGGammaValue cred[red.count];
        for (NSUInteger i = 0; i < red.count; ++i) {
            cred[i] = [[red objectAtIndex:i] floatValue];
        }
        CGGammaValue cgreen[green.count];
        for (NSUInteger i = 0; i < green.count; ++i) {
            cgreen[i] = [[green objectAtIndex:i] floatValue];
        }
        CGGammaValue cblue[blue.count];
        for (NSUInteger i = 0; i < blue.count; ++i) {
            cblue[i] = [[blue objectAtIndex:i] floatValue];
        }
        uint32_t size = (uint32_t)sizeof(cred) / sizeof(cred[0]);
        CGSetDisplayTransferByTable(CGMainDisplayID(), size, cred, cgreen, cblue);
    };

    __weak JSContext *weakCtx = ctx;

    ctx[@"require"] = ^(NSString *path) {
        path = [path stringByStandardizingPath];

        if(! [path hasPrefix: @"/"]) {
            NSString *configPath = [ConfigPath stringByResolvingSymlinksInPath];
            NSURL *requirePathUrl = [NSURL URLWithString: path relativeToURL: [NSURL URLWithString: configPath]];
            path = [requirePathUrl absoluteString];
        }

        if(! [[NSFileManager defaultManager] fileExistsAtPath: path isDirectory: NULL]) {
            [self showJsException: [NSString stringWithFormat: @"Require: cannot find path %@", path]];
        } else {
            [self addConfigListener: path];

            NSString *_js = [NSString stringWithContentsOfFile: path encoding: NSUTF8StringEncoding error: NULL];
            [weakCtx evaluateScript:_js];
        }
    };

    ctx[@"Window"] = [Window self];
    ctx[@"App"] = [App self];
    ctx[@"Screen"] = [NSScreen self];
    ctx[@"MousePosition"] = [MousePosition self];
}

- (void)showJsException: (id)arg {
    [Alerts show:[NSString stringWithFormat:@"[js exception] %@", arg] duration:3.0f];
}

@end
