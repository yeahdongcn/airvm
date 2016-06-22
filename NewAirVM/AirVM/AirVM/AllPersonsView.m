//
//  AllPersonsView.m
//  AirVM
//
//  Created by Zhaokai Yuan on 6/22/16.
//  Copyright © 2016 VMware. All rights reserved.
//

#import "AllPersonsView.h"

@implementation AllPersonsView

- (void)awakeFromNib {
   [self registerForDraggedTypes:[NSArray arrayWithObjects:NSStringPboardType,NSFilenamesPboardType,nil]];
}

- (void)drawRect:(NSRect)dirtyRect {
   [super drawRect:dirtyRect];
   //[[NSColor blueColor] setFill];
   //[NSBezierPath fillRect:self.bounds];
}

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


@end
