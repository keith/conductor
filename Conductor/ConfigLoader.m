#import "Alerts.h"
#import "App.h"
#import "Config.h"
#import "ConfigLoader.h"
#import "HotKey.h"
#import "MousePosition.h"
#import "NSScreen+JSInterface.h"
#import "PathWatcher.h"
#import "Window.h"

@interface ConfigLoader ()

@property NSMutableArray *hotkeys;
@property NSMutableArray *watchers;

@end

static NSString *const ConfigPath = @"~/.conductor.js";

@implementation ConfigLoader

- (instancetype)init {
    self = [super init];
    if (!self) return nil;

    self.watchers = [NSMutableArray array];
    [self resetConfigListeners];

    return self;
}

- (void)addConfigListener:(NSString *)path {
    for (PathWatcher *watcher in self.watchers) {
        if ([watcher.path isEqualToString:[path stringByExpandingTildeInPath]]) {
            return;
        }
    }

    PathWatcher *watcher = [[PathWatcher alloc] initWithPath:[path stringByExpandingTildeInPath] handler:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [self reload];
        });
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
    [Alerts show:message duration:5.0];
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
    NSString *filename = [ConfigPath stringByStandardizingPath];
    NSString *config = [NSString stringWithContentsOfFile:filename
                                                 encoding:NSUTF8StringEncoding
                                                    error:NULL];

    if (!config) {
        NSString *message = [NSString stringWithFormat:@"No configuration found at %@\nRelaunch to create one automatically", filename];
        [Alerts show:message duration:5.0];
        return;
    }

    [self.hotkeys makeObjectsPerformSelector:@selector(disable)];
    self.hotkeys = [NSMutableArray array];

    JSContext *ctx = [[JSContext alloc] initWithVirtualMachine:[[JSVirtualMachine alloc] init]];

    ctx.exceptionHandler = ^(JSContext *context, JSValue *val) {
        [Alerts show:[NSString stringWithFormat:@"[js exception] %@", val] duration:3.0f];
    };

    NSURL *underscoreURL = [[NSBundle mainBundle] URLForResource:@"underscore-min" withExtension:@"js"];
    NSString *underscore = [NSString stringWithContentsOfURL:underscoreURL
                                                    encoding:NSUTF8StringEncoding
                                                       error:NULL];
    [ctx evaluateScript:underscore];
    [self setupAPI:ctx];

    [ctx evaluateScript:config];
    [Alerts show:@"Conductor config loaded" duration:1.3];
}

- (void)setupAPI:(JSContext *)ctx {
    JSValue *api = [JSValue valueWithNewObjectInContext:ctx];
    ctx[@"api"] = api;

    api[@"reload"] = ^void {
        [self reload];
    };

    api[@"launch"] = ^void(NSString *appName) {
        [[NSWorkspace sharedWorkspace] launchApplication:appName];
    };

    api[@"alert"] = ^void(NSString *str, CGFloat duration) {
        if (isnan(duration)) { duration = 2.0; }
        [Alerts show:str duration:duration];
    };

    api[@"log"] = ^void(NSString *msg) {
        NSLog(@"%@", msg);
    };

    api[@"bind"] = ^void(NSString *key, NSArray *mods, JSValue *handler) {
        HotKey *hotkey = [HotKey withKey:key mods:mods handler:^BOOL{
            return [[handler callWithArguments:@[]] toBool];
        }];
        [self.hotkeys addObject:hotkey];
        [hotkey enable];
    };

    api[@"runCommand"] = ^void(NSString *path, NSArray *args) {
        NSTask *task = [[NSTask alloc] init];

        [task setArguments:args];
        [task setLaunchPath:path];
        [task launch];

        while([task isRunning]);
    };

    __weak JSContext *weakCtx = ctx;

    ctx[@"require"] = ^void(NSString *path) {
        path = [path stringByStandardizingPath];

        if (![path hasPrefix:@"/"]) {
            NSString *configPath = [ConfigPath stringByResolvingSymlinksInPath];
            NSURL *requirePathUrl = [NSURL URLWithString:path relativeToURL:[NSURL URLWithString:configPath]];
            path = [requirePathUrl absoluteString];
        }

        if (![[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:NULL]) {
            [self showJsException:[NSString stringWithFormat:@"Require: cannot find path %@", path]];
        } else {
            [self addConfigListener:path];

            NSString *javascript = [NSString stringWithContentsOfFile:path
                                                             encoding:NSUTF8StringEncoding
                                                                error:NULL];
            [weakCtx evaluateScript:javascript];
        }
    };

    ctx[@"Window"] = [Window self];
    ctx[@"App"] = [App self];
    ctx[@"Screen"] = [NSScreen self];
    ctx[@"MousePosition"] = [MousePosition self];
    ctx[@"Config"] = [Config self];
}

- (void)showJsException:(id)arg {
    [Alerts show:[NSString stringWithFormat:@"[js exception] %@", arg] duration:3.0];
}

@end
