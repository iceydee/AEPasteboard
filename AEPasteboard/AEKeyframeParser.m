//
//  AEKeyframeParser.m
//  AEPasteboard
//
//  Created by Mio Nilsson on 20/08/2012.
//  Copyright (c) 2012 Plingot Ltd. All rights reserved.
//

#import "AEKeyframeParser.h"

@implementation AEKeyframeParser

@synthesize parseString = _parseString;

#pragma mark - Initialization

- (void)dealloc
{
    self.parseString = nil;
}

#pragma mark - Accessor overrides

- (void)setParseString:(NSString *)parseString
{
    if (![_parseString isEqualToString:parseString])
    {
        _parseString = [parseString copy];
        printf("\n%s\n", [_parseString UTF8String]);
    }
}

@end
