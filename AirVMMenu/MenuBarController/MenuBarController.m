//
//  MenuBarController.m
//  MenuBarController
//
//  Created by Dmitry Nikolaev on 27.10.14.
//  Copyright (c) 2014 Dmitry Nikolaev. All rights reserved.
//

#import "MenuBarController.h"
#import "StatusItemButton.h"

@interface MenuBarController () <StatusItemButtonDelegate>

@property (strong, nonatomic) NSStatusItem *statusItem;

@end

@implementation MenuBarController

- (instancetype) initWithImage: (NSImage *) image menu: (NSMenu *) menu {
    self = [super init];
    if (self) {
        self.image = image;
        self.menu = menu;
    }
    return self;
}

- (void) setImage: (NSImage *) image {
    _image = image;
    
    if ([self isYosemite]) {
        self.statusItem.button.image = image;
    } else {
        StatusItemButton *button = (StatusItemButton *)self.statusItem.view;
        button.image = image;
    }
}

- (NSView *) statusItemView {
    
    if ([self isYosemite]) {
        return self.statusItem.button;
    } else {
        return self.statusItem.view;
    }
    
}

- (void) showStatusItem {
    if (!self.statusItem) {
        self.statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSSquareStatusItemLength];
        if ([self isYosemite]) {
            [self initStatusItem10];
        } else {
            [self initStatusItem];
        }
    }
}

- (void) hideStatusItem {
    if (self.statusItem) {
        [[NSStatusBar systemStatusBar] removeStatusItem:self.statusItem];
        self.statusItem = nil;
    }
}

// Yosemite

- (void) initStatusItem10 {
    
     self.statusItem.button.image = self.image;
     self.statusItem.button.appearsDisabled = NO;
     self.statusItem.button.target = self;
     self.statusItem.button.action = @selector(leftClick10:);
     
     __unsafe_unretained MenuBarController *weakSelf = self;
     
     [NSEvent addLocalMonitorForEventsMatchingMask:
     (NSRightMouseDownMask | NSAlternateKeyMask | NSLeftMouseDownMask) handler:^(NSEvent *incomingEvent) {
     
     if (incomingEvent.type == NSLeftMouseDown) {
         weakSelf.statusItem.menu = nil;
     }
     
     if (incomingEvent.type == NSRightMouseDown || [incomingEvent modifierFlags] & NSAlternateKeyMask) {
         if (weakSelf.handler) {
             weakSelf.handler(NO);
         }
         [weakSelf.delegate menuBarControllerStatusChanged:NO];
         weakSelf.statusItem.menu = weakSelf.menu;
     }
     
     return incomingEvent;
     }];
}

- (IBAction)leftClick10:(id)sender {
    if (self.handler) {
        self.handler(YES);
    }
    [self.delegate menuBarControllerStatusChanged:YES];
}

// Before Yosemite

- (void) initStatusItem {
    self.statusItem.highlightMode = YES;
    StatusItemButton *button = [[StatusItemButton alloc] initWithImage:self.image];
    button.delegate = self;
    [self.statusItem setView:button];
}

- (void) statusItemButtonLeftClick: (StatusItemButton *) button {
    if (self.handler) {
        self.handler(YES);
    }
    [self.delegate menuBarControllerStatusChanged:YES];
}

- (void) statusItemButtonRightClick: (StatusItemButton *) button {
    if (self.handler) {
        self.handler(NO);
    }
    [self.delegate menuBarControllerStatusChanged:NO];
    [self.statusItem popUpStatusItemMenu:self.menu];
}

#pragma mark - Private

- (BOOL) isYosemite {
    return [self.statusItem respondsToSelector:@selector(button)];
}

@end
