//
//  DeleteNotInDeckSelection.h
//  FlashNotes
//
//  Created by Douglas Mason on 12/21/09.
//  Copyright 2009 All rights reserved.
//
//	For CardEditViewController

#import <Foundation/Foundation.h>
#import "SaveDeleteDeckSelection.h"

@interface DeleteDeckSelection : NSObject <SaveDeleteDeckSelection>
{
	NSUInteger deckId;
	NSUInteger cardId;
}

- (id)initWithDeckId:(int)dId cardId:(int)cId;

@end
