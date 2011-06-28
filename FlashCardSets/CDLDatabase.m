//
//  CDLDatabase.m
//  LangFlashCards
//
//  Created by Doug Mason on 12/16/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "CDLDatabase.h"
#import "DebugOutput.h"

#pragma mark -
#pragma mark Methods -- PrivateMethods

@interface CDLDatabase(PrivateMethods)

- (void)open;
- (void)raiseSqliteException:(NSString *)errorMessage;

- (NSArray *)columnNamesForStatement:(sqlite3_stmt *)statement;
- (NSArray *)columnTypesForStatement:(sqlite3_stmt *)statement;
- (int)typeForStatement:(sqlite3_stmt *)statement column:(int)column;
- (int)columnTypeToInt:(NSString *)columnType;

- (void)copyValuesFromStatement:(sqlite3_stmt *)statement 
						  toRow:(id)row
					  queryInfo:(NSDictionary *)queryInfo
					columnTypes:(NSArray *)columnTypes
					columnNames:(NSArray *)columnNames;

- (id)valueFromStatement:(sqlite3_stmt *)statement
				  column:(int)column
			   queryInfo:(NSDictionary *)queryInfo
			 columnTypes:(NSArray *)columnTypes;

- (void)bindArguments:(NSArray *)arguments 
		  toStatement:(sqlite3_stmt *)statement 
			queryInfo:(NSDictionary *)queryInfo;

- (NSArray *)tables;

@end

#pragma mark Methdos -- End of PrivateMethods
#pragma mark -

@implementation CDLDatabase
@synthesize pathToDatabase;

// Init with the path to the database.
// Set the path of the database to the var self.pathToDatabase
// Also open a connection to the sqlite3 database
- (id)initWithPath:(NSString *)filePath
{
	self = [super init];
	if (self != nil)
	{
		self.pathToDatabase = filePath;
		[self open];
	}
	
	return self;
}

// Init with the name of the database file.
// It will look through the directories in the sandboxed app
// and get the path and then will call
// (id)initWithPath:(NSString *)filePath to set
// the path to the pathToDatabase var and will open a connection.
- (id)initWithFileName:(NSString *)fileName
{
	BOOL success;
	NSFileManager *fileManager = [NSFileManager defaultManager];
	NSError *error;
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	NSString *writableDBPath = [documentsDirectory stringByAppendingPathComponent:fileName];
	success = [fileManager fileExistsAtPath:writableDBPath];
	
#if (APPLICATION_DEBUG_VERBOSE)
	debug(@"documentsDirectory:%@", documentsDirectory);
	debug(@"writableDBPath:%@", writableDBPath);
	debug(@"is file in that dir:%@", (success) ? @"Yes" : @"No");
#endif
	
	if (success)
	{
		return [self initWithPath:writableDBPath];
	}
	
	NSString *defaultDBPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:fileName];
	success = [fileManager copyItemAtPath:defaultDBPath toPath:writableDBPath error:&error];
	
#if (APPLICATION_DEBUG_VERBOSE)
	debug(@"bundle resource path:%@", defaultDBPath);
	debug(@"did file get copied:%@", (success) ? @"Yes" : @"No");
#endif
	
	return [self initWithPath:writableDBPath];
}

// Release variables when this obj is to be deallocated.
- (void)dealloc
{
	[self close];
	[pathToDatabase release];
	
	database = nil;
	
	[super dealloc];
}

#pragma mark -
#pragma mark Methods -- Connections

// Close the connection to the database.
- (void)close
{
	if (sqlite3_close(database) != SQLITE_OK)
	{
		[self raiseSqliteException:@"failed to close database with message '%S'."];
	}
}

- (void)open
{
	// opens the database, creating the file if it does not already exist
#if (APPLICATION_DEBUG_GENERAL)
	debug(@"pathToDatabase:%@", self.pathToDatabase);
#endif
	if (sqlite3_open([self.pathToDatabase UTF8String], &database) != SQLITE_OK)
	{
		sqlite3_close(database);
		[self raiseSqliteException:@"Failed to open database with message '%S'."];
	}
}

#pragma mark -
#pragma mark Methods -- Exception Handling

- (void)raiseSqliteException:(NSString *)errorMessage
{
	[NSException raise:@"DMDatabaseSQLiteException" format:errorMessage, sqlite3_errmsg16(database)];
}

#pragma mark -
#pragma mark Methods -- Execute 

// Don't fully understand this function
// but it looks at the arguments passed in
// and finds the parameters to be executed with the sql
- (NSArray *)executeSqlWithParameters:(NSString *)sql, ...
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
	
	return [self executeSql:sql withParameters:arguments];
}

// When needing to execute straight sql, this is the function that will do it.
// Will simply call the helper function: -(NSArray *)executeSql:(NSString *)sql withParameters:(NSArray *)parameters
- (NSArray *)executeSql:(NSString *)sql
{
	return [self executeSql:sql withParameters:nil];
}

// When executing sql with parameters and not associating a Active Record Object (A class with the same name as a particular table)
// use this function. This function will return an array of dictionaries. 
- (NSArray *)executeSql:(NSString *)sql withParameters:(NSArray *)parameters
{
	return [self executeSql:sql withParameters:parameters withClassForRow:[NSMutableDictionary class]];
}

// This function does the actual querying of the database.
- (NSArray *)executeSql:(NSString *)sql withParameters:(NSArray *)parameters withClassForRow:(Class)rowClass
{
	NSMutableDictionary *queryInfo = [NSMutableDictionary dictionary];
	[queryInfo setObject:sql forKey:@"sql"];
	
	if (parameters == nil)
	{
		parameters = [NSArray array];
	}
	
	// we now add the parameters to queryInfo
	[queryInfo setObject:parameters forKey:@"parameters"];
	
	NSMutableArray *rows = [NSMutableArray array];
	
#if (APPLICATION_DEBUG_VERBOSE)
	debug(@"SQL:%@ \n parameters:%@", sql, parameters);
#endif
	
	sqlite3_stmt *statement = nil;
	if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL) == SQLITE_OK)
	{
		[self bindArguments:parameters toStatement:statement queryInfo:queryInfo];
		
		BOOL needsToFetchColumnTypesAndNames = YES;
		NSArray *columnTypes = nil;
		NSArray *columnNames = nil;
		
		while (sqlite3_step(statement) == SQLITE_ROW)
		{
			if (needsToFetchColumnTypesAndNames)
			{
				columnTypes = [self columnTypesForStatement:statement];
				columnNames = [self columnNamesForStatement:statement];
				needsToFetchColumnTypesAndNames = NO;
			}
			
			id row = [[rowClass alloc] init];
			[self copyValuesFromStatement:statement
									toRow:row
								queryInfo:queryInfo
							  columnTypes:columnTypes
							  columnNames:columnNames];
			
			[rows addObject:row];
			[row release];
		}
	}
	else 
	{
		sqlite3_finalize(statement);
		[self raiseSqliteException:[[NSString stringWithFormat:@"failed to execute statement: '%@', parameters: '%@' with message: ", sql, parameters] stringByAppendingString:@"%S"]];
	}
	
	sqlite3_finalize(statement);
	
	return rows;
}

#pragma mark -
#pragma mark Methods -- Column Lookup

- (NSArray *)columnsForTableName:(NSString *)tableName
{
	NSArray *results = [self executeSql:[NSString stringWithFormat:@"pragma table_info(%@)", tableName]];
	return [results valueForKey:@"name"];
}

- (NSArray *)columnNamesForStatement:(sqlite3_stmt *)statement
{
	int columnCount = sqlite3_column_count(statement);
	
	NSMutableArray *columnNames = [NSMutableArray array];
	for (int i = 0; i < columnCount; i++)
	{
		[columnNames addObject:[NSString stringWithUTF8String:sqlite3_column_name(statement, i)]];
	}
	
	return columnNames;
}

- (NSArray *)columnTypesForStatement:(sqlite3_stmt *)statement
{
	int columnCount = sqlite3_column_count(statement);
	
	NSMutableArray *columnTypes = [NSMutableArray array];
	for (int i = 0; i < columnCount; i++)
	{
		[columnTypes addObject:[NSNumber numberWithInt:[self typeForStatement:statement column:i]]];
	}
	
	return columnTypes;
}

- (int)typeForStatement:(sqlite3_stmt *)statement column:(int)column
{
	const char *columnType = sqlite3_column_decltype(statement, column);
	
	if (columnType != NULL)
	{
		return [self columnTypeToInt:[[NSString stringWithUTF8String:columnType] uppercaseString]];
	}
	
	return sqlite3_column_type(statement, column);
}

- (int)columnTypeToInt:(NSString *)columnType
{
	if ([columnType isEqualToString:@"INTEGER"])
	{
		return SQLITE_INTEGER;
	}
	else if ([columnType isEqualToString:@"REAL"])
	{
		return SQLITE_FLOAT;
	}
	else if ([columnType isEqualToString:@"TEXT"])
	{
		return SQLITE_TEXT;
	}
	else if ([columnType isEqualToString:@"BLOB"])
	{
		return SQLITE_BLOB;
	}
	else if ([columnType isEqualToString:@"NULL"])
	{
		return SQLITE_NULL;
	}
	
	return SQLITE_TEXT;
}

- (void)copyValuesFromStatement:(sqlite3_stmt *)statement 
						  toRow:(id)row
					  queryInfo:(NSDictionary *)queryInfo
					columnTypes:(NSArray *)columnTypes
					columnNames:(NSArray *)columnNames
{
	int columnCount = sqlite3_column_count(statement);
	for (int i = 0; i < columnCount; i++)
	{
		id value = [self valueFromStatement:statement column:i queryInfo:queryInfo columnTypes:columnTypes];
		if (value != nil)
		{
			[row setValue:value forKey:[columnNames objectAtIndex:i]];
		}
	}
}

#pragma mark -
#pragma mark Method Mapping SQL Types to Objective C Types

- (id)valueFromStatement:(sqlite3_stmt *)statement
				  column:(int)column
			   queryInfo:(NSDictionary *)queryInfo
			 columnTypes:(NSArray *)columnTypes
{
	int columnType = [[columnTypes objectAtIndex:column] intValue];
	
	// force conversion to the declared type using sql conversions; this save some
	// problems with NSNull being assigned to non-object values
	if (columnType == SQLITE_INTEGER)
	{
		return [NSNumber numberWithInt:sqlite3_column_int(statement, column)];
	}
	else if (columnType == SQLITE_FLOAT)
	{
		return [NSNumber numberWithDouble:sqlite3_column_double(statement, column)];
	}
	else if (columnType == SQLITE_TEXT)
	{
		const char *text = (const char *)sqlite3_column_text(statement, column);
		if (text != nil)
		{
			return [NSString stringWithUTF8String:text];
		}
		else
		{
			return nil;
		}
	}
	else if (columnType == SQLITE_BLOB)
	{
		// create an NSData object with the same size as the BLOB
		return [NSData dataWithBytes:sqlite3_column_blob(statement, column) length:sqlite3_column_bytes(statement, column)];
	}
	else if (columnType == SQLITE_NULL)
	{
		return nil;
	}
	
#if (APPLICATION_DEBUG_VERBOSE)
	debug(@"Unrecognized SQL column type: %i for sql: %@", columnType, [queryInfo objectForKey:@"sql"]);
#endif
	
	return nil;
}

#pragma mark -
#pragma mark Method -- Table Lookup

- (NSArray *)tables
{
	return [self executeSql:@"select * from sqlite_master where type = 'table'"];
}

- (NSArray *)tableNames
{
	return [[self tables] valueForKey:@"name"];
}

#pragma mark -
#pragma mark Method -- Binding Objective C Types to SQL Types

- (void)bindArguments:(NSArray *)arguments toStatement:(sqlite3_stmt *)statement queryInfo:(NSDictionary *)queryInfo
{
	int expectedArguments = sqlite3_bind_parameter_count(statement);
	
	NSAssert2(expectedArguments == [arguments count], @"Number of bound parameters does not match for sql: %@ parameters: '%@'", [queryInfo objectForKey:@"sql"], [queryInfo objectForKey:@"parameters"]);
	
	for (int i = 1; i <= expectedArguments; i++)
	{
		id argument = [arguments objectAtIndex:i - 1];
		if ([argument isKindOfClass:[NSString class]])
		{
			sqlite3_bind_text(statement, i, [argument UTF8String], -1, SQLITE_TRANSIENT);
		}
		else if ([argument isKindOfClass:[NSData class]])
		{
			sqlite3_bind_blob(statement, i, [argument bytes], [argument length], SQLITE_TRANSIENT);
		}
		else if ([argument isKindOfClass:[NSDate class]])
		{
			sqlite3_bind_double(statement, i, [argument timeIntervalSince1970]);
		}
		else if ([argument isKindOfClass:[NSNumber class]])
		{
			sqlite3_bind_double(statement, i, [argument doubleValue]);
		}
		else if ([argument isKindOfClass:[NSNull class]])
		{
			sqlite3_bind_null(statement, i);
		}
		else 
		{
			sqlite3_finalize(statement);
			[NSException raise:@"Unrecognized object type" 
						format:@"Active record doesn'it know how to handle object:'%@' bound to sql: %@ position: %i", argument, [queryInfo objectForKey:@"sql"], i];
		}
		
	}
}

#pragma mark -
#pragma mark Method -- TRANSACTIONS

- (void)beginTransaction
{
	[self executeSql:@"BEGIN IMMEDIATE TRANSACTION;"];
}

- (void)commit
{
	[self executeSql:@"COMMIT TRANSACTION;"];
}

- (void)rollBack
{
	[self executeSql:@"ROLLBACK TRANSACTION;"];
}

#pragma mark -
#pragma mark Method -- Determine Highest Primary Key Value

- (NSUInteger)lastInsertRowId
{
	return (NSUInteger)sqlite3_last_insert_rowid(database);
}

@end
