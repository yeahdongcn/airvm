//
//  BJPublishActionButtonTransformer.m
//  Bonjour-OSX
//
//  Created by Sun Peng on 14-10-13.
//  Copyright (c) 2014年 Peng Sun. All rights reserved.
//

#import "BJPublishActionButtonTransformer.h"
#import "AppDelegate.h"

@implementation BJPublishActionButtonTransformer

+ (Class)transformedValueClass
{
    return [NSString class];
}

+ (BOOL)allowsReverseTransformation
{
    return NO;
}

- (id)transformedValue:(id)value
{
    if ([value respondsToSelector:@selector(intValue)]) {
        int status = [value intValue];
        switch (status) {
            case Started:
                return @"Stop";
            case Starting:
                return @"Starting...";
            case Stopped:
                return @"Start";
            case Stopping:
                return @"Stopping...";
            default:
                break;
        }
    }

    return @"Unknown";
}

@end
