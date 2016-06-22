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

@end

@implementation ConfirmToShareViewController

- (void)viewDidLoad {
   [super viewDidLoad];
   self.progressIndicator.hidden = YES;
}
- (IBAction)onShareButtonPressed:(id)sender {
   if (self.shareAction) {
      self.progressIndicator.hidden = NO;
      self.shareAction(YES);
   }
}
- (IBAction)onCalcelButtonPressed:(id)sender {
   if (self.shareAction) {
      self.shareAction(NO);
   }
}

@end
