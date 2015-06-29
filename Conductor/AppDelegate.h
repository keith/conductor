#import "ConfigLoader.h"

@interface AppDelegate : NSObject <NSApplicationDelegate>

@property (nonatomic) IBOutlet NSMenu *statusItemMenu;
@property (nonatomic) NSStatusItem *statusItem;
@property (nonatomic) ConfigLoader *configLoader;

@end
