//
//  AirVMManager.m
//  BonjourSDK
//
//  Created by wujeff on 6/18/16.
//  Copyright © 2016 Peng Sun. All rights reserved.
//

#import "AirVMManager.h"

static AirVMManager* instance;

@implementation AirVMManager

+(AirVMManager*) sharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[AirVMManager alloc] init];
        instance.airVMs = [[NSMutableDictionary alloc] init];
    });
    return instance;
}

-(NSArray*) getAllAirVMs {
    return instance.airVMs.allValues;
}

-(void) resetAirVMs {
    instance.airVMs.removeAllObjects;
    instance.airVMs = instance.airVMs = [[NSMutableDictionary alloc] init];
}

-(NSMutableDictionary*) addAirVM:(AirVM*) vm {
    [instance.airVMs setObject:vm forKey:vm.vncIP];
    return instance.airVMs;
}

-(NSMutableDictionary*) removeAirVM:(AirVM*) vm {
    [instance.airVMs removeObjectForKey:vm.vncIP];
    return instance.airVMs;
}

@end

@implementation AirVM : NSObject 



@end
