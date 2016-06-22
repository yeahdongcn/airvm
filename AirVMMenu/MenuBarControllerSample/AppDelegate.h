//
//  AppDelegate.h
//  MenuBarControllerSample
//
//  Created by Dmitry Nikolaev on 19.01.15.
//  Copyright (c) 2015 Dmitry Nikolaev. All rights reserved.
//

#import "BonjourSDK.h"
#import <Cocoa/Cocoa.h>

typedef enum : NSInteger {
    Starting,
    Started,
    Stopping,
    Stopped,
} ServiceStartStatus;

@class SharedVM;
@interface AppDelegate : NSObject <NSApplicationDelegate, BSBonjourServerDelegate, BSBonjourClientDelegate>

- (void)sendVM:(SharedVM*) vm;
- (void) sendVMs:(NSArray*) vms;
- (void)refreshService;
- (void)startServer;
- (void)stopServer;
@end


