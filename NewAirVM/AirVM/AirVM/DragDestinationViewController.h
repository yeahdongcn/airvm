//
//  DragDestinationViewController.h
//  AirVM
//
//  Created by Zhaokai Yuan on 6/22/16.
//  Copyright © 2016 VMware. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PersonView.h"

@class ConfirmToShareViewController;
@interface DragDestinationViewController : NSViewController <NSPopoverDelegate, AirVMDragDrop>
@property (nonatomic, strong) NSPopover *confirmToSharePopover;
@property (nonatomic, strong) ConfirmToShareViewController * confirmToShareViewController;
@end
