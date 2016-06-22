//
//  AllPersonsViewController.h
//  AirVM
//
//  Created by Zhaokai Yuan on 6/22/16.
//  Copyright © 2016 VMware. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "DragDestinationViewController.h"
@interface AllPersonsViewController : DragDestinationViewController
@property (nonatomic, strong) NSMutableArray * personViewControllers; // of PersonViewController
@end
