//
//  AEKeyframeParser.h
//  AEPasteboard
//
//  Created by Mio Nilsson on 20/08/2012.
//  Copyright (c) 2012 Plingot Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^ManipulationBlock)(NSMutableArray *heading, NSMutableArray *row, NSMutableArray *previousRow, NSUInteger index, BOOL *shouldBreak);

@interface AEKeyframeParser : NSObject

- (void)convertFramesToTime;
- (void)convertRowsToDeltas:(BOOL)keepFirstValue;
- (void)flipY:(CGSize)compSize;

@property (assign) BOOL parsing;
@property (nonatomic, copy) NSString *heading;
@property (nonatomic, assign) double unitsPerSecond;
@property (nonatomic, assign) double sourceWidth;
@property (nonatomic, assign) double sourceHeight;
@property (nonatomic, assign) double sourcePixelAspectRatio;
@property (nonatomic, assign) double compPixelAspectRatio;
@property (nonatomic, copy) NSString *transformType;

@property (nonatomic, copy) NSString *parseString;
@property (nonatomic, copy) NSString *expectKey;
@property (nonatomic, assign) BOOL fetchingRawData;
@property (nonatomic, strong) NSMutableArray *rawData;

@end
