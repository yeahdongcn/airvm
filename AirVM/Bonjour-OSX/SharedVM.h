//
//  SharedVM.h
//  AirVM
//
//  Created by Zhaokai Yuan on 6/19/16.
//  Copyright © 2016 Peng Sun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>

@interface SharedVM : NSObject

@property (nonatomic, copy) NSString *vmName;
@property (nonatomic, strong) NSNetService *netService;
@property (nonatomic, copy) NSString *vncPort;

@end


@interface SharedVMMgr : NSObject

@property (nonatomic) NSMutableDictionary *sharedVMs;
@property (nonatomic) NSMutableSet *vmPorts;

+(SharedVMMgr*) sharedInstance;
-(NSMutableDictionary*) listSharedVMs;
-(void) startSharedVM:(NSString*) vmxPath andCompletionBlock:(void(^)()) completionBlock;

@end
