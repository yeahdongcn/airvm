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


@interface PersonViewController () <NSPopoverDelegate>

@property (nonatomic, strong) AirVM *person;

@property (weak) IBOutlet PersonView *portraitView;
@property (weak) IBOutlet NSTextField *nameLabel;
@property (nonatomic, strong) NSPopover *popover;
@property (nonatomic, strong) OpenSharedVMViewController *contentViewController;
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

- (NSViewController *)contentViewController {
   if (!_contentViewController) {
      _contentViewController = [[OpenSharedVMViewController alloc] initWithNibName:@"OpenSharedVMViewController" bundle:nil];
   }
   return _contentViewController;
}

- (NSWindow *)detachedWindow {
   if (!_detachedWindow) {
      NSRect rect = self.contentViewController.view.bounds;
      NSUInteger styleMask = NSTitledWindowMask + NSClosableWindowMask;
      _detachedWindow = [[NSWindow alloc] initWithContentRect:rect styleMask:styleMask backing:NSBackingStoreBuffered defer:YES];
      _detachedWindow.contentViewController = self.contentViewController;
   }
   return _detachedWindow;
}

- (NSPopover *)popover {
   if (!_popover) {
      _popover = [[NSPopover alloc] init];
      _popover.contentViewController = self.contentViewController;
      _popover.behavior = NSPopoverBehaviorSemitransient;
      _popover.delegate = self;
      _popover.appearance = [NSAppearance appearanceNamed:NSAppearanceNameVibrantLight];
   }
   return _popover;
}

- (void)viewDidLoad {
   [super viewDidLoad];
   self.portraitView.image = [NSImage imageNamed:@"person"];
   self.portraitView.wantsLayer = YES;
   self.portraitView.layer.cornerRadius = self.portraitView.frame.size.width / 2;
   self.nameLabel.stringValue = self.person.machineName;
   self.portraitView.delegate = self;
}

#pragma mark AirVMDrop



- (void)concludeDropOperation:(id<NSDraggingInfo>)sender {
   NSData *data = [[sender draggingPasteboard] dataForType:NSStringPboardType];
   NSString *vmName = [NSKeyedUnarchiver unarchiveObjectWithData:data];

   
   [[SharedVMMgr sharedInstance] startSharedVM:vmName andCompletionBlock:^(SharedVM *vm) {
      vm.netService = self.person.netService;
      [(AppDelegate *)([[NSApplication sharedApplication] delegate]) sendVM:vm];
   }];
}


#pragma mark NSPopover

- (BOOL)popoverShouldDetach:(NSPopover *)popover {
   return NO;
}

- (NSWindow *)detachableWindowForPopover:(NSPopover *)popover {
   return self.detachedWindow;
}

- (BOOL)popoverShouldClose:(NSPopover *)popover {
   if (popover == self.popover) {
      return self.contentViewController.didResponse;
   }
   return YES;
}

- (void)popoverWillClose:(NSNotification *)notification {
   NSLog(@"popoverWillClose is called.");
}

- (void)showPopover {
   [self.popover showRelativeToRect:self.portraitView.bounds ofView:self.portraitView preferredEdge:NSRectEdgeMaxY];
}

- (void)showPopoverWithOpenAction:(OpenAction)openAction {
   [self showPopover];
   if ([self.popover.contentViewController isKindOfClass:[OpenSharedVMViewController class]]) {
      ((OpenSharedVMViewController *)(self.popover.contentViewController)).openAction = openAction;
   }
}

- (void)dismissPopover {
   [self.popover close];
}

//test button
- (IBAction)onButtonClicked:(id)sender {
   [self showPopover];
}
@end
