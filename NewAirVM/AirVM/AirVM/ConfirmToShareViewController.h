//
//  ConfirmToShareViewController.h
//  AirVM
//
//  Created by Zhaokai Yuan on 6/22/16.
//  Copyright © 2016 VMware. All rights reserved.
//

#import <Cocoa/Cocoa.h>

typedef void (^ShareAction)(BOOL open);

@interface ConfirmToShareViewController : NSViewController

@property (nonatomic, strong) ShareAction shareAction;

@end
