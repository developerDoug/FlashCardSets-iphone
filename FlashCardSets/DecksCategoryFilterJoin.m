//
//  DecksCategoryFilterJoin.m
//  LanguageCards
//
//  Created by Douglas Mason on 1/14/10.
//  Copyright 2010 All rights reserved.
//

#import "DecksCategoryFilterJoin.h"
#import "CDLDatabase.h"

@interface DecksCategoryFilterJoin(PrivateMethods)

- (void)insert;
- (void)update;

@end

@implementation DecksCategoryFilterJoin

@synthesize decksCategoryFilterJoinId;
@synthesize foreignKeyDeckId;
@synthesize foreignKeyCategoryId;

- (void)dealloc
{
	[super dealloc];
}

+ (NSString*)tableIdentifier
{
	return [@"DecksCategoryFilterJoin" autorelease];
}

+ (NSString*)primaryKeyIdentifier
{
	return [@"decksCategoryFilterJoinId" autorelease];
}

+ (NSString*)foreignKeyDeckIdColumnIdentifier
{
	return [@"foreignKeyDeckId" autorelease];
}

+ (NSString*)foreignKeyCategoryIdColumnIdentifier
{
	return [@"foreignKeyCategoryId" autorelease];
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
	
	NSString *sql = [NSString stringWithFormat:@"delete from %@ where decksCategoryFilterJoinId = ?", [[self class] tableName]];
	
	[db executeSqlWithParameters:sql, [NSNumber numberWithUnsignedInt:decksCategoryFilterJoinId], nil];
	savedInDatabase = NO;
	decksCategoryFilterJoinId = 0;
}

- (void)update
{
	CDLDatabase *db = [CDLModel database];
	
	NSString *setValues = [[[self columnsWithoutPrimaryKey] componentsJoinedByString:@" = ?, "] stringByAppendingString:@" = ?"];
	NSString *sql = [NSString stringWithFormat:@"update %@ set %@ where decksCategoryFilterJoinId = ?", [[self class] tableName], setValues];
	NSArray *parameters = [[self propertyValues] arrayByAddingObject:[NSNumber numberWithUnsignedInt:decksCategoryFilterJoinId]];
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
	
	NSString *sql = [NSString stringWithFormat:@"insert into %@ (%@) values(%@)", 
					 [[self class] tableName],
					 [columnsWithoutPrimaryKey componentsJoinedByString:@","],
					 [parameterList componentsJoinedByString:@","]];
	[db executeSql:sql withParameters:[self propertyValues]];
	savedInDatabase = YES;
	decksCategoryFilterJoinId = [db lastInsertRowId];
}

@end
