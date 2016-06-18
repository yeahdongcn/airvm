//
//  AppDelegate.m
//  Bonjour-OSX
//
//  Created by Sun Peng on 14-10-11.
//  Copyright (c) 2014年 Peng Sun. All rights reserved.
//

#import "AppDelegate.h"

#import <BonjourSDK/BonjourSDK.h>

#import "BJPublishActionButtonTransformer.h"
#import "BJPublishActionButtonEnableTransformer.h"

#define kServiceName     @"share_editor"
#define kServiceProtocol @"tcp"

@interface AppDelegate () {
    NSMutableData *_readInData;
    NSNumber      *_bytesRead;
}

@property (weak) IBOutlet NSWindow *window;
@property (unsafe_unretained) IBOutlet NSTextView *editor;

@property (nonatomic, strong) BSBonjourServer *bonjourServer;

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
    [connection sendData:[self.editor.string dataUsingEncoding:NSUTF8StringEncoding]];
}

- (void)connectionAttemptFailed:(BSBonjourConnection *)connection {
    NSLog(@"Connection Failed...");
}

- (void)connectionTerminated:(BSBonjourConnection *)connection {
    NSLog(@"Connection Terminated!");
}

- (void)receivedData:(NSData *)data {
    self.editor.string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}

@end
