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
@property (weak) IBOutlet NSButton *refreshButton;

@end

@implementation AirVMTitleBarViewController

- (void)viewDidLoad {
   [super viewDidLoad];
   self.refreshButton.enabled = YES;
    // Do view setup here.
}

- (IBAction)onRefreshButtonPressed:(id)sender {
   [(AppDelegate *)([[NSApplication sharedApplication] delegate]) refreshService];
}
- (IBAction)onServiceButtonPressed:(NSButton *)sender {
   NSLog(@"Service button pressed with %d", sender.state);
   if (sender.state == NSOnState) {
       [[[NSApplication sharedApplication] delegate] startServer];
       self.refreshButton.enabled = YES;
//      [sender setState:NSOffState];
   } else {
       self.refreshButton.enabled = NO;
       [[[NSApplication sharedApplication] delegate] stopServer];
//      [sender setState:NSOnState];
   }
}

@end
