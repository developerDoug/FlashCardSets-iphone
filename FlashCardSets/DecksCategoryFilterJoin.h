//
//  DecksCategoryFilterJoin.h
//  LanguageCards
//
//  Created by Douglas Mason on 1/14/10.
//  Copyright 2010 All rights reserved.
//

#import "CDLModel.h"
#import "Constants.h"

@interface DecksCategoryFilterJoin : CDLModel 
{
	NSUInteger decksCategoryFilterJoinId;
	NSUInteger foreignKeyDeckId;
	NSUInteger foreignKeyCategoryId;
}

@property (nonatomic) NSUInteger decksCategoryFilterJoinId;
@property (nonatomic) NSUInteger foreignKeyDeckId;
@property (nonatomic) NSUInteger foreignKeyCategoryId;

+ (NSString*)tableIdentifier;
+ (NSString*)primaryKeyIdentifier;
+ (NSString*)foreignKeyDeckIdColumnIdentifier;
+ (NSString*)foreignKeyCategoryIdColumnIdentifier;

- (void)save;
- (void)remove;

@end
