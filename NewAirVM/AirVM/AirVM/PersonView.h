//
//  PersonView.h
//  AirVM
//
//  Created by Zhaokai Yuan on 6/19/16.
//  Copyright © 2016 Peng Sun. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class SharedVM;
@protocol AirVMDragDrop <NSObject>
- (void)concludeDropOperation:(id<NSDraggingInfo>)sender;
@end

@interface PersonView : NSImageView <NSDraggingDestination>
@property(nonatomic, weak) id<AirVMDragDrop> delegate;
@end
