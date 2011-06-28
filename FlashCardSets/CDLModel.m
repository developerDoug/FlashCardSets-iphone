//
//  CDLModel.m
//  LangFlashCards
//
//  Created by Doug Mason on 12/16/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "CDLModel.h"
#import "CDLDatabase.h"

static CDLDatabase *db = nil;
static NSMutableDictionary *tblCache = nil;

@interface CDLModel(PrivateMethods)

- (NSUInteger)lastInsertRowId;
- (void)update;
- (void)insert;
+ (NSString *)extractJoinsFromDictionary:(NSArray *)arrayOfJoins withSql:(NSString *)sql;
+ (NSString *)concatinateJoinKeyAndValueTogether:(NSArray *)joins withSql:(NSString *)sql;
+ (NSArray *)findWithSqlReturnNSDictionary:(NSString *)sql;

@end

@implementation CDLModel

@synthesize savedInDatabase;

+ (void)assertDatabaseExists
{
	NSAssert1(db, @"Database not set. Set the database using [CDLMdel setDatabase] before using ActiveRecord.", @"");
}

+ (void)setDatabase:(CDLDatabase *)newDatabase
{
	[db autorelease];
	db = [newDatabase retain];
}

+ (CDLDatabase *)database
{
	return db;
}

+ (NSString *)tableName
{
	return NSStringFromClass([self class]);
}

+ (NSArray *)findWithSql:(NSString *)sql
{
	return [self findWithSqlWithParameters:sql, nil];
}

+ (NSArray *)findWithSqlWithJoins:(NSString *)sql
{
	[self assertDatabaseExists];
	NSArray *results = [db executeSql:sql];
	return results;
}

+ (NSArray *)findWithSqlReturnNSDictionary:(NSString *)sql
{
	[self assertDatabaseExists];
	NSArray *results = [db executeSql:sql];
	return results;
}

+ (NSArray *)findWithSql:(NSString *)sql withParameters:(NSArray *)parameters
{
	[self assertDatabaseExists];
	NSArray *results = [db executeSql:sql withParameters:parameters withClassForRow:[self class]];
	[results setValue:[NSNumber numberWithBool:YES] forKey:@"savedInDatabase"];
	return results;
}

+ (NSArray *)findWithSqlWithParameters:(NSString *)sql, ...
{
	va_list argumentList;
	va_start(argumentList, sql);
	
	NSMutableArray *arguments = [NSMutableArray array];
	id argument;
	while ((argument = va_arg(argumentList, id)))
	{
		[arguments addObject:argument];
	}
	
	va_end(argumentList);
	
	return [self findWithSql:sql withParameters:arguments];
}

+ (NSArray *)findByColumn:(NSString *)column value:(id)value
{
	return [self findWithSqlWithParameters:[NSString stringWithFormat:@"select * from %@ where %@ = ?", [self tableName], column], value, nil];
}

+ (NSArray *)findByColumn:(NSString *)column unsignedIntegerValue:(NSUInteger)value
{
	return [self findByColumn:column value:[NSNumber numberWithUnsignedInteger:value]];
}

+ (NSArray *)findByColumn:(NSString *)column integerValue:(NSInteger)value
{
	return [self findByColumn:column value:[NSNumber numberWithInteger:value]];
}

+ (NSArray *)findByColumn:(NSString *)column doubleValue:(double)value
{
	return [self findByColumn:column value:[NSNumber numberWithDouble:value]];
}

+ (id)find:(NSUInteger)primaryKey
{
	NSArray *results = [self findByColumn:@"primaryKey" unsignedIntegerValue:primaryKey];
	if ([results count] < 1)
		return nil;
	
	return [results objectAtIndex:0];
}

+ (NSArray *)findAll
{
	return [self findWithSql:[NSString stringWithFormat:@"select * from %@", [self tableName]]];
}

+ (NSArray *)findAllWithArrayOfJoins:(NSArray *)arrayOfJoins
{
	return [self findWithSqlWithJoins:[self extractJoinsFromDictionary:arrayOfJoins withSql:[NSString stringWithFormat:@"select * from %@", [self tableName]]]];
}

+ (NSArray *)findWithArrayOfJoins:(NSArray *)arrayOfJoins withWhere:(NSString *)sqlWithWhere
{
	NSString *sqlWithJoins = [self extractJoinsFromDictionary:arrayOfJoins withSql:[NSString stringWithFormat:@"select * from %@", [self tableName]]];
	NSString *sqlWithJoinsAndWhere = [NSString stringWithFormat:@"%@ %@", sqlWithJoins, sqlWithWhere];
	
	return [self findWithSqlWithJoins:sqlWithJoinsAndWhere];
}

+ (NSArray *)findAllReturnNSArrayOfNSDictionaries
{
	return [self findWithSqlReturnNSDictionary:[NSString stringWithFormat:@"select * from %@", [self tableName]]];
}

+ (NSArray *)findAllReturnNSArrayOfNSDictionariesWithWhereClause:(NSString *)sqlWhere
{
	return [self findWithSqlReturnNSDictionary:[NSString stringWithFormat:@"select * from %@ %@", [self tableName], sqlWhere]];
}

+ (NSString *)extractJoinsFromDictionary:(NSArray *)arrayOfJoins withSql:(NSString *)sql
{	
	NSMutableArray *joins = [NSMutableArray arrayWithCapacity:[arrayOfJoins count] / 2];
	
	int j = 0;
	for (int i = 0; i < [arrayOfJoins count]; i=i+2)
	{
		NSString *tableAndColumn = [NSString stringWithFormat:@"%@.%@", [arrayOfJoins objectAtIndex:i], [arrayOfJoins objectAtIndex:i+1]];
		[joins insertObject:tableAndColumn atIndex:j];
		j++;
	}
	
	return [self concatinateJoinKeyAndValueTogether:joins withSql:sql];
}

+ (NSString *)concatinateJoinKeyAndValueTogether:(NSArray *)joins withSql:(NSString *)sql
{
	NSString *joinStatement = @"";
	for (int j = 0; j < [joins count]; j=j+2)
	{
		NSString *unrangedString = [joins objectAtIndex:j];
		NSRange rangeOfStringIndex = [unrangedString rangeOfString:@"."];
		NSString *rangeOfString = [unrangedString substringToIndex:rangeOfStringIndex.location];
		if (![joinStatement isEqualToString:@""])
			joinStatement = [NSString stringWithFormat:@"%@ INNER JOIN %@ ON %@ = %@", joinStatement, rangeOfString, [joins objectAtIndex:j+1], [joins objectAtIndex:j]];
		else
			joinStatement = [NSString stringWithFormat:@"INNER JOIN %@ ON %@ = %@", rangeOfString, [joins objectAtIndex:j+1], [joins objectAtIndex:j]];
	}
	
	if (![joinStatement isEqualToString:@""])
		sql = [NSString stringWithFormat:@"%@ %@", sql, joinStatement];
	
	return sql;
}

- (NSArray *)propertyValues
{
	NSMutableArray *values = [NSMutableArray array];
	for (NSString *columnName in [self columnsWithoutPrimaryKey])
	{
		id value = [self valueForKey:columnName];
		
		if (value != nil)
		{
			[values addObject:value];
		}
		else 
		{
			[values addObject:[NSNull null]];
		}
	}
	
	return values;
}

- (NSArray *)columns
{
	if (tblCache == nil)
	{
		tblCache = [[NSMutableDictionary dictionary] retain];
	}
	
	NSString *tableName = [[self class] tableName];
	NSArray *columns = [tblCache objectForKey:tableName];
	
	if (columns == nil)
	{
		columns = [db columnsForTableName:tableName];
		[tblCache setObject:columns forKey:tableName];
	}
	
	return columns;
}

- (NSArray *)columnsWithoutPrimaryKey
{
	NSMutableArray *columns = [NSMutableArray arrayWithArray:[self columns]];
	[columns removeObjectAtIndex:0];
	
	return columns;
}

- (void)dealloc
{
	[super dealloc];
}

@end
