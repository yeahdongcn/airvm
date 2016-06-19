//
//  PersonClusterView.m
//  AirVM
//
//  Created by Zhaokai Yuan on 6/17/16.
//  Copyright © 2016 VMware. All rights reserved.
//

#import "PersonClusterView.h"

@implementation PersonClusterView

+ (NSArray *)locationOfPersonsWithNumber:(NSInteger)numOfPersons {
   return nil;
}

- (void)drawRect:(NSRect)dirtyRect {
   [super drawRect:dirtyRect];

   CGPoint centerPoint = CGPointMake(self.bounds.size.width/2, 100);

   CGContextRef airDropCtx = [[NSGraphicsContext currentContext] graphicsPort];
   CGContextSetLineWidth(airDropCtx, 1.5);
   [[NSColor colorWithRed:0/255.0 green:121/255.0 blue:255/255.0 alpha:1.0] setStroke];
   int numberOfCircles = 8;
   CGFloat angleOffset = M_PI * 2 / 25;
   for (int i=0; i<numberOfCircles; i++) {
      CGFloat radius = 5 * (i+1);
      CGContextAddArc(airDropCtx, centerPoint.x, centerPoint.y, radius, - M_PI /2 + angleOffset, M_PI * 3/2 - angleOffset, 0);
      CGContextStrokePath(airDropCtx);
   }


   [[NSColor lightGrayColor] setStroke];
   CGContextRef ctx = [[NSGraphicsContext  currentContext] graphicsPort];

   CGContextSetLineWidth(ctx, 0.25);
   for (int i=0; i<10; i++) {
      CGFloat radius = 75 * (i+1);
      CGContextAddArc(ctx, centerPoint.x, centerPoint.y, radius, 0, M_PI * 2, 0);
      CGContextStrokePath(ctx);
   }
}

@end
