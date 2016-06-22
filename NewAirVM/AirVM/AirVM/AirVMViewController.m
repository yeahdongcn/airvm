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
#import "OpenSharedVMViewController.h"
#import "AllPersonsView.h"
#import "AllPersonsViewController.h"

#import "BonjourSDK.h"

@interface AirVMViewController ()
@property (nonatomic, strong) AllPersonsViewController *allPersonsViewController;

@property (nonatomic, strong) NSArray *persons; // of AirVM
@end

@implementation AirVMViewController

- (AllPersonsViewController *)allPersonsViewController {
   if (!_allPersonsViewController) {
      _allPersonsViewController = [[AllPersonsViewController alloc] init];
   }
   return _allPersonsViewController;
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
      _sharedVMs = [[SharedVMMgr sharedInstance] listSharedVMs];
   }
   return _sharedVMs;
}

- (void)viewDidLoad {
   [super viewDidLoad];
   [[NSNotificationCenter defaultCenter] addObserver:self
                                            selector:@selector(updatePersonCluster)
                                                name:KNotificationShareVMRefreshed
                                              object:nil];
   [[NSNotificationCenter defaultCenter] addObserver:self
                                            selector:@selector(alertToOpenSharedVM:)
                                                name:KNotificationShareVMArrived
                                              object:nil];
   [self updatePersonCluster];
   [self.sharedVMsTableView reloadData];
   self.allPersonsView.delegate = self.allPersonsViewController;
   self.allPersonsViewController.view = self.allPersonsView;
}

- (void)viewWillDisappear {
   [[NSNotificationCenter defaultCenter] removeObserver:self];
   [super viewWillDisappear];
}

#pragma mark Layout Operations
- (void)clearPersonCluster {
   for (int i=0; i<self.allPersonsViewController.personViewControllers.count; i++) {
      if (self.allPersonsViewController.personViewControllers[i]) {
         if ([self.allPersonsViewController.personViewControllers[i] isKindOfClass:[PersonViewController class]]) {
            PersonViewController *pvc = self.allPersonsViewController.personViewControllers[i];
            [pvc.view removeFromSuperview];
         }
      }
   }
   [self.allPersonsViewController.personViewControllers removeAllObjects];
}

- (void)drawPersonCluster {
   NSArray *locations = [self locationsOfPersons:self.persons];
   for (int i=0; i<self.persons.count; i++) {
      PersonViewController *personViewController = [[PersonViewController alloc] initWithAirVM:self.persons[i]];
      [self.allPersonsViewController.personViewControllers addObject:personViewController];
      NSView *personView = personViewController.view;
      NSValue * location = locations[i];
      NSPoint origin = [location pointValue];
      origin.x -= personView.bounds.size.width/2;
      origin.y -= personView.bounds.size.height/2 + 20;

      [personView setFrameOrigin:origin];
      [self.personClusterView addSubview:personView];
       
       CGRect originalRect = personViewController.portraitView.frame;
    
       personViewController.portraitView.frame = originalRect;
       
       float bump = 4;
       CGRect newRectHuge = CGRectMake(originalRect.origin.x - bump/2, originalRect.origin.y + bump/2, CGRectGetWidth(originalRect) + bump, CGRectGetHeight(originalRect) + bump);
       bump = 2;
       CGRect newRectBig = CGRectMake(originalRect.origin.x - bump/2, originalRect.origin.y + bump/2, CGRectGetWidth(originalRect) + bump, CGRectGetHeight(originalRect) + bump);
       
       [NSAnimationContext runAnimationGroup:^(NSAnimationContext *context){
           [context setDuration:0.1];
           [[personViewController.portraitView animator] setFrame:newRectHuge];
       } completionHandler:^{
           [NSAnimationContext runAnimationGroup:^(NSAnimationContext *context){
               [context setDuration:0.06];
               [[personViewController.portraitView animator] setFrame:originalRect];
           } completionHandler:^{
               [NSAnimationContext runAnimationGroup:^(NSAnimationContext *context){
                   [context setDuration:0.1];
                   [[personViewController.portraitView animator] setFrame:newRectBig];
               } completionHandler:^{
                   [NSAnimationContext runAnimationGroup:^(NSAnimationContext *context){
                       [context setDuration:0.2];
                       [[personViewController.portraitView animator] setFrame:originalRect];
                   } completionHandler:^{
                       
                   }];
               }];

           }];
       }];
   }

};

- (void)updatePersonCluster {
   [self clearPersonCluster];
   self.persons = [self queryPersonsFromBojour];
   [self drawPersonCluster];
}

- (void)alertToOpenSharedVM:(NSNotification*)notification {
   [self showPopoverwithNotification:notification];
}

- (PersonViewController *)findPersonViewControllerWithMachineName:(NSString *)machineName {
   for (PersonViewController *pvc in self.allPersonsViewController.personViewControllers) {
      if ([machineName isEqualToString:pvc.machineName]) {
         return pvc;
      }
   }
   return nil;
}

- (void)showPopoverwithNotification:(NSNotification *)notification {
   NSDictionary *usrDic = [notification userInfo];
   NSString *machineName = [usrDic valueForKey:@"machineName"];
   NSString *message = [usrDic valueForKey:@"message"];
   PersonViewController *pvc = [self findPersonViewControllerWithMachineName:machineName];
   if (pvc) {
#pragma warning TODO: construct a SharedVM
      SharedVM *vm = [[SharedVM alloc] init];
      vm.ipAddress = [usrDic valueForKey:@"vncIP"];
      vm.vncPort = [usrDic valueForKey:@"vncPort"];
      OpenAction openAction = ^(BOOL open) {
         if (open) {
            [self openTheSharedVM:vm];
         } else {
            [self ignoreTheSharedVM:vm];
         }
         [pvc dismissOpenSharedVMPopover];
      };
      [pvc showPopoverWithOpenAction:openAction message:message];
   }
}

- (void)openTheSharedVM:(SharedVM *)vm {
   NSLog(@"%@ opened the shared VM: %@", self, vm);
   NSPipe *pipe = [NSPipe pipe];
   NSTask *task = [[NSTask alloc] init];
   task.launchPath = @"/usr/bin/open";
   NSString *password = @"airvm";
   NSString *ipAddress = vm.ipAddress;
   NSString *vncPort = vm.vncPort;
   vncPort = [vncPort stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"\""]];
   NSString *arg1 = [NSString stringWithFormat:@"vnc://:%@@%@:%@", password, ipAddress, vncPort];
   task.arguments = @[arg1];
   task.standardOutput = pipe;
   NSLog(@"Invoke VNC command: %@ %@", task.launchPath, arg1);
   [task launch];
}

- (void)ignoreTheSharedVM:(SharedVM *)vm {
   NSLog(@"%@ ignored the shared VM: %@", self, vm);
}




- (NSArray *)locationsOfPersons:(NSArray *)peopleCluster {
   return [self.personClusterView locationOfPersonsWithNumber:peopleCluster.count];
}

#pragma mark Data Operations
- (NSArray *)queryPersonsFromBojour {
//   AirVM *testA = [[AirVM alloc] init]; testA.machineName = @"Zhaokai";
//   AirVM *testB = [[AirVM alloc] init]; testB.machineName = @"Jeff";
//   return [NSArray arrayWithObjects:testA,testB, testA, testB,testA, testB, nil];
   return [[AirVMManager sharedInstance] getAllAirVMs];
}

#pragma mark Table View Operations
- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
   return self.sharedVMs.count;
}

- (CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row {
   return 30.0;
}

- (NSView *)tableView:(NSTableView *)tableView
   viewForTableColumn:(NSTableColumn *)tableColumn
                  row:(NSInteger)row {
   NSTableCellView *cell = [tableView makeViewWithIdentifier:@"SHAREDVMTABLECELLVIEW" owner:nil];
   SharedVM *vm = self.sharedVMs[row];
   NSString *displayName = [[vm.vmName lastPathComponent] stringByDeletingPathExtension];
   cell.textField.stringValue = displayName;
   return cell;
}

- (BOOL)tableView:(NSTableView *)aTableView writeRowsWithIndexes:(NSIndexSet *)rowIndexes toPasteboard:(NSPasteboard*)pboard {
   if (rowIndexes.count == 1) {
      //NSData *data = [NSKeyedArchiver archivedDataWithRootObject:self.sharedVMs[rowIndexes.firstIndex]];
      SharedVM *currentVM = self.sharedVMs[rowIndexes.firstIndex];
      NSData *data = [NSKeyedArchiver archivedDataWithRootObject:currentVM.vmName];
      [pboard declareTypes:[NSArray arrayWithObject:NSStringPboardType] owner:self];
      [pboard setData:data forType:NSStringPboardType];
      return YES;
   }
   return NO;
}

- (NSDragOperation)tableView:(NSTableView*)tv validateDrop:(id )info proposedRow:(NSInteger)row proposedDropOperation:(NSTableViewDropOperation)op {
   return NSDragOperationEvery;
}

- (BOOL)tableView:(NSTableView*)tv acceptDrop:(id)info row:(NSInteger)row dropOperation:(NSTableViewDropOperation)op {
   return YES;
}

@end
