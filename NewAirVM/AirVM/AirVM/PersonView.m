//
//  PersonView.m
//  AirVM
//
//  Created by Zhaokai Yuan on 6/19/16.
//  Copyright © 2016 Peng Sun. All rights reserved.
//

#import "PersonView.h"
#import "SharedVM.h"
#import "AppDelegate.h"

@implementation PersonView

- (instancetype)initWithFrame:(NSRect)frameRect {
   self = [super initWithFrame:frameRect];
   if (self) {
      [self registerForDraggedTypes:[NSArray arrayWithObjects:NSStringPboardType,NSFilenamesPboardType,nil]];
   }
   return self;
}


#pragma mark Dragging Destination

- (NSDragOperation)draggingEntered:(id<NSDraggingInfo>)sender {
   return NSDragOperationEvery;
}

- (BOOL)performDragOperation:(id<NSDraggingInfo>)sender {
   return YES;
}

- (BOOL)prepareForDragOperation:(id<NSDraggingInfo>)sender {
   return YES;
}

- (void)concludeDragOperation:(id<NSDraggingInfo>)sender {
   NSLog(@"Drop action trigured with sender %@.", sender);
   if (self.delegate) {
      [self.delegate concludeDropOperation:sender];
   }
}

//// test code
//- (void)alertToOpenSharedVM:(SharedVM *)vm {
//   NSAlert *alert = [[NSAlert alloc] init];
//   [alert addButtonWithTitle:@"Share"];
//   [alert addButtonWithTitle:@"Cancel"];
//   [alert setMessageText:@"To share your virtual machine?"];
//   [alert setInformativeText:[NSString stringWithFormat:@"Share the %@ virtual machine to %@", vm, self]];
//   [alert setAlertStyle:NSInformationalAlertStyle];
//   [alert runModal];
//}
@end
