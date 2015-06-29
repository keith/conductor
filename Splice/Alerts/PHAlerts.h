@interface PHAlerts : NSObject

@property (nonatomic) CGFloat alertDisappearDelay;
@property (nonatomic) BOOL alertAnimates;

+ (PHAlerts *)sharedAlerts;

- (void)show:(NSString *)oneLineMsg;
- (void)show:(NSString *)oneLineMsg duration:(CGFloat)duration;

@end
