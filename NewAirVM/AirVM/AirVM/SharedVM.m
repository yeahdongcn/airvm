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
   });
   return instance;
}

-(NSString*) parseVMXFile:(NSString*) vmPath{
   NSError *err;
   NSString* vmxContents = [NSString stringWithContentsOfFile:vmPath
                                                     encoding:NSUTF8StringEncoding
                                                        error:&err];
   
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
   
   NSError* err;
   // read everything from text
   NSString* fileContents = [NSString stringWithContentsOfFile:inventoryPath
                                                      encoding:NSUTF8StringEncoding
                                                         error:&err];
   
   // first, separate by new line
   NSArray* allLinedStrings =
   [fileContents componentsSeparatedByCharactersInSet:
   [NSCharacterSet newlineCharacterSet]];
   
   for (NSString* line in allLinedStrings) {
     if([line containsString:@".id"]){
         NSArray *vmPath = [line componentsSeparatedByString:@"="];
        SharedVM *vm = [[SharedVM alloc] init];
        if(vm){
           NSCharacterSet *set = [NSCharacterSet characterSetWithCharactersInString:@" \""];
           vm.vmName = [vmPath[1] stringByTrimmingCharactersInSet:set];
           NSString* port = [self parseVMXFile:vm.vmName];
           if(port){
              [_vmPorts addObject:port];
           }
           [_sharedVMs setObject:vm forKey:vm.vmName];
        }
     }
   }
   
   return [_sharedVMs allValues];
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


-(void) updateVMXfile:(NSString*) vmPath{
   NSString* vmxContents = [NSString stringWithContentsOfFile:vmPath
                                                     encoding:NSUTF8StringEncoding
                                                        error:nil];
   NSArray* allLines =
   [vmxContents componentsSeparatedByCharactersInSet:
    [NSCharacterSet newlineCharacterSet]];
   
   NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithCapacity:10];
   for (NSString* line in allLines) {
      NSArray *arr = [line componentsSeparatedByString:@"="];
      [dic setObject:[arr firstObject] forKey:[arr lastObject]];
   }
   
   if ([dic objectForKey:@"RemoteDisplay.vnc.port"]) {
      [dic setObject:@"" forKey:@"RemoteDisplay.vnc.port"];
   }
   
   if ([dic objectForKey:@"RemoteDisplay.vnc.enabled"]) {
      [dic setObject:@"\"TRUE\"" forKey:@"RemoteDisplay.vnc.enabled"];
   }
   
   if ([dic objectForKey:@"RemoteDisplay.vnc.key"]) {
      [dic setObject: @"\"GigYABETHiQLKhoJETMBBAwMBBQnPCAxNgUDIgYgEQgHMwgFFQIOFAsYBggJPgAhFBwhBgspJQAUIwAgLiEYFhcDAhEiFQ4GIRMUDCEOACgxOCASHCwjAB4iACgaGRwaGCcaASEVAgApFiAcJCQwISYkASMcDgAKMiEFIB0SFhI=\"" forKey:@"RemoteDisplay.vnc.key"];
   }
}

-(void) startSharedVM:(NSString*) vmPath andCompletionBlock:(void(^)(SharedVM* vm)) completionBlock {
   dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
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
      
      
      completionBlock([_sharedVMs objectForKey:vmPath]);
   });
}

@end

