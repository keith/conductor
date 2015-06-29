#import "PHConfigLoader.h"

@interface PHAppDelegate : NSObject <NSApplicationDelegate>

@property (nonatomic) IBOutlet NSMenu *statusItemMenu;
@property (nonatomic) NSStatusItem *statusItem;
@property (nonatomic) PHConfigLoader *configLoader;

@end
