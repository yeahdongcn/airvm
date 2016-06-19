//
//  AirVMManager.h
//  BonjourSDK
//
//  Created by wujeff on 6/18/16.
//  Copyright © 2016 Peng Sun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BSBonjourConnection.h"

static NSString* KNotificationShareVMArrived = @"KNotificationShareVMArrived";
static NSString* KNotificationShareVMRefreshed = @"KNotificationShareVMRefreshed";


@interface AirVM : NSObject

@property(nonatomic) NSString* machineName;
@property(nonatomic) NSString* vncIP;
@property(nonatomic) NSString* vncPort;
@property(nonatomic) NSNetService* netService;
@property(nonatomic) BSBonjourConnection* connection;

@end

@interface AirVMManager : NSObject

+(AirVMManager*) sharedInstance;
-(NSArray*) getAllAirVMs;
-(void) resetAirVMs;
-(NSMutableDictionary*) addAirVM:(AirVM*) vm;
-(NSMutableDictionary*) removeAirVM:(AirVM*) vm;
-(void) dump;

@property (nonatomic) NSMutableDictionary* airVMs;
@property (nonatomic) NSNetService* curService;

@end


