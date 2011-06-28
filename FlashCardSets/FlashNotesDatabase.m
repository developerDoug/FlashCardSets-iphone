//
//  LangFlashCardsDatabase.m
//  LangFlashCards
//
//  Created by Doug Mason on 12/16/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "FlashNotesDatabase.h"
#import "FlashCardSetsAppDelegate.h"
#import "DebugOutput.h"
#import "CDLModel.h"

@interface FlashNotesDatabase(PrivateMethods)

- (id)initWithMigrations;

- (void)createApplicationPropertiesTable_v1;
- (void)createApplicationSettingsTable_v1;
- (void)createDecksTable_v1;
- (void)createCardTable_v1;
- (void)createCardTable_v1_1;
- (void)createCategoryTable_v1_1;
- (void)createDecksCardsJoinTable_v1;
- (void)createDecksCategoryFilterJoinTable_v1_1;
- (void)createFavoriteTable_v1;

- (void)insertIntoApplicationPropertiesTableWithName:(NSString*)name value:(NSString*)stringAsFloatValueForValue detail:(NSString*)detail;
- (void)insertIntoApplicationSettingWithDisplayName:(NSString*)displayName tagIdentifier:(NSString*)tagIdentifier value:(int)value;

- (void)insertIntoDeckTable_v1_WithTitle:(NSString*)title;
- (void)insertIntoCardTable_v1_WithFrontSide:(NSString*)frontSide backSide:(NSString*)backSide;
- (void)insertIntoCardTable_v1_1_WithFrontSide:(NSString*)frontSide backSide:(NSString*)backSide category:(int)foreignKeyCategoryId;
- (void)insertIntoDecksCardsJointTable_v1_WithDeckId:(int)deckId cardId:(int)cardId;
- (void)insertIntoDecksCategoryFilterJoinTable_v1_1_WithDectId:(int)deckId category:(int)categoryId;
- (void)insertIntoCategories_v1_1_WithCategoryName:(NSString*)categoryName;

- (void)updateApplicationProperty:(NSString *)propertyName value:(id)value;
- (id)getApplicationProperty:(NSString *)propertyName;
- (void)setDatabaseVersion:(float)newVersionNumber;
- (float)databaseVersion;

- (void)dropApplicationPropertiesTable;
- (void)dropDecksTable;
- (void)dropCardTable;
- (void)dropDecksCardsJoinTable;
- (void)deleteApplicationPropertiesTable;
- (void)deleteDecksTable;
- (void)deleteCardsTable;
- (void)deleteDecksCardsJoinTable;

- (NSString*)getBundleVersionInInfoPListFile;

- (void)upgradeToDatabaseVersion_1_1;
- (void)upgradeToDatabaseVersion_1_2;
- (void)upgradeToDatabaseVersion_1_3;

@end

@implementation FlashNotesDatabase

+ (FlashNotesDatabase*)sharedLanguageCardsDatabase
{
	static FlashNotesDatabase *sharedLanguageCardsDatabaseInstance;
	
	@synchronized(self) 
	{
		if (!sharedLanguageCardsDatabaseInstance)
		{
			sharedLanguageCardsDatabaseInstance = [[FlashNotesDatabase alloc] initWithMigrations];
		}
	}
	
	return sharedLanguageCardsDatabaseInstance;
}	

// was initWithMigrations
- (id)initWithMigrations
{
	self = [super initWithFileName:@"languageCards.sqlite"];
	if (self != nil)
	{
		[CDLModel setDatabase:self];
	}
	return self;
}


- (void)runMigrations
{
	NSArray *tableNames = [self tableNames];
	
	if (![tableNames containsObject:@"ApplicationProperties"])
	{
		// First Version schema
		[self beginTransaction];
		
		[self createApplicationPropertiesTable_v1];
		[self createApplicationSettingsTable_v1];
		[self createDecksTable_v1];
		[self createCardTable_v1];
		[self createFavoriteTable_v1];
		[self createDecksCardsJoinTable_v1];
		
		// add any other version 1.0 schema creation code here
		// insert into database
		[self insertIntoApplicationPropertiesTableWithName:@"databaseVersion" value:@"1.0" detail:@"Development Mode"];
		
		[self insertIntoApplicationSettingWithDisplayName:@"Cards or Decks?" tagIdentifier:@"SearchForCardsOrDecks" value:1];
		[self insertIntoApplicationSettingWithDisplayName:@"Display Front Card?" tagIdentifier:@"DisplayFrontCard" value:1];
		[self insertIntoApplicationSettingWithDisplayName:@"Show Exit when playing cards?" tagIdentifier:@"AlwaysShowExitButtonWhenPlayingCards" value:0];
		[self insertIntoApplicationSettingWithDisplayName:@"Use opposite side when flipped?" tagIdentifier:@"ContinueWithOppositeSideWhenFlipped" value:0];
		[self insertIntoApplicationSettingWithDisplayName:@"Front or Back Card?" tagIdentifier:@"SortByFrontCard" value:1];
		[self insertIntoApplicationSettingWithDisplayName:@"Sort Ascending or Descending for Cards?" tagIdentifier:@"SortForCardByAsc" value:1];
		
		[self commit];
	}
	
	
	tableNames = [self tableNames];
	if ([tableNames containsObject:@"ApplicationProperties"])
	{	
		NSString *formatedBundleVersion = [NSString stringWithFormat:@"%.1f", [[self getBundleVersionInInfoPListFile] floatValue]];
		NSString *formatedDatabaseVersion = [NSString stringWithFormat:@"%.1f", [[self getApplicationProperty:@"databaseVersion"] floatValue]];
		
		float bundleVersion = [formatedBundleVersion floatValue];
		float databaseVersion = [formatedDatabaseVersion floatValue];
		
		if (bundleVersion > databaseVersion)
		{
			float versionDifference = bundleVersion - databaseVersion;
			
			if ([[NSString stringWithFormat:@"%.1f", databaseVersion] isEqualToString:@"1.0"] &&
				[[NSString stringWithFormat:@"%.1f", versionDifference] isEqualToString:@"0.1"])
			{
				// upgrade to database version 1.1
				[self upgradeToDatabaseVersion_1_1];
			}
			else if ([[NSString stringWithFormat:@"%.1f", databaseVersion] isEqualToString:@"1.0"] &&
					 [[NSString stringWithFormat:@"%.1f", versionDifference] isEqualToString:@"0.2"])
			{
				// upgrade to database version 1.2
				[self upgradeToDatabaseVersion_1_1];
				[self upgradeToDatabaseVersion_1_2];
			}
			else if ([[NSString stringWithFormat:@"%.1f", databaseVersion] isEqualToString:@"1.0"] &&
					 [[NSString stringWithFormat:@"%.1f", versionDifference] isEqualToString:@"0.3"])
			{
				// upgrade to database version 1.3
				[self upgradeToDatabaseVersion_1_1];
				[self upgradeToDatabaseVersion_1_2];
				[self upgradeToDatabaseVersion_1_3];
			}
		}
	}
}

#pragma mark -
#pragma mark Table Creation Methods

- (void)createApplicationPropertiesTable_v1
{
	[self executeSql:@"CREATE TABLE ApplicationProperties (applicationPropertiesId INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, value FLOAT, detail TEXT)"];
}

- (void)createApplicationSettingsTable_v1
{
	[self executeSql:@"CREATE TABLE ApplicationSetting (applicationSettingId INTEGER PRIMARY KEY AUTOINCREMENT, applicationSettingDisplayName TEXT NOT NULL, applicationSettingTagIdentifier TEXT NOT NULL, applicationSettingValue INTEGER NOT NULL)"];
}

- (void)createDecksTable_v1
{
	[self executeSql:@"CREATE TABLE Deck (deckId INTEGER PRIMARY KEY AUTOINCREMENT, title TEXT NOT NULL)"];
}

- (void)createCardTable_v1
{
	[self executeSql:@"CREATE TABLE Card (cardId INTEGER PRIMARY KEY AUTOINCREMENT, frontSide TEXT NOT NULL, backSide TEXT NOT NULL)"];
}

- (void)createCardTable_v1_1
{
	[self executeSql:@"CREATE TABLE Card (cardId INTEGER PRIMARY KEY AUTOINCREMENT, frontSide TEXT NOT NULL, backSide TEXT NOT NULL, foreignKeyCategoryId INTEGER NOT NULL, foreign key (foreignKeyCategoryId) references Category(categoryId))"];
}

- (void)createCategoryTable_v1_1
{
	[self executeSql:@"CREATE TABLE Category (categoryId INTEGER PRIMARY KEY AUTOINCREMENT, categoryName TEXT NOT NULL)"];
}

- (void)createDecksCardsJoinTable_v1
{
	[self executeSql:@"CREATE TABLE DecksCardsJoin (decksCardsJoinId INTEGER PRIMARY KEY AUTOINCREMENT, foreignKeyDeckId INTEGER NOT NULL, foreignKeyCardId INTEGER NOT NULL, FOREIGN KEY (foreignKeyDeckId) REFERENCES Deck(deckId), FOREIGN KEY (foreignKeyCardId) REFERENCES Card(cardId))"];
}

- (void)createDecksCategoryFilterJoinTable_v1_1
{
	[self executeSql:@"CREATE TABLE DecksCategoryFilterJoin (decksCategoryFilterJoinId INTEGER PRIMARY KEY AUTOINCREMENT, foreignKeyDeckId INTEGER NOT NULL, foreignKeyCategoryId INTEGER NOT NULL, FOREIGN KEY (foreignKeyDeckId) REFERENCES Deck(deckId), FOREIGN KEY (foreignKeyCategoryId) REFERENCES Category(categoryId))"];
}

- (void)createFavoriteTable_v1
{
	[self executeSql:@"CREATE TABLE Favorite (favoriteId INTEGER PRIMARY KEY AUTOINCREMENT, foreignKeyDeckId INTEGER NOT NULL, FOREIGN KEY (foreignKeyDeckId) REFERENCES Deck(deckId))"];
}

#pragma mark -
#pragma mark Table Insertion Methods

- (void)insertIntoApplicationPropertiesTableWithName:(NSString *)name value:(NSString *)stringAsFloatValueForValue detail:(NSString *)detail
{
	[self executeSql:[NSString stringWithFormat:@"INSERT INTO ApplicationProperties (name, value, detail) values ('%@', %@, '%@')", name, stringAsFloatValueForValue, detail]];
}

- (void)insertIntoApplicationSettingWithDisplayName:(NSString *)displayName tagIdentifier:(NSString *)tagIdentifier value:(int)value
{
	[self executeSql:[NSString stringWithFormat:@"INSERT INTO ApplicationSetting (applicationSettingDisplayName, applicationSettingTagIdentifier, applicationSettingValue) VALUES ('%@', '%@', %d)", displayName, tagIdentifier, value]];
}

- (void)insertIntoDeckTable_v1_WithTitle:(NSString*)title
{
	[self executeSql:[NSString stringWithFormat:@"INSERT INTO Deck (title) values ('%@')", title]];
}

- (void)insertIntoCardTable_v1_WithFrontSide:(NSString*)frontSide backSide:(NSString*)backSide
{
	[self executeSql:[NSString stringWithFormat:@"INSERT INTO Card (frontSide, backSide) values ('%@', '%@')", frontSide, backSide]];
}

- (void)insertIntoCardTable_v1_1_WithFrontSide:(NSString *)frontSide backSide:(NSString *)backSide category:(int)foreignKeyCategoryId
{
	[self executeSql:[NSString stringWithFormat:@"INSERT INTO Card (frontSide, backSide, foreignKeyCategoryId) values ('%@', '%@', %d)", frontSide, backSide, foreignKeyCategoryId]];
}

- (void)insertIntoDecksCardsJointTable_v1_WithDeckId:(int)deckId cardId:(int)cardId
{
	[self executeSql:[NSString stringWithFormat:@"INSERT INTO DecksCardsJoin (foreignKeyDeckId, foreignKeyCardId) values (%d, %d)", deckId, cardId]];
}

- (void)insertIntoDecksCategoryFilterJoinTable_v1_1_WithDectId:(int)deckId category:(int)categoryId
{
	[self executeSql:[NSString stringWithFormat:@"INSERT INTO DecksCategoryFilterJoin (foreignKeyDeckId, foreignKeyCategoryId) values (%d, %d)", deckId, categoryId]];
}

- (void)insertIntoCategories_v1_1_WithCategoryName:(NSString *)categoryName
{
	[self executeSql:[NSString stringWithFormat:@"INSERT INTO Category (categoryName) values ('%@')", categoryName]];
}

#pragma mark -
#pragma mark Update ApplicationProperties Table Method

- (void)updateApplicationProperty:(NSString *)propertyName value:(id)value
{
	[self executeSqlWithParameters:@"UPDATE ApplicationProperties SET value = ? WHERE name = ?", value, propertyName, nil];
}

- (id)getApplicationProperty:(NSString *)propertyName
{
	NSArray *rows = [self executeSqlWithParameters:@"SELECT value FROM ApplicationProperties WHERE name = ?", propertyName, nil];
	if ([rows count] == 0)
	{
		return nil;
	}
	
	id object = [[rows lastObject] objectForKey:@"value"];
	if ([object isKindOfClass:[NSString class]])
	{
		object = [NSNumber numberWithFloat:[(NSString *)object floatValue]];
	}
	return object;
}

#pragma mark -
#pragma mark Setting and Getting Database Version Methods

- (void)setDatabaseVersion:(float)newVersionNumber
{
	return [self updateApplicationProperty:@"databaseVersion" value:[NSNumber numberWithFloat:newVersionNumber]];
}

- (float)databaseVersion
{
	return [[self getApplicationProperty:@"databaseVersion"] floatValue];
}

#pragma mark -
#pragma mark Drop Table Methods

- (void)dropApplicationPropertiesTable
{
	[self executeSql:@"DROP TABLE ApplicationProperties"];
}

- (void)dropDecksTable
{
	[self executeSql:@"DROP TABLE Decks"];
}

- (void)dropCardTable
{
	[self executeSql:@"DROP TABLE Card"];
}

- (void)dropDecksCardsJoinTable
{
	[self executeSql:@"DROP TABLE DecksCardsJoin"];
}

- (void)deleteApplicationPropertiesTable
{
	[self executeSql:@"DELETE FROM ApplicationProperteis"];
}

- (void)deleteDecksTable
{
	[self executeSql:@"DELETE FROM Decks"];
}

- (void)deleteCardTable
{
	[self executeSql:@"DELETE FROM Card"];
}

- (void)deleteDecksCardsJoinTable
{
	[self executeSql:@"DELETE FROM DecksCardsJoin"];
}

- (void)dealloc
{
	[super dealloc];
}

- (NSString*)getBundleVersionInInfoPListFile
{
	return [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
}

- (void)upgradeToDatabaseVersion_1_1
{
	[self beginTransaction];
	
	NSArray *tableNames = [self tableNames];
	NSArray *arrayOfCards = [self executeSql:@"SELECT * FROM Card"];
	NSArray *arrayOfDecks = [self executeSql:@"SELECT * FROM Deck"];
	
	if ([tableNames containsObject:@"Card"])
	{
		[self dropCardTable];
		[self dropDecksCardsJoinTable];
		
		[self createCardTable_v1_1];
		[self createDecksCardsJoinTable_v1];
	}
	
	if (![tableNames containsObject:@"Category"])
	{
		[self createCategoryTable_v1_1];
		[self insertIntoCategories_v1_1_WithCategoryName:@"NONE"];
		[self insertIntoCategories_v1_1_WithCategoryName:@"Adjective"];
		[self insertIntoCategories_v1_1_WithCategoryName:@"Adverb"];
		[self insertIntoCategories_v1_1_WithCategoryName:@"Noun"];
		[self insertIntoCategories_v1_1_WithCategoryName:@"Pronoun"];
		[self insertIntoCategories_v1_1_WithCategoryName:@"Verb"];
		[self insertIntoCategories_v1_1_WithCategoryName:@"Other"];
	}
	
	if (![tableNames containsObject:@"DecksCategoryFilterJoin"])
	{
		[self createDecksCategoryFilterJoinTable_v1_1];
	}
	
	if ([arrayOfCards count] > 0)
	{
		for (NSDictionary *dict in arrayOfCards)
		{
			[self insertIntoCardTable_v1_1_WithFrontSide:[dict valueForKey:@"frontSide"] backSide:[dict valueForKey:@"backSide"] category:6];
		}
	}
	
	if ([arrayOfDecks count] > 0)
	{
		for (NSDictionary *dict in arrayOfDecks)
		{
			NSUInteger deckId = [[dict valueForKey:@"deckId"] unsignedIntegerValue];
			[self insertIntoDecksCategoryFilterJoinTable_v1_1_WithDectId:deckId category:1];
		}
	}
	
	NSString *path = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"Cards.plist"];
	NSDictionary *plistDictionary = [NSDictionary dictionaryWithContentsOfFile:path];
	
	NSArray *verbsArray = [plistDictionary objectForKey:@"verbs"];
	NSArray *nounsArray = [plistDictionary objectForKey:@"nouns"];
	NSArray *adjectivesArray = [plistDictionary objectForKey:@"adjectives"];
	
	for (NSDictionary *dict in verbsArray)
	{
		[self insertIntoCardTable_v1_1_WithFrontSide:[dict valueForKey:@"frontSide"]
											backSide:[dict valueForKey:@"backSide"]
											category:[[dict valueForKey:@"categoryId"] integerValue]];
	}
	
	for (NSDictionary *dict in nounsArray)
	{
		[self insertIntoCardTable_v1_1_WithFrontSide:[dict valueForKey:@"frontSide"]
											backSide:[dict valueForKey:@"backSide"]
											category:[[dict valueForKey:@"categoryId"] integerValue]];
	}
	
	for (NSDictionary *dict in adjectivesArray)
	{
		[self insertIntoCardTable_v1_1_WithFrontSide:[dict valueForKey:@"frontSide"]
											backSide:[dict valueForKey:@"backSide"] 
											category:[[dict valueForKey:@"categoryId"] integerValue]];
	}
	
	arrayOfCards = [self executeSql:@"SELECT * FROM Card"];
	if ([arrayOfCards count] > 0)
	{
		for (NSDictionary *dict in arrayOfCards)
		{
			[self insertIntoDecksCardsJointTable_v1_WithDeckId:1 cardId:[[dict valueForKey:@"cardId"] unsignedIntegerValue]];
		}
	}
	
	[self setDatabaseVersion:1.1];
	
	[self commit];
}

- (void)upgradeToDatabaseVersion_1_2
{
	[self insertIntoApplicationSettingWithDisplayName:@"Search By Keyword or Creator" tagIdentifier:@"SearchByKeywordOrCreator" value:1];
	[self setDatabaseVersion:1.2];
}

- (void)upgradeToDatabaseVersion_1_3
{
	
}

@end
