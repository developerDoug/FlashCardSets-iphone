//
//  CommonStructs.h
//  WordPuzzleTestIdeaOne
//
//  Created by Douglas Mason on 12/25/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "CommonEnums.h"

typedef struct {
	int index;
	int location;
	int posInColumn;
	int posInRow;
	int width;
	int height;
	TileType tileType;
	TileTypeSprite tileTypeSprite;
	unichar character;
} PuzzleTile;

typedef struct {
	int tilesAcross;
	int sizeOfBlocks;
} PuzzleGrid;

typedef struct {
	BOOL returnValue;
	int rowValue;
	int colValue;
} WordPlacementCompareInfo;

typedef struct {
	int rowValue;
	int colValue;
} WordPlacementInsertInfo;

typedef struct {
	int index;
	int location;
	int width;
	int height;
	SearchForWordsType searchForWordsType;
} SearchForWords;

typedef struct {
	int labelsAcross;
	int sizeOfLabels;
} LabelGrid;