@class PHMousePosition;

@protocol PHMousePositionJSExport <JSExport>

+ (NSPoint)capture;
+ (void)restore:(NSPoint)p;

@end

@interface PHMousePosition : NSObject <PHMousePositionJSExport>
@end
