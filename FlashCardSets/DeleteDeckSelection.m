//
//  DeleteNotInDeckSelection.m
//  FlashNotes
//
//  Created by Douglas Mason on 12/21/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "DeleteDeckSelection.h"
#import "DecksCardsJoin.h"
#import "CDLModel.h"
#import "CDLDatabase.h"

@implementation DeleteDeckSelection

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
	NSString *deleteQuery = [NSString stringWithFormat:@"DELETE FROM %@ WHERE %@ = %d AND %@ = %d",
							 [DecksCardsJoin tableIdentifier],
							 [DecksCardsJoin foreignKeyDeckIdColumnIdentifier], deckId,
							 [DecksCardsJoin foreignKeyCardIdColumnIdentifier], cardId];
	
	
	[[CDLModel database] executeSql:deleteQuery];
}

@end
