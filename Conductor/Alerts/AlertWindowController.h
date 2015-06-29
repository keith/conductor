@class AlertWindowController;

@protocol AlertDelegate <NSObject>

- (void)alertClosed:(AlertWindowController *)alert;

@end

@interface AlertWindowController : NSWindowController

@property (weak) id<AlertDelegate> delegate;

- (void)show:(NSString *)message duration:(CGFloat)duration YAdjustment:(CGFloat)adjustment;

@end
