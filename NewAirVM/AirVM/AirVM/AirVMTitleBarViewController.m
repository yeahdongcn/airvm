//
//  AirVMTitleBarViewController.m
//  AirVM
//
//  Created by Zhaokai Yuan on 6/21/16.
//  Copyright © 2016 VMware. All rights reserved.
//

#import "AirVMTitleBarViewController.h"
#import "AppDelegate.h"
@interface AirVMTitleBarViewController ()

@end

@implementation AirVMTitleBarViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
}
- (IBAction)onRefreshButtonPressed:(id)sender {
   [(AppDelegate *)([[NSApplication sharedApplication] delegate]) refreshService];
}
- (IBAction)onServiceButtonPressed:(NSButton *)sender {
   NSLog(@"Service button pressed with %d", sender.state);
//   if (sender.state == NSOnState) {
//      [sender setState:NSOffState];
//   } else {
//      [sender setState:NSOnState];
//   }
}

@end
