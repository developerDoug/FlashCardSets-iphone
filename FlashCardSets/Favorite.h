//
//  Favorite.h
//  LangFlashCards
//
//  Created by Doug Mason on 12/17/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "CDLModel.h"
#import "Constants.h"

@class Deck;
@interface Favorite : CDLModel {
	NSUInteger favoriteId;
	NSNumber *foreignKeyDeckId;
}

@property (nonatomic) NSUInteger favoriteId;
@property (nonatomic, retain) NSNumber *foreignKeyDeckId;

+ (NSString *)tableIdentifier;
+ (NSString *)primaryKeyIdentifier;
+ (NSString *)foreignKeyDeckIdColumnIdentifier;

- (void)save;
- (void)remove;

@end
