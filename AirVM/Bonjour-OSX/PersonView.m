//
//  PersonView.m
//  AirVM
//
//  Created by Zhaokai Yuan on 6/19/16.
//  Copyright © 2016 Peng Sun. All rights reserved.
//

#import "PersonView.h"

@implementation PersonView



- (void)drawRect:(NSRect)dirtyRect {
   [super drawRect:dirtyRect];

   // Drawing code here.
}


#pragma mark Dragging Destination

- (NSDragOperation)draggingEntered:(id<NSDraggingInfo>)sender {
   return NSDragOperationAll;
}
//
//- (BOOL)performDragOperation:(id<NSDraggingInfo>)sender {
//   return YES;
//}
//
//- (BOOL)prepareForDragOperation:(id<NSDraggingInfo>)sender {
//   return YES;
//}

- (void)concludeDragOperation:(id<NSDraggingInfo>)sender {
   NSLog(@"Drop action trigured with sender %@.", sender);
   [self alertToOpenSharedVM];
}

- (void)alertToOpenSharedVM {
   NSAlert *alert = [[NSAlert alloc] init];
   [alert addButtonWithTitle:@"Open"];
   [alert addButtonWithTitle:@"Do not Open"];
   [alert setMessageText:@"Open the shared virtual machine?"];
   [alert setInformativeText:@"xxx just shared a virtual machine to you throuth AirVM."];
   [alert setAlertStyle:NSInformationalAlertStyle];
   [alert runModal];
}
@end
