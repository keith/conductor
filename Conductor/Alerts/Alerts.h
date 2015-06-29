@interface Alerts : NSObject

@property (nonatomic) CGFloat alertDisappearDelay;
@property (nonatomic) BOOL alertAnimates;

+ (Alerts *)sharedAlerts;

- (void)show:(NSString *)oneLineMsg;
- (void)show:(NSString *)oneLineMsg duration:(CGFloat)duration;

@end
