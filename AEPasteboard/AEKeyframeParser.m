//
//  AEKeyframeParser.m
//  AEPasteboard
//
//  Created by Mio Nilsson on 20/08/2012.
//  Copyright (c) 2012 Plingot Ltd. All rights reserved.
//

#import "AEKeyframeParser.h"

@implementation AEKeyframeParser

@synthesize heading = _heading;
@synthesize unitsPerSecond = _unitsPerSecond;
@synthesize sourceWidth = _sourceWidth;
@synthesize sourceHeight = _sourceHeight;
@synthesize sourcePixelAspectRatio = _sourcePixelAspectRatio;
@synthesize compPixelAspectRatio = _compPixelAspectRatio;
@synthesize transformType = _transformType;
@synthesize parseString = _parseString;
@synthesize expectKey = _expectKey;
@synthesize rawData = _rawData;
@synthesize fetchingRawData = _fetchingRawData;

#pragma mark - Queues

+ (NSOperationQueue *)sharedParsingQueue
{
    static NSOperationQueue *pSharedParsingQueue = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        pSharedParsingQueue = [[NSOperationQueue alloc] init];
        [pSharedParsingQueue setMaxConcurrentOperationCount:4];
    });
    return pSharedParsingQueue;
}

#pragma mark - Initialization

- (void)dealloc
{
    self.heading = nil;
    self.transformType = nil;
    self.parseString = nil;
    self.expectKey = nil;
    self.rawData = nil;
}

#pragma mark - Parsing

- (void)parseLine:(NSString *)line
{
    NSUInteger rawCount = 0;
    __block NSMutableArray *rawDataRow = nil;
    if (self.fetchingRawData)
    {
        // Get the number of expected entries
        rawCount = [[self.rawData objectAtIndex:0] count];

        // Create new entry in raw data for each new line
        rawDataRow = [NSMutableArray arrayWithCapacity:rawCount];
        [self.rawData addObject:rawDataRow];
    }

    void (^addRawData)(NSString *value) = ^(NSString *value) {
        double rawValue = [value doubleValue];
        NSNumber *entry = [NSNumber numberWithDouble:rawValue];
        [rawDataRow addObject:entry];
    };

    NSScanner *tabScanner = [NSScanner scannerWithString:line];
    while (![tabScanner isAtEnd])
    {
        NSString *tabStop = nil;
        [tabScanner scanUpToString:@"\t" intoString:&tabStop];
        if (tabStop)
        {
            if (self.expectKey)
            {
                [self setValue:tabStop forKey:self.expectKey];
                self.expectKey = nil;
            }
            else if (self.fetchingRawData)
            {
                addRawData(tabStop);
            }
            else
            {
                self.expectKey = [self expectKeyForEntry:tabStop];
                if ([self.expectKey isEqualToString:@"##HEADING##"])
                {
                    [[self.rawData objectAtIndex:0] addObject:[tabStop copy]];
                    self.expectKey = nil;
                }
                else if (self.fetchingRawData)
                {
                    // Make sure we get the very first entry also
                    if (!rawDataRow)
                    {
                        rawDataRow = [NSMutableArray array];
                        [self.rawData addObject:rawDataRow];
                    }
                    addRawData(tabStop);
                }
            }
        }
    }

    if (self.fetchingRawData)
    {
        if (rawDataRow.count < rawCount)
        {
            [self.rawData removeLastObject];
        }
        else if (rawDataRow.count > rawCount)
        {
            [self.rawData removeLastObject];
        }
    }
}

- (void)parse
{
    // Expect heading as first line
    self.expectKey = @"heading";

    NSScanner *lineScanner = [NSScanner scannerWithString:self.parseString];
    while (![lineScanner isAtEnd])
    {
        NSString *line = nil;
        [lineScanner scanUpToCharactersFromSet:[NSCharacterSet newlineCharacterSet]
                                    intoString:&line];
        if (line)
        {
            [self parseLine:line];
        }
    }

    NSLog(@"Done parsing");
}

#pragma mark - Expects

#define EXPECT_KEY(KEY, VALUE) \
    if ([entry isEqualToString:KEY]) \
    { \
        return VALUE; \
    }

#define EXPECT_HEADING(TRANSFORMTYPE, COUNT) \
    if ([self.transformType isEqualToString:TRANSFORMTYPE] && [[self.rawData objectAtIndex:0] count] < COUNT) \
    { \
        return @"##HEADING##"; \
    }

- (NSString *)expectKeyForEntry:(NSString *)entry
{
    if (self.fetchingRawData)
    {
        return nil;
    }
    
    EXPECT_KEY(@"Units Per Second", @"unitsPerSecond");
    EXPECT_KEY(@"Source Width", @"sourceWidth");
    EXPECT_KEY(@"Source Height", @"sourceHeight");
    EXPECT_KEY(@"Source Pixel Aspect Ratio", @"sourcePixelAspectRatio");
    EXPECT_KEY(@"Comp Pixel Aspect Ratio", @"compPixelAspectRatio");
    EXPECT_KEY(@"Transform", @"transformType");

    // Put in a nil check for the end of the block
    EXPECT_KEY(@"End of Keyframe Data", nil);

    // Get headings
    EXPECT_HEADING(@"Position", 4);

    // Assume we have all headings by now
    self.fetchingRawData = YES;

    printf("unhandled key? [%s]\n", [entry UTF8String]);
    return NULL;
}

#pragma mark - Accessor overrides

- (void)setParseString:(NSString *)parseString
{
    if (![_parseString isEqualToString:parseString])
    {
        _parseString = [parseString copy];
        if (_parseString)
        {
            if (!self.parsing)
            {
                self.parsing = YES;
                __block typeof(self) bSelf = self;
                [[AEKeyframeParser sharedParsingQueue] addOperationWithBlock:^{
                    [bSelf parse];
                    bSelf.parsing = NO;
                }];
            }
        }
    }
}

- (NSMutableArray *)rawData
{
    // Lazy loading
    if (!_rawData)
    {
        // Create the base raw data object
        _rawData = [NSMutableArray array];

        // Add one row for the headings
        [_rawData addObject:[NSMutableArray array]];
    }
    return _rawData;
}

@end
