@class MousePosition;

@protocol MousePositionJSExport <JSExport>

+ (NSPoint)capture;
+ (void)restore:(NSPoint)p;

@end

@interface MousePosition : NSObject <MousePositionJSExport>
@end
