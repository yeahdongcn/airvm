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
#import "SharedVM.h"

#import <BonjourSDK/BonjourSDK.h>

@interface AirVMViewController ()
@property (nonatomic, strong) NSMutableArray * personViewControllers; // of PersonViewController
@property (nonatomic, strong) NSArray *persons; // of AirVM
@end

@implementation AirVMViewController

- (NSMutableArray *)personViewControllers {
   if (!_personViewControllers) {
      _personViewControllers = [[NSMutableArray alloc] init];
   }
   return _personViewControllers;
}

- (NSArray *)persons {
   if (!_persons) {
      _persons = [[NSArray alloc] init];
   }
   return _persons;
}

// test code
- (NSMutableArray *)sharedVMs {
   if (!_sharedVMs) {
      SharedVM * testVM1 = [[SharedVM alloc] init];
      testVM1.vmName = @"Windows 10 x64bit";
      SharedVM * testVM2 = [[SharedVM alloc] init];
      testVM2.vmName = @"macOS 10.12";
      _sharedVMs = [[NSMutableArray alloc] initWithObjects:testVM1, testVM2, nil];
   }
   return _sharedVMs;
}

- (void)viewDidLoad {
   [super viewDidLoad];
   [[NSNotificationCenter defaultCenter] addObserver:self
                                            selector:@selector(updatePersonCluster)
                                                name:KNotificationShareVMRefreshed
                                              object:nil];
   [self updatePersonCluster];
   [self.sharedVMsTableView reloadData];
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

#pragma mark Table View Operations
- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
   return self.sharedVMs.count;
}

- (NSView *)tableView:(NSTableView *)tableView
   viewForTableColumn:(NSTableColumn *)tableColumn
                  row:(NSInteger)row {
   NSTableCellView *cell = [tableView makeViewWithIdentifier:@"SHAREDVMTABLECELLVIEW" owner:nil];
   SharedVM *vm = self.sharedVMs[row];
   cell.textField.stringValue = vm.vmName;
   return cell;
}

- (BOOL)tableView:(NSTableView *)aTableView writeRowsWithIndexes:(NSIndexSet *)rowIndexes toPasteboard:(NSPasteboard*)pboard {
   if (rowIndexes.count == 1) {
      NSData *data = [NSKeyedArchiver archivedDataWithRootObject:self.sharedVMs[rowIndexes.firstIndex]];
      [pboard declareTypes:[NSArray arrayWithObject:NSStringPboardType] owner:self];
      [pboard setData:data forType:NSStringPboardType];
      return YES;
   }
   return NO;
}

- (NSDragOperation)tableView:(NSTableView*)tv validateDrop:(id )info proposedRow:(NSInteger)row proposedDropOperation:(NSTableViewDropOperation)op {
   return NSDragOperationAll;
}

- (BOOL)tableView:(NSTableView*)tv acceptDrop:(id)info row:(NSInteger)row dropOperation:(NSTableViewDropOperation)op {
   return YES;
}

@end
