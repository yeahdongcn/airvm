//
//  PersonClusterView.m
//  AirVM
//
//  Created by Zhaokai Yuan on 6/17/16.
//  Copyright © 2016 VMware. All rights reserved.
//

#import "PersonClusterView.h"

#define NUM_CIRCLES 15
#define CENTER_POINT_Y 100
#define RADIUS 75


@implementation PersonClusterView


- (NSArray *)locationOfPersonsWithNumber:(NSInteger)numOfPersons {
   if (numOfPersons <= 0) {
      return nil;
   }
   NSArray *ret = [[NSArray alloc] init];
   CGFloat width = self.bounds.size.width;
   CGFloat height = self.bounds.size.height;
   NSMutableArray * array = [[NSMutableArray alloc] init];
   switch (numOfPersons) {
      case 1:
         ret = [NSArray arrayWithObjects:[self pointWithX:width/2 Y:(CENTER_POINT_Y + 2 * RADIUS)], nil];
         break;
      case 2:
         ret = [NSArray arrayWithObjects:
                  [self pointWithX:(width/2 - 2 * RADIUS * cos(M_PI_4)) Y:(CENTER_POINT_Y + 2 * RADIUS * cos(M_PI_4))],
                  [self pointWithX:(width/2 + 2 * RADIUS * cos(M_PI_4)) Y:(CENTER_POINT_Y + 2 * RADIUS * cos(M_PI_4))], nil];
         break;
      case 3:
         ret = [NSArray arrayWithObjects:
                  [self pointWithX:width/2 Y:(CENTER_POINT_Y + 2 * RADIUS)],
                  [self pointWithX:(width/2 - 2 * RADIUS * cos(M_PI_4)) Y:(CENTER_POINT_Y + 2 * RADIUS * cos(M_PI_4))],
                  [self pointWithX:(width/2 + 2 * RADIUS * cos(M_PI_4)) Y:(CENTER_POINT_Y + 2 * RADIUS * cos(M_PI_4))], nil];
         break;
      case 4:
         ret = [NSArray arrayWithObjects:
                  [self pointWithX:width/2 Y:(CENTER_POINT_Y + 2 * RADIUS)],
                  [self pointWithX:(width/2 - 2 * RADIUS * cos(M_PI_4)) Y:(CENTER_POINT_Y + 2 * RADIUS * cos(M_PI_4))],
                  [self pointWithX:(width/2 + 2 * RADIUS * cos(M_PI_4)) Y:(CENTER_POINT_Y + 2 * RADIUS * cos(M_PI_4))],
                  [self pointWithX:(width/2) Y:(CENTER_POINT_Y + 4 * RADIUS)], nil];
         break;
      case 5:
         ret = [NSArray arrayWithObjects:
                [self pointWithX:width/2 Y:(CENTER_POINT_Y + 2 * RADIUS)],
                [self pointWithX:(width/2 - 2*RADIUS * cos(M_PI_4)) Y:(CENTER_POINT_Y + 2 * RADIUS * cos(M_PI_4))],
                [self pointWithX:(width/2 + 2*RADIUS * cos(M_PI_4)) Y:(CENTER_POINT_Y + 2 * RADIUS * cos(M_PI_4))],
                [self pointWithX:(width/2 - 2*RADIUS * cos(M_PI_4)) Y:(CENTER_POINT_Y + 4 * RADIUS * cos(atan(2.0/4)))],
                [self pointWithX:(width/2 + 2*RADIUS * cos(M_PI_4)) Y:(CENTER_POINT_Y + 4 * RADIUS * cos(atan(2.0/4)))], nil];
         break;
      case 6:
         ret = [NSArray arrayWithObjects:
                [self pointWithX:width/2 Y:(CENTER_POINT_Y + 2 * RADIUS)],
                [self pointWithX:(width/2 - 2*RADIUS * cos(M_PI_4)) Y:(CENTER_POINT_Y + 2 * RADIUS * cos(M_PI_4))],
                [self pointWithX:(width/2 + 2*RADIUS * cos(M_PI_4)) Y:(CENTER_POINT_Y + 2 * RADIUS * cos(M_PI_4))],
                [self pointWithX:(width/2) Y:(CENTER_POINT_Y + 4 * RADIUS)],
                [self pointWithX:(width/2 - 2*RADIUS * cos(M_PI_4)) Y:(CENTER_POINT_Y + 4 * RADIUS * cos(atan(2.0/4)))],
                [self pointWithX:(width/2 + 2*RADIUS * cos(M_PI_4)) Y:(CENTER_POINT_Y + 4 * RADIUS * cos(atan(2.0/4)))], nil];
         break;
      default:
//         for (int i=0; i<numOfPersons; i++) {
//            [array addObject:[self pointWithX:<#(CGFloat)#> Y:<#(CGFloat)#>]];;;
//         }
         ret = nil;
         break;
   }

   return ret;
}

- (NSValue *)pointWithX:(CGFloat)x Y:(CGFloat)y {
   return [NSValue valueWithPoint:CGPointMake(x, y)];
}

- (void)drawRect:(NSRect)dirtyRect {
   [super drawRect:dirtyRect];
   self.wantsLayer = YES;
   self.layer.backgroundColor = [NSColor whiteColor].CGColor;
   CGPoint centerPoint = CGPointMake(self.bounds.size.width/2, CENTER_POINT_Y);
   //NSLog(@"center point x: %f, y: %f", centerPoint.x, centerPoint.y);
   [self drawAirDropWithCenter:centerPoint];
   [self drawLayoutRingWithCenter:centerPoint];

   [self reLayoutSubviews];
}

- (void)reLayoutSubviews {
   NSArray *subviews = self.subviews;
   int numberOfViews = subviews.count;
   NSArray *locations = [self locationOfPersonsWithNumber:numberOfViews];
   for (int i=0; i<numberOfViews; i++) {
      NSView *subview = subviews[i];
      NSValue *value = locations[i];
      NSPoint point = [value pointValue];
      subview.frame = NSMakeRect(point.x-subview.bounds.size.width/2, point.y-subview.bounds.size.height/2-20, subview.bounds.size.width, subview.bounds.size.height);
   }
}

- (void)drawAirDropWithCenter:(CGPoint)centerPoint {
   CGContextRef airDropCtx = [[NSGraphicsContext currentContext] graphicsPort];
   CGContextSetLineWidth(airDropCtx, 1.5);
   [[NSColor colorWithRed:0/255.0 green:121/255.0 blue:255/255.0 alpha:1.0] setStroke];
   int numberOfCircles = 8;
   CGFloat angleOffset = M_PI * 2 / 25;
   for (int i=0; i<numberOfCircles; i++) {
      CGFloat radius = 4 * (i+1);
      CGContextAddArc(airDropCtx, centerPoint.x, centerPoint.y, radius, - M_PI /2 + angleOffset, M_PI * 3/2 - angleOffset, 0);
      CGContextStrokePath(airDropCtx);
   }
}

- (void)drawLayoutRingWithCenter:(CGPoint)centerPoint {
   [[NSColor lightGrayColor] setStroke];
   CGContextRef ctx = [[NSGraphicsContext  currentContext] graphicsPort];
   CGContextSetLineWidth(ctx, 0.25);
   for (int i = 0; i < NUM_CIRCLES; i++) {
      CGFloat radius = RADIUS * (i + 1);
      CGContextAddArc(ctx, centerPoint.x, centerPoint.y, radius, 0, M_PI * 2, 0);
      CGContextStrokePath(ctx);
   }
}

@end
