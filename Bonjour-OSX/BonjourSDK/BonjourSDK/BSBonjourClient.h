//
//  BSBonjourClient.h
//  BonjourSDK
//
//  Created by Sun Peng on 14-10-16.
//  Copyright (c) 2014年 Peng Sun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BSBonjourConnection.h"


typedef void (^ConnectSuccess)(BSBonjourConnection* connection);

#define kBSBonjourClientDomain @"BSBonjourBrowse"
#define kBSBonjourClientErrorBrowseFailed   -1
#define kBSBonjourClientErrorConnectFailed  -2

@protocol BSBonjourClientDelegate <NSObject>

- (void)searchStarted;
- (void)searchFailed:(NSError *)error;
- (void)searchStopped;

- (void)updateServiceList;

- (void)connectionEstablished:(BSBonjourConnection *)connection;
- (void)connectionAttemptFailed:(BSBonjourConnection *)connection;
- (void)connectionTerminated:(BSBonjourConnection *)connection;
- (void)receivedData:(NSData *)data;

@end

@interface BSBonjourClient : NSObject <NSNetServiceBrowserDelegate, BSBonjourConnectionDelegate> {
    NSNetServiceBrowser *_browser;

    BSBonjourConnection *_connection;
}

@property(nonatomic) ConnectSuccess connectsuccess;

#pragma mark -
#pragma mark Bonjour Service Type Naming
@property (nonatomic, strong) NSString *serviceType;
@property (nonatomic, strong) NSString *transportProtocol;
- (NSString *)combinedType;

#pragma mark -
#pragma mark Client Delegate
@property (nonatomic, strong) id<BSBonjourClientDelegate> delegate;

#pragma mark -
#pragma mark Found Services
@property (nonatomic, strong) NSMutableArray *foundServices;

#pragma mark -
#pragma mark Initialization
- (id)initWithServiceType:(NSString *)serviceType transportProtocol:(NSString *)transportProtocol delegate:(id<BSBonjourClientDelegate>)delegate;

#pragma mark -
#pragma mark Search
- (void)startSearching;
- (void)stopSearching;

#pragma mark -
#pragma mark Connection & Data Transmission
- (void)connectToServiceAtIndex:(NSInteger)index completetionBlock:(ConnectSuccess)connectSuccess;
- (void)connectToService:(NSNetService *)service completetionBlock:(ConnectSuccess)connectSuccess;
- (void)sendData:(NSData *)data;
- (void)disconnectFromService;

@end
