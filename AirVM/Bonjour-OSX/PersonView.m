//
//  PersonView.m
//  AirVM
//
//  Created by Zhaokai Yuan on 6/19/16.
//  Copyright © 2016 Peng Sun. All rights reserved.
//

#import "PersonView.h"
#import "SharedVM.h"

@implementation PersonView

- (instancetype)initWithFrame:(NSRect)frameRect {
   self = [super initWithFrame:frameRect];
   if (self) {
      [self registerForDraggedTypes:[NSArray arrayWithObjects:NSStringPboardType,NSFilenamesPboardType,nil]];
   }
   return self;
}

- (void)drawRect:(NSRect)dirtyRect {
   [super drawRect:dirtyRect];

   // Drawing code here.
}


#pragma mark Dragging Destination

- (NSDragOperation)draggingEntered:(id<NSDraggingInfo>)sender {
   return NSDragOperationAll;
}

- (BOOL)performDragOperation:(id<NSDraggingInfo>)sender {
   return YES;
}

- (BOOL)prepareForDragOperation:(id<NSDraggingInfo>)sender {
   return YES;
}

- (void)concludeDragOperation:(id<NSDraggingInfo>)sender {
   NSLog(@"Drop action trigured with sender %@.", sender);
   NSData *data = [[sender draggingPasteboard] dataForType:NSStringPboardType];
   SharedVM *vm = [NSKeyedUnarchiver unarchiveObjectWithData:data];
   [self alertToOpenSharedVM:vm];
}

// test code
- (void)alertToOpenSharedVM:(SharedVM *)vm {
   NSAlert *alert = [[NSAlert alloc] init];
   [alert addButtonWithTitle:@"Share"];
   [alert addButtonWithTitle:@"Cancel"];
   [alert setMessageText:@"To share your virtual machine?"];
   [alert setInformativeText:[NSString stringWithFormat:@"Share the %@ virtual machine to %@", vm, self]];
   [alert setAlertStyle:NSInformationalAlertStyle];
   [alert runModal];
}
@end
