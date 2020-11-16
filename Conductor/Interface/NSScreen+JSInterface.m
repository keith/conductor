#include <IOKit/graphics/IOGraphicsLib.h>
#import "NSScreen+JSInterface.h"

@implementation NSScreen (JSInterface)

- (CGRect)frameIncludingDockAndMenu {
    NSScreen *primaryScreen = [[NSScreen screens] objectAtIndex:0];
    CGRect f = [self frame];
    f.origin.y = NSHeight([primaryScreen frame]) - NSHeight(f) - f.origin.y;
    return f;
}

- (CGRect)frameWithoutDockOrMenu {
    NSScreen *primaryScreen = [[NSScreen screens] objectAtIndex:0];
    CGRect f = [self visibleFrame];
    f.origin.y = NSHeight([primaryScreen frame]) - NSHeight(f) - f.origin.y;
    return f;
}

- (NSScreen *)nextScreen {
    NSArray *screens = [NSScreen screens];
    NSUInteger index = [screens indexOfObject:self] + 1;
    if (index == screens.count) {
        index = 0;
    }

    return [screens objectAtIndex:index];
}

- (NSScreen *)previousScreen {
    NSArray *screens = [NSScreen screens];
    NSInteger index = (NSInteger)[screens indexOfObject:self];

    index -= 1;
    if (index == -1) {
        index = (NSInteger)[screens count] - 1;
    }

    return [screens objectAtIndex:(NSUInteger)index];
}

+ (float)getBrightness
{
    io_iterator_t iterator;
    kern_return_t result = IOServiceGetMatchingServices(kIOMasterPortDefault,
                                                        IOServiceMatching("IODisplayConnect"),
                                                        &iterator);

    if (result != kIOReturnSuccess) {
        return -1.0;
    }

    io_object_t service;
    while ((service = IOIteratorNext(iterator))) {
        float level;
        IODisplayGetFloatParameter(service, kNilOptions,
                                   CFSTR(kIODisplayBrightnessKey), &level);
        IOObjectRelease(service);

        return level * 100;
    }

    return -1.0;
}

+ (void)setBrightness:(float)brightness
{
    float userLevel = brightness / 100.0f;
    userLevel = MAX(MIN(userLevel, 1.0f), 0.0f);
    float level = (float)userLevel;

    io_iterator_t iterator;
    kern_return_t result = IOServiceGetMatchingServices(kIOMasterPortDefault,
                                                        IOServiceMatching("IODisplayConnect"),
                                                        &iterator);

    if (result != kIOReturnSuccess) {
        return;
    }

    io_object_t service;
    while ((service = IOIteratorNext(iterator))) {
        IODisplaySetFloatParameter(service, kNilOptions,
                                   CFSTR(kIODisplayBrightnessKey), level);
        IOObjectRelease(service);
    }
}

@end
