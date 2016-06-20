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
