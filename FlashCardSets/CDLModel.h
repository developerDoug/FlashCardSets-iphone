//
//  CDLModel.h
//  LangFlashCards
//
//  Created by Doug Mason on 12/16/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Constants.h"

@class CDLDatabase;
@interface CDLModel : NSObject {
	//NSUInteger primaryKey;
	BOOL savedInDatabase;
}
//@property (nonatomic) NSUInteger primaryKey;
@property (nonatomic) BOOL savedInDatabase;

+ (void)setDatabase:(CDLDatabase *)newDatabase;
+ (CDLDatabase *)database;
+ (NSString *)tableName;
+ (NSArray *)findWithSql:(NSString *)sql;
+ (NSArray *)findWithSql:(NSString *)sql withParameters:(NSArray *)parameters;
+ (NSArray *)findWithSqlWithParameters:(NSString *)sql, ...;
+ (NSArray *)findByColumn:(NSString *)column value:(id)value;
+ (NSArray *)findByColumn:(NSString *)column unsignedIntegerValue:(NSUInteger)value;
+ (NSArray *)findByColumn:(NSString *)column integerValue:(NSInteger)value;
+ (NSArray *)findByColumn:(NSString *)column doubleValue:(double)value;
+ (NSArray *)find:(NSUInteger)primaryKey;
+ (NSArray *)findAll;
+ (NSArray *)findWithSqlWithJoins:(NSString *)sql;
+ (NSArray *)findAllWithArrayOfJoins:(NSArray *)arrayOfJoins;
+ (NSArray *)findAllReturnNSArrayOfNSDictionaries;
+ (NSArray *)findAllReturnNSArrayOfNSDictionariesWithWhereClause:(NSString *)sqlWhere;
+ (NSArray *)findWithArrayOfJoins:(NSArray *)arrayOfJoins withWhere:(NSString *)sqlWithWhere;

- (NSArray *)propertyValues;
- (NSArray *)columns;
- (NSArray *)columnsWithoutPrimaryKey;

// Added this for testing, remove these methods from here, not in .m file to set object back to normal
+ (void)assertDatabaseExists;

@end
