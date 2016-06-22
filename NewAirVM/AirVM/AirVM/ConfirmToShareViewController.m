//
//  ConfirmToShareViewController.m
//  AirVM
//
//  Created by Zhaokai Yuan on 6/22/16.
//  Copyright © 2016 VMware. All rights reserved.
//

#import "ConfirmToShareViewController.h"

@interface ConfirmToShareViewController ()
@property (weak) IBOutlet NSProgressIndicator *progressIndicator;
@property (weak) IBOutlet NSTextField *shareMessageTextField;
@property (weak) IBOutlet NSButton *cancelButton;
@property (weak) IBOutlet NSButton *shareButton;
@end

@implementation ConfirmToShareViewController

- (void)viewDidLoad {
   [super viewDidLoad];
   self.progressIndicator.hidden = YES;
   self.shareMessageTextField.stringValue = @"Click Open to access the shared VM.";
   [self setUIState:YES];
}

- (void)setUIState:(BOOL)state {
   self.shareMessageTextField.enabled = state;
   self.cancelButton.enabled = state;
   self.shareButton.enabled = state;
}

- (IBAction)onShareButtonPressed:(id)sender {
   [self setUIState:NO];
   if (self.shareAction) {
      self.progressIndicator.hidden = NO;
      [self.progressIndicator startAnimation:nil];
      self.shareAction(YES, self.shareMessageTextField.stringValue);
   }
}
- (IBAction)onCalcelButtonPressed:(id)sender {
   if (self.shareAction) {
      self.shareAction(NO, nil);
   }
}

- (void)controlTextDidChange:(NSNotification *)notification {
   NSTextField *textField = [notification object];
   self.shareMessageTextField.stringValue = [textField stringValue];
}
@end
