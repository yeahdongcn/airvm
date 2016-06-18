//
//  BSBonjourConnection.m
//  BonjourSDK
//
//  Created by Sun Peng on 14-10-16.
//  Copyright (c) 2014年 Peng Sun. All rights reserved.
//

#import "BSBonjourConnection.h"
#include <arpa/inet.h>
#include "AirVMManager.h"

void readStreamEventHandler(CFReadStreamRef stream, CFStreamEventType eventType, void *info);
void writeStreamEventHandler(CFWriteStreamRef stream, CFStreamEventType eventType, void *info);

@interface BSBonjourConnection ()

@property(nonatomic, assign) CFSocketNativeHandle connectedSocketHandle;

@property (nonatomic, strong) AirVM* vm;

- (void) clean;
- (BOOL) setupSocketStreams;

- (void) readStreamHandleEvent:(CFStreamEventType)event;
- (void) writeStreamHandleEvent:(CFStreamEventType)event;

- (void) readFromStreamIntoIncomingBuffer;
- (void) writeOutgoingBufferToStream;

@end

@implementation BSBonjourConnection

@synthesize connectedSocketHandle;

#pragma mark -
#pragma mark Initialization and Cleanup

- (id) initWithHostAddress:(NSString *)host andPort:(NSInteger)port
{
    if (self = [super init]) {
        [self clean];

        _host = host;
        _port = port;
    }

    return self;
}

- (id) initWithNativeSocketHandle:(CFSocketNativeHandle)nativeSocketHandle
{
    if (self = [super init]) {
        [self clean];
        self.connectedSocketHandle = nativeSocketHandle;
    }

    return self;
}

- (id)initWithNetService:(NSNetService *)netService {
    if (self = [super init]) {
        [self clean];

        // Has it been resolved?
        if ( netService.hostName != nil ) {
            return [self initWithHostAddress:_netService.hostName andPort:_netService.port];
        }

        _netService = netService;
    }

    return self;
}

- (void) dealloc
{
    self.delegate = nil;
}

- (void) clean
{
    _readStream = nil;
    _readStreamOpen = NO;

    _writeStream = nil;
    _writeStreamOpen = NO;

    _incomingDataBuffer = nil;
    _outgoingDataBuffer = nil;

    connectedSocketHandle = -1;
}

- (BOOL) connect
{
    if ( _host != nil ) {
        // Bind read/write streams to a new socket
        CFStreamCreatePairWithSocketToHost(kCFAllocatorDefault, (__bridge CFStringRef)_host,
                                           (UInt32)_port, &_readStream, &_writeStream);

        // Do the rest
        return [self setupSocketStreams];
    } else if ( self.connectedSocketHandle != -1 ) {
        CFStreamCreatePairWithSocket(kCFAllocatorDefault, self.connectedSocketHandle,
                                     &_readStream, &_writeStream);

        return [self setupSocketStreams];
    } else if ( _netService != nil ) {
        // Still need to resolve?
        if ( _netService.hostName != nil ) {
            CFStreamCreatePairWithSocketToHost(kCFAllocatorDefault,
                                               (__bridge CFStringRef)_netService.hostName, (UInt32)_netService.port, &_readStream, &_writeStream);
            return [self setupSocketStreams];
        }

        // Start resolving
        _netService.delegate = self;
        [_netService resolveWithTimeout:5.0];

        return YES;
    }

    return NO;
}


- (BOOL) setupSocketStreams
{
    if (_readStream == nil || _writeStream == nil) {
        [self close];
        return NO;
    }

    _incomingDataBuffer = [[NSMutableData alloc] init];
    _outgoingDataBuffer = [[NSMutableData alloc] init];

    CFReadStreamSetProperty(_readStream, kCFStreamPropertyShouldCloseNativeSocket, kCFBooleanTrue);
    CFWriteStreamSetProperty(_writeStream, kCFStreamPropertyShouldCloseNativeSocket, kCFBooleanTrue);

    CFOptionFlags registeredEvents = kCFStreamEventOpenCompleted | kCFStreamEventHasBytesAvailable
    | kCFStreamEventCanAcceptBytes | kCFStreamEventEndEncountered
    | kCFStreamEventErrorOccurred;

    CFStreamClientContext ctx = {0, (void *)CFBridgingRetain(self), NULL, NULL, NULL};

    CFReadStreamSetClient(_readStream, registeredEvents, readStreamEventHandler, &ctx);
    CFWriteStreamSetClient(_writeStream, registeredEvents, writeStreamEventHandler, &ctx);

    CFReadStreamScheduleWithRunLoop(_readStream, CFRunLoopGetCurrent(), kCFRunLoopCommonModes);
    CFWriteStreamScheduleWithRunLoop(_writeStream, CFRunLoopGetCurrent(), kCFRunLoopCommonModes);

    if ( !CFReadStreamOpen(_readStream) || !CFWriteStreamOpen(_writeStream)) {
        [self close];
        return NO;
    }

    return YES;
}

- (void) close
{
    if ( _readStream != nil ) {
        CFReadStreamUnscheduleFromRunLoop(_readStream, CFRunLoopGetCurrent(), kCFRunLoopCommonModes);
        CFReadStreamClose(_readStream);
        CFRelease(_readStream);
        _readStream = NULL;
    }

    if ( _writeStream != nil ) {
        CFWriteStreamUnscheduleFromRunLoop(_writeStream, CFRunLoopGetCurrent(), kCFRunLoopCommonModes);
        CFWriteStreamClose(_writeStream);
        CFRelease(_writeStream);
        _writeStream = NULL;
    }

    _incomingDataBuffer = NULL;
    _outgoingDataBuffer = NULL;

    [self clean];
}


#pragma mark -
#pragma mark Send Data
- (void) sendData:(NSData *)data
{
    [_outgoingDataBuffer appendData:data];
    [self writeOutgoingBufferToStream];
}


#pragma mark -
#pragma mark Read Stream
void readStreamEventHandler(CFReadStreamRef stream, CFStreamEventType eventType, void *info)
{
    BSBonjourConnection* connection = (__bridge BSBonjourConnection *)info;
    [connection readStreamHandleEvent:eventType];
}

- (void) readStreamHandleEvent:(CFStreamEventType)event
{
    if ( event == kCFStreamEventOpenCompleted ) {
        _readStreamOpen = YES;
        _incomingDataBuffer = [[NSMutableData alloc] init];

        [self.delegate connectionEstablished:self];
    } else if ( event == kCFStreamEventHasBytesAvailable ) {
        [self readFromStreamIntoIncomingBuffer];
    } else if ( event == kCFStreamEventEndEncountered || event == kCFStreamEventErrorOccurred ) {
        [self close];

        if ( !_readStreamOpen || !_writeStreamOpen ) {
            [self.delegate connectionAttemptFailed:self];
        } else {
            [self terminateVM];
            [self.delegate connectionTerminated:self];
        }
    }
}

- (void) readFromStreamIntoIncomingBuffer
{
    UInt8 buf[1024];

    while( CFReadStreamHasBytesAvailable(_readStream) ) {
        CFIndex len = CFReadStreamRead(_readStream, buf, sizeof(buf));
        if ( len <= 0 ) {
            [self close];
            [self terminateVM];
            [self.delegate connectionTerminated:self];
            return;
        }

        [_incomingDataBuffer appendBytes:buf length:len];
    }

    [self.delegate receivedData:[_incomingDataBuffer copy]
                  viaConnection:self];
}


#pragma mark -
#pragma mark Write Stream
void writeStreamEventHandler(CFWriteStreamRef stream, CFStreamEventType eventType, void *info)
{
    BSBonjourConnection* connection = (__bridge BSBonjourConnection *)info;
    [connection writeStreamHandleEvent:eventType];
}


- (void) writeStreamHandleEvent:(CFStreamEventType)event
{
    if ( event == kCFStreamEventOpenCompleted ) {
        _writeStreamOpen = YES;
    }

    else if ( event == kCFStreamEventCanAcceptBytes ) {
        [self writeOutgoingBufferToStream];
    }

    else if ( event == kCFStreamEventEndEncountered || event == kCFStreamEventErrorOccurred ) {
        [self close];

        if ( !_readStreamOpen || !_writeStreamOpen ) {
            [self.delegate connectionAttemptFailed:self];
        }
        else {
            [self terminateVM];
            [self.delegate connectionTerminated:self];
        }
    }
}

- (void) writeOutgoingBufferToStream
{
    if ( !_readStreamOpen || !_writeStreamOpen ) {
        return;
    }

    if ( [_outgoingDataBuffer length] == 0 ) {
        return;
    }

    if ( !CFWriteStreamCanAcceptBytes(_writeStream) ) {
        return;
    }

    CFIndex writtenBytes = CFWriteStreamWrite(_writeStream, [_outgoingDataBuffer bytes], [_outgoingDataBuffer length]);

    if ( writtenBytes == -1 ) {
        [self close];
        [self terminateVM];
        [self.delegate connectionTerminated:self];

        return;
    }

    NSRange range = {0, writtenBytes};
    [_outgoingDataBuffer replaceBytesInRange:range withBytes:NULL length:0];
}

#pragma mark -
#pragma mark Address Resolution
#pragma mark -
#pragma mark NSNetService Delegate Method Implementations

// Called if we weren't able to resolve net service
- (void)netService:(NSNetService *)sender didNotResolve:(NSDictionary *)errorDict
{
    if ( sender != _netService ) {
        return;
    }

    // Close everything and tell delegate that we have failed
    [self.delegate connectionAttemptFailed:self];

    [self close];
}


// Called when net service has been successfully resolved
- (void)netServiceDidResolveAddress:(NSNetService *)sender
{
    if ( sender != _netService ) {
        return;
    }

    // Save connection info
    _host = _netService.hostName;
    _port = _netService.port;
    
    // Don't need the service anymore
    _netService = nil;
    
    self.vm = [[AirVM alloc] init];
    self.vm.machineName = _host;
    self.vm.vncIP = [self getIP:sender.addresses];
    self.vm.vncPort = @"9547";
    self.vm.netService = sender;
    [[AirVMManager sharedInstance] addAirVM:self.vm];

    // Connect!
    if ( ![self connect] ) {
        [self.delegate connectionAttemptFailed:self];
        [self close];
    }
}

-(void) terminateVM {
    [[AirVMManager sharedInstance] removeAirVM:self.vm];
}

-(NSString*) getIP:(NSArray<NSData *> *) addresses {
    char addressBuffer[INET6_ADDRSTRLEN];
    
    for (NSData *data in addresses)
    {
        memset(addressBuffer, 0, INET6_ADDRSTRLEN);
        
        typedef union {
            struct sockaddr sa;
            struct sockaddr_in ipv4;
            struct sockaddr_in6 ipv6;
        } ip_socket_address;
        
        ip_socket_address *socketAddress = (ip_socket_address *)[data bytes];
        
        if ((socketAddress->sa.sa_family == AF_INET))
        {
            const char *addressStr = inet_ntop(
                                               socketAddress->sa.sa_family,
                                               (socketAddress->sa.sa_family == AF_INET ? (void *)&(socketAddress->ipv4.sin_addr) : (void *)&(socketAddress->ipv6.sin6_addr)),
                                               addressBuffer,
                                               sizeof(addressBuffer));
            
            int port = ntohs(socketAddress->sa.sa_family == AF_INET ? socketAddress->ipv4.sin_port : socketAddress->ipv6.sin6_port);
            
            if (addressStr && port)
            {
                NSLog(@"Found service at %s:%d", addressStr, port);
            }
        }
    }
    
    NSString *string_content = [[NSString alloc] initWithCString:(const char*)addressBuffer];

    return string_content;
}


@end
