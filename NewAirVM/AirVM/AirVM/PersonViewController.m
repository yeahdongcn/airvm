//
//  PersonViewController.m
//  AirVM
//
//  Created by Zhaokai Yuan on 6/18/16.
//  Copyright © 2016 VMware. All rights reserved.
//

#import "PersonViewController.h"
#import "SharedVM.h"
#import "AppDelegate.h"
#import "PersonView.h"
#import "OpenSharedVMViewController.h"
#import "ConfirmToShareViewController.h"

@interface PersonViewController () <NSPopoverDelegate>


@property (weak) IBOutlet NSTextField *nameLabel;
@property (nonatomic, strong) NSPopover *openSharedVMPopover;
@property (nonatomic, strong) NSPopover *confirmToSharePopover;
@property (nonatomic, strong) OpenSharedVMViewController *openSharedVMViewController;
@property (nonatomic, strong) ConfirmToShareViewController * confirmToShareViewController;
@property (nonatomic, strong) NSWindow *detachedWindow;

@end

@implementation PersonViewController

- (instancetype)initWithAirVM:(AirVM *)airVM {
   self = [super initWithNibName:@"PersonViewController" bundle:nil];
   if (self) {
      _person = airVM;
   }
   return self;
}

- (NSString *)machineName {
   return self.person.machineName;
}

- (NSViewController *)openSharedVMViewController {
   if (!_openSharedVMViewController) {
      _openSharedVMViewController = [[OpenSharedVMViewController alloc] initWithNibName:@"OpenSharedVMViewController" bundle:nil];
   }
   return _openSharedVMViewController;
}
- (NSViewController *)confirmToShareViewController {
   if (!_confirmToShareViewController) {
      _confirmToShareViewController = [[ConfirmToShareViewController alloc] initWithNibName:@"ConfirmToShareViewController" bundle:nil];
   }
   return _confirmToShareViewController;
}

- (NSWindow *)detachedWindow {
   if (!_detachedWindow) {
      NSRect rect = self.openSharedVMViewController.view.bounds;
      NSUInteger styleMask = NSTitledWindowMask + NSClosableWindowMask;
      _detachedWindow = [[NSWindow alloc] initWithContentRect:rect styleMask:styleMask backing:NSBackingStoreBuffered defer:YES];
      _detachedWindow.contentViewController = self.openSharedVMViewController;
   }
   return _detachedWindow;
}

- (NSPopover *)openSharedVMPopover {
   if (!_openSharedVMPopover) {
      _openSharedVMPopover = [[NSPopover alloc] init];
      _openSharedVMPopover.contentViewController = self.openSharedVMViewController;
      _openSharedVMPopover.behavior = NSPopoverBehaviorSemitransient;
      _openSharedVMPopover.delegate = self;
      _openSharedVMPopover.appearance = [NSAppearance appearanceNamed:NSAppearanceNameVibrantLight];
   }
   return _openSharedVMPopover;
}

- (NSPopover *)confirmToSharePopover {
   if (!_confirmToSharePopover) {
      _confirmToSharePopover = [[NSPopover alloc] init];
      _confirmToSharePopover.contentViewController = self.confirmToShareViewController;
      _confirmToSharePopover.behavior = NSPopoverBehaviorSemitransient;
      _confirmToSharePopover.delegate = self;
      _confirmToSharePopover.appearance = [NSAppearance appearanceNamed:NSAppearanceNameVibrantLight];
   }
   return _confirmToSharePopover;
}

- (void)viewDidLoad {
   [super viewDidLoad];
   self.portraitView.image = [NSImage imageNamed:@"person"];
   self.nameLabel.stringValue = self.person.machineName;
   self.portraitView.delegate = self;
}

#pragma mark AirVMDrop

- (void)concludeDropOperation:(id<NSDraggingInfo>)sender {
   NSData *data = [[sender draggingPasteboard] dataForType:NSStringPboardType];
   NSString *vmName = [NSKeyedUnarchiver unarchiveObjectWithData:data];
   [self showConfirmToShareVMPopoverWithName:vmName];
}


#pragma mark NSPopover

- (BOOL)popoverShouldDetach:(NSPopover *)popover {
   return NO;
}

- (NSWindow *)detachableWindowForPopover:(NSPopover *)popover {
   return self.detachedWindow;
}

- (BOOL)popoverShouldClose:(NSPopover *)popover {
   if (popover == self.openSharedVMPopover) {
      return self.openSharedVMViewController.didResponse;
   }
//   if (popover == self.confirmToSharePopover) {
//      return NO;
//   }
   return YES;
}

- (void)popoverWillClose:(NSNotification *)notification {
   NSLog(@"popoverWillClose is called.");
}

- (void)showOpenSharedVMPopover {
   [self.openSharedVMPopover showRelativeToRect:self.portraitView.bounds ofView:self.portraitView preferredEdge:NSRectEdgeMaxY];
}

- (void)showConfirmToShareVMPopoverWithName:(NSString *)vmName {
   [self.confirmToSharePopover showRelativeToRect:self.portraitView.bounds ofView:self.portraitView preferredEdge:NSRectEdgeMinX];

   __weak PersonViewController *weakSelf = self;
   self.confirmToShareViewController.shareAction = ^(BOOL share, NSString *message) {
      if (share) {
         [[SharedVMMgr sharedInstance] startSharedVM:vmName andCompletionBlock:^(SharedVM *vm) {
            vm.netService = weakSelf.person.netService;
            vm.message = message;
            [(AppDelegate *)([[NSApplication sharedApplication] delegate]) sendVM:vm];
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

- (void)showPopoverWithOpenAction:(OpenAction)openAction message:(NSString *)message{

   if ([self.openSharedVMPopover.contentViewController isKindOfClass:[OpenSharedVMViewController class]]) {
      OpenSharedVMViewController *osvvc = ((OpenSharedVMViewController *)(self.openSharedVMPopover.contentViewController));
      osvvc.openAction = openAction;
      osvvc.message = message;
   }

   [self showOpenSharedVMPopover];
}

- (void)dismissOpenSharedVMPopover {
   [self.openSharedVMPopover close];
}

//test button
- (IBAction)onButtonClicked:(id)sender {
   [self showOpenSharedVMPopover];
}
@end
