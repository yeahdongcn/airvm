//
//  BJPublishActionButtonEnableTransformer.m
//  Bonjour-OSX
//
//  Created by Sun Peng on 14-10-13.
//  Copyright (c) 2014年 Peng Sun. All rights reserved.
//

#import "BJPublishActionButtonEnableTransformer.h"
#import "AppDelegate.h"

@implementation BJPublishActionButtonEnableTransformer

+ (Class)transformedValueClass
{
    return [NSNumber class];
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
            case Stopped:
                return [NSNumber numberWithBool:YES];
            default:
                return [NSNumber numberWithBool:NO];
        }
    }

    return [NSNumber numberWithBool:NO];
}

@end
