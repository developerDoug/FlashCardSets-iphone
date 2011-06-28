//
//  DecksCardsJoin.h
//  LangFlashCards
//
//  Created by Doug Mason on 12/16/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "CDLModel.h"
#import "Constants.h"

@interface DecksCardsJoin : CDLModel {
	NSUInteger decksCardsJoinId;
	NSNumber *foreignKeyDeckId;
	NSNumber *foreignKeyCardId;
}

@property (nonatomic) NSUInteger decksCardsJoinId;
@property (nonatomic, retain) NSNumber *foreignKeyDeckId;
@property (nonatomic, retain) NSNumber *foreignKeyCardId;

+ (NSString *)tableIdentifier;
+ (NSString *)primaryKeyIdentifier;
+ (NSString *)foreignKeyDeckIdColumnIdentifier;
+ (NSString *)foreignKeyCardIdColumnIdentifier;

- (void)save;
- (void)remove;

@end
