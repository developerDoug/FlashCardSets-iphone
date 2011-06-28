//
//  LangFlashCardsDatabase.h
//  LangFlashCards
//
//  Created by Doug Mason on 12/16/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "CDLDatabase.h"
#import "Constants.h"

@class CDLModel;
@interface FlashNotesDatabase : CDLDatabase {

}

+ (FlashNotesDatabase*)sharedLanguageCardsDatabase;

- (void)runMigrations;

@end
