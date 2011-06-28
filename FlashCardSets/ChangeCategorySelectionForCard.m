//
//  ChangeCategorySelectionForCard.m
//  LanguageCards
//
//  Created by Douglas Mason on 1/13/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "ChangeCategorySelectionForCard.h"
#import "Card.h"

@implementation ChangeCategorySelectionForCard

- (id)initWithCard:(Card *)card category:(int)foreignKeyCategoryId
{
	if ((self = [super init]))
	{
		_card = card;
		_foreignKeyCategoryId = foreignKeyCategoryId;
	}
	return self;
}

- (void)performCategorySelection
{
	_card.foreignKeyCategoryId = _foreignKeyCategoryId;
	[_card save];
}

@end
