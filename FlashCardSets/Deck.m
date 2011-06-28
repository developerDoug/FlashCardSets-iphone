//
//  Decks.m
//  LangFlashCards
//
//  Created by Doug Mason on 12/16/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "Deck.h"
#import "CDLDatabase.h"

@interface Deck(PrivateMethods)

- (void)insert;
- (void)update;

@end

@implementation Deck
@synthesize deckId;
@synthesize title;

- (void)dealloc
{
	[self setTitle:nil];
	[super dealloc];
}

+ (NSString *)tableIdentifier
{
	return @"Deck";
}

+ (NSString *)primaryKeyIdentifier
{
	return @"deckId";
}

+ (NSString *)titleColumnIdentifier
{
	return @"title";
}

- (void)save
{
	[[self class] assertDatabaseExists];
	
	if (!savedInDatabase)
	{
		[self insert];
	}
	else 
	{
		[self update];
	}
	
}

- (void)remove
{
	CDLDatabase *db = [CDLModel database];
	
	[[self class] assertDatabaseExists];
	if (!savedInDatabase)
	{
		return;
	}
	
	NSString *sql = [NSString stringWithFormat:@"delete from %@ where deckId = ?", [[self class] tableName]];
	
	[db executeSqlWithParameters:sql, [NSNumber numberWithUnsignedInt:deckId], nil];
	savedInDatabase = NO;
	deckId = 0;
}

- (void)update
{
	CDLDatabase *db = [CDLModel database];
	
	NSString *setValues = [[[self columnsWithoutPrimaryKey] componentsJoinedByString:@" = ?, "] stringByAppendingString:@" = ?"];
	NSString *sql = [NSString stringWithFormat:@"update %@ set %@ where deckId = ?", [[self class] tableName], setValues];
	NSArray *parameters = [[self propertyValues] arrayByAddingObject:[NSNumber numberWithUnsignedInt:deckId]];
	[db executeSql:sql withParameters:parameters];
	savedInDatabase = YES;
}

- (void)insert
{
	CDLDatabase *db = [CDLModel database];
	
	NSMutableArray *parameterList = [NSMutableArray array];
	
	NSArray *columnsWithoutPrimaryKey = [self columnsWithoutPrimaryKey];
	
	for (int i = 0; i < [columnsWithoutPrimaryKey count]; i++)
	{
		[parameterList addObject:@"?"];
	}
	
	NSString *sql = [NSString stringWithFormat:@"insert into %@ (%@) values(%@)", [[self class] tableName], [columnsWithoutPrimaryKey componentsJoinedByString:@","], [parameterList componentsJoinedByString:@","]];
	[db executeSql:sql withParameters:[self propertyValues]];
	savedInDatabase = YES;
	deckId = [db lastInsertRowId];
}

@end
