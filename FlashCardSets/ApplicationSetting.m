//
//  ApplicationSetting.m
//  FlashNotes
//
//  Created by Douglas Mason on 12/23/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "ApplicationSetting.h"
#import "CDLDatabase.h"

@interface ApplicationSetting(PrivateMethods)

- (void)insert;
- (void)update;

@end

@implementation ApplicationSetting

@synthesize applicationSettingId;
@synthesize applicationSettingDisplayName;
@synthesize applicationSettingTagIdentifier;
@synthesize applicationSettingValue;

- (void)dealloc
{
	[self.applicationSettingDisplayName release];
	[self.applicationSettingTagIdentifier release];
	[super dealloc];
}

+ (NSString *)tableIdentifier
{
	return @"ApplicationSetting";
}

+ (NSString *)primaryKeyColumnIdentifier
{
	return @"applicationSettingId";
}

+ (NSString *)applicationSettingDisplayNameColumnIdentifier
{
	return @"applicationSettingDisplayName";
}

+ (NSString *)applicationSettingTagIdentifierColumnIdentifier
{
	return @"applicationSettingTagIdentifier";
}

+ (NSString *)applicationSettingValueColumnIdentifier
{
	return @"applicationSettingValue";
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
	
	NSString *sql = [NSString stringWithFormat:@"delete from %@ where applicationSettingId = ?", [[self class] tableName]];
	
	[db executeSqlWithParameters:sql, [NSNumber numberWithUnsignedInt:applicationSettingId], nil];
	savedInDatabase = NO;
	applicationSettingId = 0;
}

- (void)update
{
	CDLDatabase *db = [CDLModel database];
	
	NSString *setValues = [[[self columnsWithoutPrimaryKey] componentsJoinedByString:@" = ?, "] stringByAppendingString:@" = ?"];
	NSString *sql = [NSString stringWithFormat:@"update %@ set %@ where applicationSettingId = ?", [[self class] tableName], setValues];
	NSArray *parameters = [[self propertyValues] arrayByAddingObject:[NSNumber numberWithUnsignedInt:applicationSettingId]];
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
	applicationSettingId = [db lastInsertRowId];
}

@end
