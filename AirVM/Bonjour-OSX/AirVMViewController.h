//
//  VMAirViewController.h
//  AirVM
//
//  Created by Zhaokai Yuan on 6/17/16.
//  Copyright © 2016 VMware. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class PersonClusterView;
@interface AirVMViewController : NSViewController

@property (weak) IBOutlet PersonClusterView *personClusterView;

@property (nonatomic, strong) NSMutableArray *sharedVMs;
@end
