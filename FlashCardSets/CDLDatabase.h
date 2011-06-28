//
//  CDLDatabase.h
//  LangFlashCards
//
//  Created by Doug Mason on 12/16/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
// 

#import <Foundation/Foundation.h>
#import <sqlite3.h>
#import "Constants.h"

@interface CDLDatabase : NSObject {
	NSString *pathToDatabase;
	sqlite3 *database;
}

@property (nonatomic, retain) NSString *pathToDatabase;

- (id)initWithPath:(NSString *)filePath;
- (id)initWithFileName:(NSString *)fileName;

- (void)close;
- (NSArray *)executeSql:(NSString *)sql;
- (NSArray *)executeSqlWithParameters:(NSString *)sql, ...;
- (NSArray *)executeSql:(NSString *)sql withParameters:(NSArray *)parameters;
- (NSArray *)executeSql:(NSString *)sql withParameters:(NSArray *)parameters withClassForRow:(Class)rowClass;
- (NSArray *)tableNames;
- (void)beginTransaction;
- (void)commit;
- (void)rollBack;
- (NSArray *)columnsForTableName:(NSString *)tableName;
- (NSUInteger)lastInsertRowId;
@end
