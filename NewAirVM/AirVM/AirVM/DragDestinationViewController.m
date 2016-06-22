//
//  DragDestinationViewController.m
//  AirVM
//
//  Created by Zhaokai Yuan on 6/22/16.
//  Copyright © 2016 VMware. All rights reserved.
//

#import "DragDestinationViewController.h"
#import "ConfirmToShareViewController.h"

@interface DragDestinationViewController ()

@end

@implementation DragDestinationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (NSViewController *)confirmToShareViewController {
   if (!_confirmToShareViewController) {
      _confirmToShareViewController = [[ConfirmToShareViewController alloc] initWithNibName:@"ConfirmToShareViewController" bundle:nil];
   }
   return _confirmToShareViewController;
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

- (void)concludeDropOperation:(id<NSDraggingInfo>)sender {
   NSData *data = [[sender draggingPasteboard] dataForType:NSStringPboardType];
   NSString *vmName = [NSKeyedUnarchiver unarchiveObjectWithData:data];
   [self showConfirmToShareVMPopoverWithName:vmName];
}

- (void)showConfirmToShareVMPopoverWithName:(NSString *)vmName {
   [self.confirmToSharePopover showRelativeToRect:self.view.bounds ofView:self.view preferredEdge:NSRectEdgeMinX];
}

#pragma mark NSPopover
- (BOOL)popoverShouldDetach:(NSPopover *)popover {
   return NO;
}

- (BOOL)popoverShouldClose:(NSPopover *)popover {
   return YES;
}

- (void)popoverWillClose:(NSNotification *)notification {
   NSLog(@"popoverWillClose is called.");
}

@end
