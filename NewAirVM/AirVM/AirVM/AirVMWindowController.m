//
//  AirVMWindowController.m
//  AirVM
//
//  Created by Zhaokai Yuan on 6/21/16.
//  Copyright © 2016 VMware. All rights reserved.
//

#import "AirVMWindowController.h"
#import "WAYAppStoreWindow.h"

@interface AirVMWindowController ()

@end

@implementation AirVMWindowController

- (void)windowDidLoad {
    [super windowDidLoad];
   WAYAppStoreWindow * window = self.window;
   window.titleBarHeight = 100;
}

@end
