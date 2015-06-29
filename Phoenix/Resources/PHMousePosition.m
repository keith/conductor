#import "PHMousePosition.h"

@implementation PHMousePosition

+ (NSPoint)capture {
    CGEventRef ourEvent = CGEventCreate(NULL);
    return CGEventGetLocation(ourEvent);
}

+ (void)restore:(NSPoint)p {
    CGWarpMouseCursorPosition(p);
}

@end
