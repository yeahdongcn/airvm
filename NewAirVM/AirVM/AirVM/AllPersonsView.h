//
//  AllPersonsView.h
//  AirVM
//
//  Created by Zhaokai Yuan on 6/22/16.
//  Copyright © 2016 VMware. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PersonView.h"

@interface AllPersonsView : NSView <NSDraggingDestination>
@property(nonatomic, weak) id<AirVMDragDrop> delegate;
@end
