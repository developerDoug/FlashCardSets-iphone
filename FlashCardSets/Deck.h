//
//  Decks.h
//  LangFlashCards
//
//  Created by Doug Mason on 12/16/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "CDLModel.h"
#import "Constants.h"

@interface Deck : CDLModel {
	NSUInteger deckId;
	NSString *title;
}

@property (nonatomic) NSUInteger deckId;
@property (nonatomic, retain) NSString *title;
+ (NSString *)tableIdentifier;
+ (NSString *)primaryKeyIdentifier;
+ (NSString *)titleColumnIdentifier;

- (void)save;
- (void)remove;

@end
