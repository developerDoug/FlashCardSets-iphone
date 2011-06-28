//
//  SaveDeckSelection.m
//  FlashNotes
//
//  Created by Douglas Mason on 12/21/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "SaveDeckSelection.h"
#import "DecksCardsJoin.h"

@implementation SaveDeckSelection

- (id)initWithDeckId:(int)dId cardId:(int)cId
{
	self = [super init];
	if (self != nil)
	{
		deckId = dId;
		cardId = cId;
	}
	return self;
}

- (void)performDeckSelectionTask
{
	DecksCardsJoin *join = [[DecksCardsJoin alloc] init];
	join.savedInDatabase = NO;
	join.foreignKeyDeckId = [NSNumber numberWithUnsignedInteger:deckId];
	join.foreignKeyCardId = [NSNumber numberWithUnsignedInteger:cardId];
	[join save];
	[join release];
}

@end
