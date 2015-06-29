@interface Alerts : NSObject

@property (nonatomic) CGFloat alertDisappearDelay;

+ (Alerts *)sharedAlerts;

- (void)show:(NSString *)oneLineMsg;
- (void)show:(NSString *)oneLineMsg duration:(CGFloat)duration;

@end
