//
//  AppDelegate.h
//  Bonjour-OSX
//
//  Created by Sun Peng on 14-10-11.
//  Copyright (c) 2014年 Peng Sun. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <BonjourSDK/BonjourSDK.h>

typedef enum : NSInteger {
    Starting,
    Started,
    Stopping,
    Stopped,
} ServiceStartStatus;

@interface AppDelegate : NSObject <NSApplicationDelegate, BSBonjourServerDelegate>


@end

