//
//  MenuBarController.h
//  MenuBarController
//
//  Created by Dmitry Nikolaev on 27.10.14.
//  Copyright (c) 2014 Dmitry Nikolaev. All rights reserved.
//

#import <Cocoa/Cocoa.h>

//! Project version number for MenuBarController.
FOUNDATION_EXPORT double MenuBarControllerVersionNumber;

//! Project version string for MenuBarController.
FOUNDATION_EXPORT const unsigned char MenuBarControllerVersionString[];

// In this header, you should import all the public headers of your framework using statements like #import <MenuBarController/PublicHeader.h>

typedef void(^MenuBarControllerActionBlock)(BOOL active);


@protocol MenuBarControllerDelegate

- (void) menuBarControllerStatusChanged: (BOOL) active;

@end


@interface MenuBarController : NSObject

@property (strong) NSMenu *menu;
@property (copy) MenuBarControllerActionBlock handler;
@property (strong, nonatomic) NSImage *image;
@property (unsafe_unretained, nonatomic) id<MenuBarControllerDelegate> delegate;

- (instancetype) initWithImage: (NSImage *) image menu: (NSMenu *) menu;
- (NSView *) statusItemView;
- (void) showStatusItem;
- (void) hideStatusItem;

@end


