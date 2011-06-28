//
//  Cards.m
//  LangFlashCards
//
//  Created by Doug Mason on 12/16/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "Card.h"
#import "CDLDatabase.h"

@interface Card(PrivateMethods)

- (void)insert;
- (void)update;

@end

@implementation Card
@synthesize cardId, frontSide, backSide, foreignKeyCategoryId;

- (void)dealloc
{
	[self setFrontSide:nil];
	[self setBackSide:nil];
	[super dealloc];
}

+ (NSString *)tableIdentifier
{
	return [@"Card" autorelease];
}

+ (NSString *)primaryKeyIdentifier
{
	return [@"cardId" autorelease];
}

+ (NSString *)frontSideColumnIdentifier
{
	return [@"frontSide" autorelease];
}

+ (NSString *)backSideColumnIdentifier
{
	return [@"backSide" autorelease];
}

+ (NSString *)foreignKeyCategoryIdColumnIdentifier
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
	
	NSString *sql = [NSString stringWithFormat:@"delete from %@ where cardId = ?", [[self class] tableName]];
	
	[db executeSqlWithParameters:sql, [NSNumber numberWithUnsignedInt:cardId], nil];
	savedInDatabase = NO;
	cardId = 0;
}

- (void)update
{
	CDLDatabase *db = [CDLModel database];
	
	NSString *setValues = [[[self columnsWithoutPrimaryKey] componentsJoinedByString:@" = ?, "] stringByAppendingString:@" = ?"];
	NSString *sql = [NSString stringWithFormat:@"update %@ set %@ where cardId = ?", [[self class] tableName], setValues];
	NSArray *parameters = [[self propertyValues] arrayByAddingObject:[NSNumber numberWithUnsignedInt:cardId]];
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
	cardId = [db lastInsertRowId];
}

@end
