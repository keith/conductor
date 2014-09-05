//
//  MyWindow.h
//  Zephyros
//
//  Created by Steven Degutis on 2/28/13.
//  Copyright (c) 2013 Steven Degutis. All rights reserved.
//

@class PHApp;
@class PHWindow;

@protocol PHWindowJSExport <JSExport>

+ (NSArray *)allWindows;
+ (NSArray *)visibleWindows;
+ (PHWindow *)focusedWindow;
+ (NSArray *)visibleWindowsMostRecentFirst;
- (NSArray *)otherWindowsOnSameScreen;
- (NSArray *)otherWindowsOnAllScreens;

- (CGRect)frame;
- (CGPoint)topLeft;
- (CGSize)size;
- (void)setFrame:(CGRect)frame;
- (void)setTopLeft:(CGPoint)thePoint;
- (void)setSize:(CGSize)theSize;
- (void)maximize;
- (void)minimize;
- (void)unMinimize;

- (NSScreen *)screen;
- (PHApp *)app;

- (BOOL)focusWindow;
- (NSArray *)windowsToWest;
- (NSArray *)windowsToEast;
- (NSArray *)windowsToNorth;
- (NSArray *)windowsToSouth;
- (void)focusWindowLeft;
- (void)focusWindowRight;
- (void)focusWindowUp;
- (void)focusWindowDown;

- (NSString *)title;
- (BOOL)isNormalWindow;
- (BOOL)isWindowMinimized;

@end

@interface PHWindow : NSObject <PHWindowJSExport>

- (id)initWithElement:(AXUIElementRef)win;

@end
