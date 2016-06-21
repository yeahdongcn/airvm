//
//  AirVMWindowController.m
//  AirVM
//
//  Created by Zhaokai Yuan on 6/21/16.
//  Copyright © 2016 VMware. All rights reserved.
//

#import "AirVMWindowController.h"
#import "WAYAppStoreWindow.h"
#import "AirVMTitleBarViewController.h"

@interface AirVMWindowController ()
@property (nonatomic, strong) AirVMTitleBarViewController * airVMTBVC;
@end

@implementation AirVMWindowController

- (void)windowDidLoad {
    [super windowDidLoad];
   WAYAppStoreWindow * window = self.window;
   //window.titleBarView
   window.titleBarHeight = 70;
   window.centerTrafficLightButtons = NO;
   window.verticallyCenterTitle = YES;
   window.bottomBarHeight = 24;

   self.airVMTBVC = [[AirVMTitleBarViewController alloc] initWithNibName:@"AirVMTitleBarViewController" bundle:nil];
   NSView * titleView = self.airVMTBVC.view;
   titleView.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
   [window.titleBarView addSubview:titleView];
}


@end
