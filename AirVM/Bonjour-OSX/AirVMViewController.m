//
//  VMAirViewController.m
//  AirVM
//
//  Created by Zhaokai Yuan on 6/17/16.
//  Copyright © 2016 VMware. All rights reserved.
//

#import "AirVMViewController.h"
#import "Person.h"
#import "PersonClusterView.h"
#import "PersonViewController.h"
#import <BonjourSDK/BonjourSDK.h>

@interface AirVMViewController ()
@property (nonatomic, strong) NSMutableArray * personViewControllers; // of PersonViewController
@property (nonatomic, strong) NSArray *persons; // of AirVM
@end

@implementation AirVMViewController

- (void)viewDidLoad {
   [super viewDidLoad];
   [[NSNotificationCenter defaultCenter] addObserver:self
                                            selector:@selector(updatePersonCluster)
                                                name:KNotificationShareVMRefreshed
                                              object:nil];
   [self updatePersonCluster];
}

- (void)viewWillDisappear {
   [[NSNotificationCenter defaultCenter] removeObserver:self];
   [super viewWillDisappear];
}

#pragma mark Layout Operations
- (void)clearPersonCluster {
   for (int i=0; i<self.personViewControllers.count; i++) {
      if (self.personViewControllers[i]) {
         if ([self.personViewControllers[i] isKindOfClass:[PersonViewController class]]) {
            PersonViewController *pvc = self.personViewControllers[i];
            [pvc.view removeFromSuperview];
         }
      }
   }
   [self.personViewControllers removeAllObjects];
}

- (void)drawPersonCluster {
   NSArray *locations = [self locationsOfPersons:self.persons];
   for (int i=0; i<self.persons.count; i++) {
      PersonViewController *personViewController = [[PersonViewController alloc] initWithAirVM:self.persons[i]];
      [self.personViewControllers addObject:personViewController];
      NSView *personView = personViewController.view;
      NSValue * location = locations[i];
      [personView setFrameOrigin:[location pointValue]];
      [self.personClusterView addSubview:personView];
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
//   Person *testA = [[Person alloc] initWithName:@"Zhaokai"];
//   Person *testB = [[Person alloc] initWithName:@"Jeff"];
//   return [NSArray arrayWithObjects:testA, testB, nil];
   return [[AirVMManager sharedInstance] getAllAirVMs];
}

@end
