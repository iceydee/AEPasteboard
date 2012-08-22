//
//  PasteboardManager.m
//  AEPasteboard
//
//  Created by Mio Nilsson on 20/08/2012.
//  Copyright (c) 2012 Plingot Ltd. All rights reserved.
//

#import "PasteboardManager.h"
#import "AEKeyframeParser.h"

@implementation PasteboardManager

- (IBAction)paste:(NSMenuItem *)sender
{
    NSPasteboard *pasteboard = [NSPasteboard generalPasteboard];
    NSArray *classes = [[NSArray alloc] initWithObjects:[NSString class], nil];
    NSDictionary *options = [NSDictionary dictionary];
    NSArray *copiedItems = [pasteboard readObjectsForClasses:classes options:options];
    for (NSString *item in copiedItems)
    {
        if ([self stringHasAEKeyframes:item])
        {
            NSLog(@"AE Keyframes found");
            AEKeyframeParser *parser = [[AEKeyframeParser alloc] init];
            parser.parseString = item;
//            [parser parse];
        }
    }
}

- (BOOL)stringHasAEKeyframes:(NSString *)string
{
    NSString *aeKeyframeHeading = @"Adobe After Effects 8.0 Keyframe Data";
    NSPredicate *aeKeyframePredicate = [NSPredicate predicateWithFormat:@"SELF beginswith %@", aeKeyframeHeading];
    return [aeKeyframePredicate evaluateWithObject:string];
}

@end
