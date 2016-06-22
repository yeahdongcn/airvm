//
//  AllPersonsViewController.m
//  AirVM
//
//  Created by Zhaokai Yuan on 6/22/16.
//  Copyright © 2016 VMware. All rights reserved.
//

#import "AllPersonsViewController.h"
#import "PersonViewController.h"
#import "ConfirmToShareViewController.h"
#import "SharedVM.h"
#import "AppDelegate.h"

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

   __weak AllPersonsViewController *weakSelf = self;
   self.confirmToShareViewController.shareAction = ^(BOOL share, NSString *message) {
      if (share) {

         [[SharedVMMgr sharedInstance] startSharedVM:vmName andCompletionBlock:^(SharedVM *vm) {
            vm.message = message;

            NSMutableArray * vms = [[NSMutableArray alloc] init];
            for (PersonViewController *pvc in weakSelf.personViewControllers) {
               if (![pvc.machineName isEqualToString:[[NSHost currentHost] localizedName]]) {
                  SharedVM *newVM = [[SharedVM alloc] init];
                  newVM.vmName = vmName;
                  newVM.message = message;
                  newVM.netService = pvc.person.netService;
                  newVM.vncPort = vm.vncPort;
                  [vms addObject:newVM];
               }
            }

            [(AppDelegate *)([[NSApplication sharedApplication] delegate]) sendVMs:vms];
            dispatch_async(dispatch_get_main_queue(), ^{
               [weakSelf.confirmToSharePopover close];
            });

         }];
      } else {
         dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf.confirmToSharePopover close];
         });
      }
      
   };
}


@end
