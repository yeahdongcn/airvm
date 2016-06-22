//
//  AllPersonsViewController.m
//  AirVM
//
//  Created by Zhaokai Yuan on 6/22/16.
//  Copyright © 2016 VMware. All rights reserved.
//

#import "AllPersonsViewController.h"
#import "PersonViewController.h"

@interface AllPersonsViewController ()

@end

@implementation AllPersonsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
}

- (NSMutableArray *)personViewControllers {
   if (!_personViewControllers) {
      _personViewControllers = [[NSMutableArray alloc] init];
   }
   return _personViewControllers;
}

- (void)showConfirmToShareVMPopoverWithName:(NSString *)vmName {
   [self.confirmToSharePopover showRelativeToRect:self.view.bounds ofView:self.view preferredEdge:NSRectEdgeMinX];
   
}


@end
