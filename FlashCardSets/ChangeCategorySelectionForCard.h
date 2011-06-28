//
//  ChangeCategorySelectionForCard.h
//  LanguageCards
//
//  Created by Douglas Mason on 1/13/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ChangeCategorySelection.h"

@class Card;

@interface ChangeCategorySelectionForCard : NSObject <ChangeCategorySelection>
{
	Card *_card;
	NSUInteger _foreignKeyCategoryId;
}

- (id)initWithCard:(Card*)card category:(int)foreignKeyCategoryId;

@end
