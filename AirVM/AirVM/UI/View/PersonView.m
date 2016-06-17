//
//  PersonView.m
//  AirVM
//
//  Created by Zhaokai Yuan on 6/17/16.
//  Copyright © 2016 VMware. All rights reserved.
//

#import "PersonView.h"

@implementation PersonView

- (void)awakeFromNib {
   NSLog(@"awakeFromNib of PersonView is called.");
}

- (instancetype)initWithFrame:(NSRect)frameRect {
   self = [super initWithFrame:frameRect];
   if (self) {
      self.wantsLayer = YES;
      [self.layer setBackgroundColor:[[NSColor cyanColor] CGColor]];
      self.layer.cornerRadius = self.frame.size.width / 2;
   }
   return self;
}

//- (void)drawRect:(NSRect)dirtyRect {
//   [[NSColor blueColor] set];
//   NSRectFill(dirtyRect);
//}

@end
