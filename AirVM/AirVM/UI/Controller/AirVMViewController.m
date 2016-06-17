//
//  VMAirViewController.m
//  AirVM
//
//  Created by Zhaokai Yuan on 6/17/16.
//  Copyright © 2016 VMware. All rights reserved.
//

#import "AirVMViewController.h"
#import "Person.h"
#import "PersonView.h"
#import "PersonClusterView.h"

@interface AirVMViewController ()
@property (nonatomic, strong) NSMutableArray * personViews; // of PersonView
@property (nonatomic, strong) NSArray *persons; // of Person
@end

@implementation AirVMViewController

- (void)viewDidLoad {
   [super viewDidLoad];
   [self updatePersonCluster];
}

#pragma mark Layout Operations
- (void)clearPersonCluster {
   for (int i=0; i<self.personViews.count; i++) {
      if (self.personViews[i]) {
         [self.personViews[i] removeFromSuperview];
      }
   }
   [self.personViews removeAllObjects];
}

- (void)drawPersonCluster {
   NSArray *locations = [self locationsOfPersons:self.persons];
   for (int i=0; i<self.persons.count; i++) {
      PersonView *personView = [[PersonView alloc] initWithFrame:NSMakeRect(0, 0, 95.0, 95.0)];
      NSValue * location = locations[i];
      [personView setFrameOrigin:[location pointValue]];
      
      [self.personClusterView addSubview:personView];
      [self.personViews addObject:personView];
   }
   [self.view setNeedsDisplay:YES];
};

- (void)updatePersonCluster {
   [self clearPersonCluster];
   self.persons = [self queryPersonsFromBojour];
   [self drawPersonCluster];
}


- (NSArray *)locationsOfPersons:(NSArray *)peopleCluster {
   NSMutableArray *locations = [[NSMutableArray alloc] init];
   CGFloat offsetX = 100.0;
   CGFloat offsetY = 100.0;
   CGFloat offsetXInterval = 100.0;
   CGFloat offsetYInterval = 100.0;
   for (int i=0; i<peopleCluster.count; i++) {
      CGFloat x = offsetX + i * offsetXInterval;
      CGFloat y = offsetY + i * offsetYInterval;
      NSPoint point = NSMakePoint(x, y);
      [locations addObject:[NSValue valueWithPoint:point]];
   }
   return [NSArray arrayWithArray:locations];
}

#pragma mark Data Operations
- (NSArray *)queryPersonsFromBojour {
   Person *testA = [[Person alloc] initWithName:@"Zhaokai"];
   Person *testB = [[Person alloc] initWithName:@"Jeff"];
   return [NSArray arrayWithObjects:testA, testB, nil];
}

@end
