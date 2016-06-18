//
//  AppDelegate.m
//  Bonjour-OSX
//
//  Created by Sun Peng on 14-10-11.
//  Copyright (c) 2014年 Peng Sun. All rights reserved.
//

/*
 
 1. start BSBonjourServer
 2. start BSBonjourClient
 3. BSBonjourClient startSearch, get all friends in AirVMManager
 4. Using sendVM:TargetVM to send local VM VNC info to others
 5. Others will get reply in receivedData:(NSData *)data, parse data to vnc info
 
 
 */

#import "AppDelegate.h"

#include <ifaddrs.h>
#include <arpa/inet.h>

#import <BonjourSDK/BonjourSDK.h>

#import "BJPublishActionButtonTransformer.h"
#import "BJPublishActionButtonEnableTransformer.h"

#define kServiceName     @"airvm"
#define kServiceProtocol @"tcp"

@interface AppDelegate () {
    NSMutableData *_readInData;
    NSNumber      *_bytesRead;
}

@property (weak) IBOutlet NSWindow *window;
@property (unsafe_unretained) IBOutlet NSTextView *editor;

@property (nonatomic, strong) BSBonjourServer *bonjourServer;
@property (nonatomic, strong) BSBonjourClient *bonjourClient;

@property (nonatomic, assign) ServiceStartStatus status;
@property (nonatomic, strong) NSString *         statusText;

@property (nonatomic, strong, readwrite) NSNetService *     netService;

@end

@implementation AppDelegate

+ (void)initialize
{
    if (self == [AppDelegate class]) {
        BJPublishActionButtonTransformer *transformer = [[BJPublishActionButtonTransformer alloc] init];
        [NSValueTransformer setValueTransformer:transformer
                                        forName:@"BJPublishActionButtonTransformer"];

        BJPublishActionButtonEnableTransformer *enableTransformer = [[BJPublishActionButtonEnableTransformer alloc] init];
        [NSValueTransformer setValueTransformer:enableTransformer forName:@"BJPublishActionButtonEnableTransformer"];
    }
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    self.bonjourServer = [[BSBonjourServer alloc] initWithServiceType:kServiceName
                                                    transportProtocol:kServiceProtocol
                                                             delegate:self];

    self.status = Stopped;
    self.statusText = @"Not Published";
    self.bonjourClient = [[BSBonjourClient alloc] initWithServiceType:kServiceName transportProtocol:kServiceProtocol delegate:self];
    [self.bonjourClient startSearching];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    if (self.status == Started) {
        [self stopServer];
    }
}

- (IBAction)toggleAction:(id)sender {
    
    if (self.status == Started) {
        self.status = Stopping;
        [self stopServer];
    } else if (self.status == Stopped) {
        self.status = Starting;
        [self startServer];
    }
}

- (void)startServer
{
    [self.bonjourServer publish];
}

- (void)stopServer
{
    [self.bonjourServer unpublish];
}

#pragma mark -
#pragma mark BSBonjourServerDelegate
- (void)published:(NSString *)name {
    self.status = Started;
    self.statusText = [NSString stringWithFormat:@"Service published with name: %@", name];
}

- (void)registerFailed:(NSError *)error
{
    self.status = Stopped;
    NSAlert *alert = [NSAlert alertWithError:error];
    [alert beginSheetModalForWindow:self.window completionHandler:nil];
}

- (void)publishFailed:(NSError *)error {
    self.status = Stopped;
    NSAlert *alert = [NSAlert alertWithError:error];
    [alert beginSheetModalForWindow:self.window completionHandler:nil];
}

- (void)serviceStopped:(NSString *)name {
    self.statusText = @"Service Stopped";
    self.status = Stopped;
}

- (void)connectionEstablished:(BSBonjourConnection *)connection {
//    [connection sendData:[self.editor.string dataUsingEncoding:NSUTF8StringEncoding]];
    NSLog(@"connectionEstablished");
}

- (void)connectionAttemptFailed:(BSBonjourConnection *)connection {
    NSLog(@"Connection Failed...");
    [self.bonjourClient startSearching];
}

- (void)connectionTerminated:(BSBonjourConnection *)connection {
    NSLog(@"Connection Terminated!");
}

- (void)receivedData:(NSData *)data {
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
    if ([[dic objectForKey:@"op"] isEqualToString:@"openvnc"]) { // register other air vm for management
        NSLog(@"open vnc at %@ !!!!!!!!!!!!!!",[dic objectForKey:@"vncIP"]);
    } else { // accept share from others to open vnc client
        
    }
    self.editor.string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}

#pragma mark BSBonjourClientDelegate

- (void)searchStarted {
    
}
- (void)searchFailed:(NSError *)error {
    
}
- (void)searchStopped {
    
}

- (void)updateServiceList {
    
    [[AirVMManager sharedInstance] resetAirVMs];
    for (NSNetService* service in self.bonjourClient.foundServices) {
        AirVM* vm = [[AirVM alloc] init];
        vm.machineName = service.name;
        vm.netService = service;
        [[AirVMManager sharedInstance] addAirVM:vm];
    }
}

#pragma mark util
- (void)sendOpenVNCCommand:(BSBonjourConnection *)connection {
//     send current vm information to others
    NSDictionary* dic = @{@"op":@"airvm",@"machineName": [[NSHost currentHost] localizedName], @"vncIP":[self getIPAddress], @"vncPort" : @"9547"};
    NSData *data =   [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:nil];
    [connection sendData:data];
    
}

// send connection info to target computer, here we use AirVM map to target computer as well
-(void) sendVM:(AirVM*) vm {
    [self.bonjourClient connectToService:vm.netService completetionBlock:^(BSBonjourConnection *connection) {
        [self sendOpenVNCCommand:connection];
        [self.bonjourClient startSearching];
    }];
}

- (NSString *)getIPAddress {
    
    NSString *address = @"error";
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    int success = 0;
    // retrieve the current interfaces - returns 0 on success
    success = getifaddrs(&interfaces);
    if (success == 0) {
        // Loop through linked list of interfaces
        temp_addr = interfaces;
        while(temp_addr != NULL) {
            if(temp_addr->ifa_addr->sa_family == AF_INET) {
                // Check if interface is en0 which is the wifi connection on the iPhone
                if([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en0"]) {
                    // Get NSString from C String
                    address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
                    
                }
                
            }
            
            temp_addr = temp_addr->ifa_next;
        }
    }
    // Free memory
    freeifaddrs(interfaces);
    return address;
    
}

@end
