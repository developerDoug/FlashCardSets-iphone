//
//  Category.m
//  LanguageCards
//
//  Created by Douglas Mason on 1/12/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "Category.h"
#import "CDLDatabase.h"

@interface Category(PrivateMethods)

- (void)insert;
- (void)update;

@end

@implementation Category

@synthesize categoryId;
@synthesize categoryName;

- (void)dealloc
{
	[self setCategoryName:nil];
	[super dealloc];
}

+ (NSString*)tableIdentifier
{
	return [@"Category" autorelease];
}

+ (NSString*)primaryKeyIdentifier
{
	return [@"categoryId" autorelease];
}

+ (NSString*)categoryNameColumnIdentifier
{
	return [@"categoryName" autorelease];
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
	
	NSString *sql = [NSString stringWithFormat:@"delete from %@ where categoryId = ?", [[self class] tableName]];
	
	[db executeSqlWithParameters:sql, [NSNumber numberWithUnsignedInt:categoryId], nil];
	savedInDatabase = NO;
	categoryId = 0;
}

- (void)update
{
	CDLDatabase *db = [CDLModel database];
	
	NSString *setValues = [[[self columnsWithoutPrimaryKey] componentsJoinedByString:@" = ?, "] stringByAppendingString:@" = ?"];
	NSString *sql = [NSString stringWithFormat:@"update %@ set %@ where categoryId = ?", [[self class] tableName], setValues];
	NSArray *parameters = [[self propertyValues] arrayByAddingObject:[NSNumber numberWithUnsignedInt:categoryId]];
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
	categoryId = [db lastInsertRowId];
}

@end
