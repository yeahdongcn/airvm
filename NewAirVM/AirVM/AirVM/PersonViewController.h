//
//  PersonViewController.h
//  AirVM
//
//  Created by Zhaokai Yuan on 6/18/16.
//  Copyright © 2016 VMware. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "BonjourSDK.h"
#import "PersonView.h"
#import "OpenSharedVMViewController.h"

@interface PersonViewController : NSViewController <AirVMDragDrop>
@property (nonatomic, strong) AirVM *person;
- (instancetype)initWithAirVM:(AirVM *)airVM;
- (NSString *)machineName;
- (void)showPopoverWithOpenAction:(OpenAction)openAction message:(NSString *)message;
- (void)dismissOpenSharedVMPopover;
@property (weak) IBOutlet PersonView *portraitView;
@end
