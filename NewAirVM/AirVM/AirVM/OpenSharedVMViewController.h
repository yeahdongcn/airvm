//
//  OpenSharedVMViewController.h
//  AirVM
//
//  Created by Zhaokai Yuan on 6/20/16.
//  Copyright © 2016 Peng Sun. All rights reserved.
//

#import <Cocoa/Cocoa.h>

typedef void (^OpenAction)(BOOL open);

@interface OpenSharedVMViewController : NSViewController

@property (nonatomic, assign) BOOL didResponse;
@property (nonatomic, strong) OpenAction openAction;
@property (nonatomic, copy) NSString *message;


- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil;
@end
