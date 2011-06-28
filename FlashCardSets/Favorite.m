//
//  Favorite.m
//  LangFlashCards
//
//  Created by Doug Mason on 12/17/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "Favorite.h"
#import "Deck.h"
#import "CDLDatabase.h"

@interface Favorite(PrivateMethods)

- (void)insert;
- (void)update;

@end

@implementation Favorite
@synthesize favoriteId, foreignKeyDeckId;

- (void)dealloc
{
	[self setForeignKeyDeckId:nil];
	[super dealloc];
}

+ (NSString *)tableIdentifier
{
	return @"Favorite";
}

+ (NSString *)primaryKeyIdentifier
{
	return @"favoriteId";
}

+ (NSString *)foreignKeyDeckIdColumnIdentifier
{
	return @"foreignKeyDeckId";
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
	
	NSString *sql = [NSString stringWithFormat:@"delete from %@ where favoriteId = ?", [[self class] tableName]];
	
	[db executeSqlWithParameters:sql, [NSNumber numberWithUnsignedInt:favoriteId], nil];
	savedInDatabase = NO;
	favoriteId = 0;
}

- (void)update
{
	CDLDatabase *db = [CDLModel database];
	
	NSString *setValues = [[[self columnsWithoutPrimaryKey] componentsJoinedByString:@" = ?, "] stringByAppendingString:@" = ?"];
	NSString *sql = [NSString stringWithFormat:@"update %@ set %@ where favoriteId = ?", [[self class] tableName], setValues];
	NSArray *parameters = [[self propertyValues] arrayByAddingObject:[NSNumber numberWithUnsignedInt:favoriteId]];
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
	favoriteId = [db lastInsertRowId];
}

@end
