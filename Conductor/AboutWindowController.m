#import "AboutWindowController.h"
#import "OpenAtLogin.h"

@interface AboutWindowController ()

@property (nonatomic) NSButton *openAtLoginCheckbox;

@end

@implementation AboutWindowController

+ (instancetype)sharedController {
    static AboutWindowController *controller;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        controller = [[AboutWindowController alloc] init];
    });
    return controller;
}

- (instancetype)init {
    NSWindow *window = [[NSWindow alloc] initWithContentRect:NSMakeRect(0, 0, 300, 220)
                                                   styleMask:NSWindowStyleMaskTitled | NSWindowStyleMaskClosable
                                                     backing:NSBackingStoreBuffered
                                                       defer:NO];
    window.title = @"About Conductor";
    [window center];

    self = [super initWithWindow:window];
    if (self) {
        [self setupContent];
    }
    return self;
}

- (void)setupContent {
    NSView *contentView = self.window.contentView;

    NSBundle *bundle = [NSBundle mainBundle];
    NSImage *appIcon = [NSApp applicationIconImage];
    NSString *appName = [bundle objectForInfoDictionaryKey:@"CFBundleName"];
    NSString *version = [bundle objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    NSString *copyright = [bundle objectForInfoDictionaryKey:@"NSHumanReadableCopyright"];

    NSImageView *iconView = [NSImageView imageViewWithImage:appIcon];
    iconView.translatesAutoresizingMaskIntoConstraints = NO;
    [contentView addSubview:iconView];

    NSTextField *nameLabel = [NSTextField labelWithString:appName];
    nameLabel.translatesAutoresizingMaskIntoConstraints = NO;
    nameLabel.font = [NSFont boldSystemFontOfSize:14];
    nameLabel.alignment = NSTextAlignmentCenter;
    [contentView addSubview:nameLabel];

    NSTextField *versionLabel = [NSTextField labelWithString:[NSString stringWithFormat:@"Version %@", version]];
    versionLabel.translatesAutoresizingMaskIntoConstraints = NO;
    versionLabel.font = [NSFont systemFontOfSize:11];
    versionLabel.textColor = [NSColor secondaryLabelColor];
    versionLabel.alignment = NSTextAlignmentCenter;
    [contentView addSubview:versionLabel];

    NSTextField *copyrightLabel = [NSTextField labelWithString:copyright];
    copyrightLabel.translatesAutoresizingMaskIntoConstraints = NO;
    copyrightLabel.font = [NSFont systemFontOfSize:11];
    copyrightLabel.textColor = [NSColor secondaryLabelColor];
    copyrightLabel.alignment = NSTextAlignmentCenter;
    [contentView addSubview:copyrightLabel];

    self.openAtLoginCheckbox = [NSButton checkboxWithTitle:@"Open at Login" target:self action:@selector(toggleOpenAtLogin:)];
    self.openAtLoginCheckbox.translatesAutoresizingMaskIntoConstraints = NO;
    [contentView addSubview:self.openAtLoginCheckbox];

    [NSLayoutConstraint activateConstraints:@[
        [iconView.topAnchor constraintEqualToAnchor:contentView.topAnchor constant:20],
        [iconView.centerXAnchor constraintEqualToAnchor:contentView.centerXAnchor],
        [iconView.widthAnchor constraintEqualToConstant:64],
        [iconView.heightAnchor constraintEqualToConstant:64],

        [nameLabel.topAnchor constraintEqualToAnchor:iconView.bottomAnchor constant:10],
        [nameLabel.centerXAnchor constraintEqualToAnchor:contentView.centerXAnchor],

        [versionLabel.topAnchor constraintEqualToAnchor:nameLabel.bottomAnchor constant:4],
        [versionLabel.centerXAnchor constraintEqualToAnchor:contentView.centerXAnchor],

        [copyrightLabel.topAnchor constraintEqualToAnchor:versionLabel.bottomAnchor constant:4],
        [copyrightLabel.centerXAnchor constraintEqualToAnchor:contentView.centerXAnchor],

        [self.openAtLoginCheckbox.topAnchor constraintEqualToAnchor:copyrightLabel.bottomAnchor constant:16],
        [self.openAtLoginCheckbox.centerXAnchor constraintEqualToAnchor:contentView.centerXAnchor],
    ]];
}

- (void)showWindow {
    self.openAtLoginCheckbox.state = [OpenAtLogin opensAtLogin] ? NSControlStateValueOn : NSControlStateValueOff;
    [NSApp activateIgnoringOtherApps:YES];
    [self.window center];
    [self.window makeKeyAndOrderFront:nil];
}

- (void)toggleOpenAtLogin:(NSButton *)sender {
    [OpenAtLogin setOpensAtLogin:sender.state == NSControlStateValueOn];
}

@end
