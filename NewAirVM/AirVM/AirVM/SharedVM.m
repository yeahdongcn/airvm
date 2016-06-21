//
//  SharedVM.m
//  AirVM
//
//  Created by Zhaokai Yuan on 6/19/16.
//  Copyright © 2016 Peng Sun. All rights reserved.
//

#import "SharedVM.h"

@implementation SharedVM

- (id)initWithCoder:(NSCoder *)decoder {
   self = [super init];
   if (!self) {
      return nil;
   }

   self.vmName = [decoder decodeObjectForKey:@"vmName"];
   self.netService = [decoder decodeObjectForKey:@"netService"];
   self.vncPort = [decoder decodeObjectForKey:@"vncPort"];
   self.ipAddress = [decoder decodeObjectForKey:@"ipAddress"];
   return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
   [encoder encodeObject:self.vmName forKey:@"vmName"];
   [encoder encodeObject:self.netService forKey:@"netService"];
   [encoder encodeObject:self.vncPort forKey:@"vncPort"];
   [encoder encodeObject:self.ipAddress forKey:@"ipAddress"];
}

@end

static SharedVMMgr* instance;

@implementation SharedVMMgr

+(SharedVMMgr*) sharedInstance {
   static dispatch_once_t onceToken;
   dispatch_once(&onceToken, ^{
      instance = [[SharedVMMgr alloc] init];
      instance.sharedVMs = [[NSMutableDictionary alloc] init];
      instance.vmPorts = [[NSMutableSet alloc] init];
   });
   return instance;
}

-(NSString*) getPortFromVMX:(NSString*) vmPath{
   NSString* vmxContents = [NSString stringWithContentsOfFile:vmPath
                                                     encoding:NSUTF8StringEncoding
                                                        error:nil];
   
   NSArray* allLines =
   [vmxContents componentsSeparatedByCharactersInSet:
    [NSCharacterSet newlineCharacterSet]];
   
   for (NSString* line in allLines) {
      if([line containsString:@"RemoteDisplay.vnc.port"]){
         NSArray *arr = [line componentsSeparatedByString:@"="];
         NSCharacterSet *set = [NSCharacterSet characterSetWithCharactersInString:@" \""];
         return [[arr lastObject] stringByTrimmingCharactersInSet:set];
      }
   }
   return nil;
}

-(NSMutableDictionary*) listSharedVMs{
   
   NSString* inventoryPath = [NSString stringWithFormat:@"%@//Library/Application Support/VMware Fusion/vmInventory", NSHomeDirectory()];

   // read everything from text
   NSString* fileContents = [NSString stringWithContentsOfFile:inventoryPath
                                                      encoding:NSUTF8StringEncoding
                                                         error:nil];
   
   // first, separate by new line
   NSArray* allLinedStrings =
   [fileContents componentsSeparatedByCharactersInSet:
   [NSCharacterSet newlineCharacterSet]];
   
   for (NSString* line in allLinedStrings) {
     if([line containsString:@".id"]){
        NSArray *vmPath = [line componentsSeparatedByString:@"="];
        NSCharacterSet *set = [NSCharacterSet characterSetWithCharactersInString:@" \""];
        SharedVM *vm = [[SharedVM alloc] init];
        vm.vmName = [vmPath[1] stringByTrimmingCharactersInSet:set];
        NSString* port = [self getPortFromVMX:vm.vmName];
        if(port){
           [self.vmPorts addObject:port];
        }
        [self.sharedVMs setObject:vm forKey:vm.vmName];
     }
   }
   NSLog(@"%@", self.vmPorts);
   return [self.sharedVMs allValues];
}

- (NSString*)_randomNumberBetween:(NSInteger)min maxNumber:(NSInteger)max
{
   return [NSString stringWithFormat:@"%d",(min + arc4random_uniform(max - min + 1))];
}

-(NSString*) generatePortWithBlackList:(NSArray*) blacklist {
   
   NSString* str;
   do {
      str = [self _randomNumberBetween:5000 maxNumber:6000];
   } while ([blacklist containsObject:str]);
   
   return str;
}

-(void) updateVMX:(SharedVM* ) vm{
   NSString* vmPath = vm.vmName;
   NSString* vmxContents = [NSString stringWithContentsOfFile:vmPath
                                                     encoding:NSUTF8StringEncoding
                                                        error:nil];
   
   NSArray* allLines =[vmxContents componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
   
   NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithCapacity:10];
   for (NSString* line in allLines) {
      NSArray *arr = [line componentsSeparatedByString:@"="];
      
      NSCharacterSet *set = [NSCharacterSet characterSetWithCharactersInString:@" "];
      NSString *key = [[arr firstObject] stringByTrimmingCharactersInSet:set];
      NSString *val = [[arr lastObject] stringByTrimmingCharactersInSet:set];
      [dic setObject:val forKey:key];
   }
   
   if ([dic objectForKey:@"encryption.keySafe"]) {
      NSLog(@"encryption vmx... do nothing");
      return;
   }
   
   if (![dic objectForKey:@"RemoteDisplay.vnc.port"]) {
      NSString *port = [self generatePortWithBlackList:[self.vmPorts allObjects]];
      [self.vmPorts addObject:port];
      [dic setObject:[NSString stringWithFormat:@"\"%@\"",port] forKey:@"RemoteDisplay.vnc.port"];
      vm.vncPort = port;
   }
   else{
      NSCharacterSet *set = [NSCharacterSet characterSetWithCharactersInString:@"\""];
      vm.vncPort = [[dic objectForKey:@"RemoteDisplay.vnc.port"] stringByTrimmingCharactersInSet:set];
   }
   
   [dic setObject:@"\"TRUE\"" forKey:@"RemoteDisplay.vnc.enabled"];
   [dic setObject: @"\"GigYABETHiQLKhoJETMBBAwMBBQnPCAxNgUDIgYgEQgHMwgFFQIOFAsYBggJPgAhFBwhBgspJQAUIwAgLiEYFhcDAhEiFQ4GIRMUDCEOACgxOCASHCwjAB4iACgaGRwaGCcaASEVAgApFiAcJCQwISYkASMcDgAKMiEFIB0SFhI=\""
            forKey:@"RemoteDisplay.vnc.key"];

   NSMutableString* str = [[NSMutableString alloc] init];
   for (NSString* key in [dic allKeys]) {
      if ([key length] > 0) {
         [str appendFormat:@"%@ = %@\n", key, [dic objectForKey:key]];
      }
   }
   [str writeToFile:vmPath atomically:YES encoding:NSUTF8StringEncoding error:nil];
}

-(void) startSharedVM:(NSString*) vmPath andCompletionBlock:(void(^)(SharedVM* vm)) completionBlock {
   dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
      
      SharedVM* vm = [_sharedVMs objectForKey:vmPath];
      [self updateVMX:vm];
      
      int pid = [[NSProcessInfo processInfo] processIdentifier];
      NSPipe *pipe = [NSPipe pipe];
      NSFileHandle *file = pipe.fileHandleForReading;
      
      NSTask *task = [[NSTask alloc] init];
      task.launchPath = @"/Applications/VMware Fusion.app/Contents/Library/vmrun";
      task.arguments = @[@"start", vmPath , @"nogui"];
      task.standardOutput = pipe;
      [task launch];
      NSData *data = [file readDataToEndOfFile];
      [file closeFile];
      NSString *output = [[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding];
      NSLog(output);
      
      completionBlock(vm);
   });
}

@end

