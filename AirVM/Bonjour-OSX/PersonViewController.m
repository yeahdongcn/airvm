//
//  PersonViewController.m
//  AirVM
//
//  Created by Zhaokai Yuan on 6/18/16.
//  Copyright © 2016 VMware. All rights reserved.
//

#import "PersonViewController.h"
#import "SharedVM.h"
#import "AppDelegate.h"
#import "PersonView.h"

@interface PersonViewController ()

@property (nonatomic, strong) AirVM *person;

@property (weak) IBOutlet PersonView *portraitView;
@property (weak) IBOutlet NSTextField *nameLabel;

@end

@implementation PersonViewController 

- (instancetype)initWithAirVM:(AirVM *)airVM {
   self = [super initWithNibName:@"PersonViewController" bundle:nil];
   if (self) {
      _person = airVM;
   }
   return self;
}

- (void)viewDidLoad {
   [super viewDidLoad];
   self.portraitView.image = [NSImage imageNamed:@"person"];
   self.portraitView.wantsLayer = YES;
   self.portraitView.layer.cornerRadius = self.portraitView.frame.size.width / 2;
   self.nameLabel.stringValue = self.person.machineName;
   self.portraitView.delegate = self;
}

#pragma mark AirVMDrop
- (void)concludeDropOperation:(id<NSDraggingInfo>)sender {
   NSData *data = [[sender draggingPasteboard] dataForType:NSStringPboardType];
   SharedVM *vm = [NSKeyedUnarchiver unarchiveObjectWithData:data];
   vm.netService = self.person.netService;
   [(AppDelegate *)([[NSApplication sharedApplication] delegate]) sendVM:vm];
}




@end
