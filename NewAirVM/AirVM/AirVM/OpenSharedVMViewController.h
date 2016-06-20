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

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil;
- (void)setDescription:(NSString *)description;
@end
