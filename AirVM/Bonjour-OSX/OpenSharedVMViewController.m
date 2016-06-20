//
//  OpenSharedVMViewController.m
//  AirVM
//
//  Created by Zhaokai Yuan on 6/20/16.
//  Copyright © 2016 Peng Sun. All rights reserved.
//

#import "OpenSharedVMViewController.h"

@interface OpenSharedVMViewController ()

@end

@implementation OpenSharedVMViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
   self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
   if (self) {
      _didResponse = NO;
   }
   return self;
}

- (IBAction)onOpenButtonPressed:(id)sender {
   NSLog(@"The Open button on the popover is pressed.");
   self.didResponse = YES;
}

- (IBAction)onIgnoreButtonPressed:(id)sender {
   NSLog(@"The Ignore button on the popover is pressed.");
   self.didResponse = YES;
}

@end
