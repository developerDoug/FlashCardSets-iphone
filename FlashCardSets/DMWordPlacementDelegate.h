//
//  DMWordPlacementDelegate.h
//  WordPuzzleGame2
//
//  Created by Douglas Mason on 1/6/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "Common.h"

@class SlabLayer;

@protocol DMWordPlacementDelegate

- (BOOL)compareWithWord:(NSString*)word rowValue:(int)row columnValue:(int)col slabTiles:(SlabLayer*[])slabs;
- (void)placeWordWithWord:(NSString*)word rowValue:(int)row columnValue:(int)col slabTiles:(SlabLayer*[])slabs;

@end
