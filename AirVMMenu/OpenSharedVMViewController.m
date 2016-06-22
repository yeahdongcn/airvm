//
//  OpenSharedVMViewController.m
//  AirVM
//
//  Created by Zhaokai Yuan on 6/20/16.
//  Copyright © 2016 Peng Sun. All rights reserved.
//

#import "OpenSharedVMViewController.h"

@interface OpenSharedVMViewController ()
@property (weak) IBOutlet NSTextField *descriptionTextField;

@end

@implementation OpenSharedVMViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
   self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
   if (self) {
      _didResponse = NO;
   }
   return self;
}

- (void)viewDidAppear {
   [super viewDidAppear];
   self.didResponse = NO;
   if (self.descriptionTextField && self.message) {
      self.descriptionTextField.stringValue = self.message;
   }
}

- (IBAction)onOpenButtonPressed:(id)sender {
   NSLog(@"The Open button on the popover is pressed.");
   self.didResponse = YES;
   self.openAction(YES);
}

- (IBAction)onIgnoreButtonPressed:(id)sender {
   NSLog(@"The Ignore button on the popover is pressed.");
   self.didResponse = YES;
   self.openAction(NO);
}

- (void)setDescription:(NSString *)description {
   self.message = description;
   self.descriptionTextField.stringValue = self.message;
}

@end
