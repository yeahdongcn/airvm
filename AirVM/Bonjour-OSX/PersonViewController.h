//
//  PersonViewController.h
//  AirVM
//
//  Created by Zhaokai Yuan on 6/18/16.
//  Copyright © 2016 VMware. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <BonjourSDK/BonjourSDK.h>
#import "PersonView.h"

@interface PersonViewController : NSViewController <AirVMDragDrop>

- (instancetype)initWithAirVM:(AirVM *)airVM;

@end
