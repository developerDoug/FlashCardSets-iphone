//
//  DecksCardsJoin.m
//  LangFlashCards
//
//  Created by Doug Mason on 12/16/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "DecksCardsJoin.h"
#import "CDLDatabase.h"

@interface DecksCardsJoin(PrivateMethods)

- (void)insert;
- (void)update;

@end

@implementation DecksCardsJoin
@synthesize decksCardsJoinId, foreignKeyDeckId, foreignKeyCardId;

- (void)dealloc
{
	[self setForeignKeyDeckId:nil];
	[self setForeignKeyCardId:nil];
	[super dealloc];
}

+ (NSString *)tableIdentifier
{
	return [@"DecksCardsJoin" autorelease];
}

+ (NSString *)primaryKeyIdentifier
{
	return [@"decksCardsJoinId" autorelease];
}

+ (NSString *)foreignKeyDeckIdColumnIdentifier
{
	return [@"foreignKeyDeckId" autorelease];
}

+ (NSString *)foreignKeyCardIdColumnIdentifier
{
	return [@"foreignKeyCardId" autorelease];
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
	
	NSString *sql = [NSString stringWithFormat:@"delete from %@ where decksCardsJoinId = ?", [[self class] tableName]];
	
	[db executeSqlWithParameters:sql, [NSNumber numberWithUnsignedInt:decksCardsJoinId], nil];
	savedInDatabase = NO;
	decksCardsJoinId = 0;
}

- (void)update
{
	CDLDatabase *db = [CDLModel database];
	
	NSString *setValues = [[[self columnsWithoutPrimaryKey] componentsJoinedByString:@" = ?, "] stringByAppendingString:@" = ?"];
	NSString *sql = [NSString stringWithFormat:@"update %@ set %@ where decksCardsJoinId = ?", [[self class] tableName], setValues];
	NSArray *parameters = [[self propertyValues] arrayByAddingObject:[NSNumber numberWithUnsignedInt:decksCardsJoinId]];
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
	decksCardsJoinId = [db lastInsertRowId];
}

@end
