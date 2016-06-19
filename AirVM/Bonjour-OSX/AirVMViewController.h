//
//  VMAirViewController.h
//  AirVM
//
//  Created by Zhaokai Yuan on 6/17/16.
//  Copyright © 2016 VMware. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class PersonClusterView;
@interface AirVMViewController : NSViewController <NSTableViewDataSource, NSTableViewDelegate>

@property (weak) IBOutlet PersonClusterView *personClusterView;
@property (weak) IBOutlet NSTableView *sharedVMsTableView;

@property (nonatomic, strong) NSMutableArray *sharedVMs;
@end
