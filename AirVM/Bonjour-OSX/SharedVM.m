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
   return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
   [encoder encodeObject:self.vmName forKey:@"vmName"];
   [encoder encodeObject:self.netService forKey:@"netService"];
   [encoder encodeObject:self.vncPort forKey:@"vncPort"];
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
   NSString* vmShortName = [[vmPath lastPathComponent] stringByDeletingPathExtension];
   NSString* vmx = [NSString stringWithFormat:@"%@.vmwarevm/%@.vmx", vmPath, vmShortName];
   
   NSString* vmxContents = [NSString stringWithContentsOfFile:vmx
                                                     encoding:NSUTF8StringEncoding
                                                        error:nil];
   NSArray* allLines =
   [vmxContents componentsSeparatedByCharactersInSet:
    [NSCharacterSet newlineCharacterSet]];
   
   for (NSString* line in allLines) {
      if([line containsString:@"RemoteDisplay.vnc.port"]){
         NSArray *arr = [line componentsSeparatedByString:@"="];
         return [arr lastObject];
      }
   }
   return nil;
}

-(NSString*) getInventoryContent {
   
   NSString* inventoryPath = @"/Users/xiangk/Desktop/test";
   int pid = [[NSProcessInfo processInfo] processIdentifier];
   NSPipe *pipe = [NSPipe pipe];
   NSFileHandle *file = pipe.fileHandleForReading;
   
   NSTask *task = [[NSTask alloc] init];
   task.launchPath = @"/bin/cat";
   task.arguments = @[inventoryPath];
   task.standardOutput = pipe;
   [task launch];
   NSData *data = [file readDataToEndOfFile];
   [file closeFile];
   NSString *output = [[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding];
   return output;
}

-(NSMutableDictionary*) listSharedVMs{
   NSString* inventoryPath = @"/Users/xiangk/Library/Application Support/VMware Fusion/vmInventory";
   
   NSError* err;
   // read everything from text
   
   NSString* fileContents = [NSString stringWithContentsOfFile:@"/Users/xiangk/Desktop/test"
                                                      encoding:NSUTF8StringEncoding
                                                         error:&err];
   //NSString *fileContents = [self getInventoryContent];
   
   // first, separate by new line
   NSArray* allLinedStrings =
   [fileContents componentsSeparatedByCharactersInSet:
    [NSCharacterSet newlineCharacterSet]];
   
   for (NSString* line in allLinedStrings) {
      if([line containsString:@".id"]){
         NSArray *vmPath = [line componentsSeparatedByString:@"="];
         SharedVM *vm = [[SharedVM alloc] init];
         if(vm){
            vm.vmName = [vmPath lastObject];
            NSString* port = [self parseVMXFile:vm.vmName];
            [_sharedVMs setObject:vm forKey:vm.vmName];
         }
      }
   }
   
   return _sharedVMs;
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

-(void) startSharedVM:(NSString*) vmxPath andCompletionBlock:(void(^)()) completionBlock {
   dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
      int pid = [[NSProcessInfo processInfo] processIdentifier];
      NSPipe *pipe = [NSPipe pipe];
      NSFileHandle *file = pipe.fileHandleForReading;
      
      NSTask *task = [[NSTask alloc] init];
      task.launchPath = @"/Applications/VMware Fusion.app/Contents/Library/vmrun";
      task.arguments = @[@"start",vmxPath , @"nogui"];
      task.standardOutput = pipe;
      [task launch];
      NSData *data = [file readDataToEndOfFile];
      [file closeFile];
      NSString *output = [[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding];
      NSLog(output);
      completionBlock();
   });
}

@end

