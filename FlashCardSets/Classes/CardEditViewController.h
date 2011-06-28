//
//  CardEditViewController.h
//  FlashNotes
//
//  Created by Douglas Mason on 12/20/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Constants.h"
#import "SaveDeleteDeckSelection.h"

@class Card;

@interface CardEditViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UIAlertViewDelegate, UIActionSheetDelegate>
{
	UITextField			*backSideTextField;
	Card				*card;
	UITableView			*cardInDecksList;
	NSArray				*decksCardsJoinData;
	NSArray				*deckData;
	NSArray				*categoryData;
	BOOL				didComeFromDeckSelection;
	NSUInteger			foreignKeyDeckId;
	UITextField			*frontSideTextField;
	BOOL				isNewCard;
}

@property (nonatomic, retain) IBOutlet UITextField				*backSideTextField;
@property (nonatomic, retain) Card								*card;
@property (nonatomic, retain) IBOutlet UITableView				*cardInDecksList;
@property (nonatomic, retain) NSArray							*decksCardsJoinData;
@property (nonatomic, retain) NSArray							*deckData;
@property (nonatomic) BOOL										didComeFromDeckSelection;
@property (nonatomic) NSUInteger								foreignKeyDeckId;
@property (nonatomic, retain) IBOutlet UITextField				*frontSideTextField;
@property (nonatomic) BOOL										isNewCard;

- (IBAction)save:(id)sender;
- (IBAction)remove:(id)sender;
- (IBAction)addToDecks:(id)sender;
- (IBAction)selectCategory:(id)sender;
- (IBAction)backgroundTap:(id)sender;
- (IBAction)textFieldDoneEditing:(id)sender;

- (NSArray *)loadJoinsArray;
- (NSArray *)findBySpecificDeckId:(int)deckId bySepcificCardId:(int)cardId;

- (NSArray *)loadDecksData;
- (NSArray *)loadDecksCardsJoinData;

- (NSArray *)loadCategoryData;

- (id<SaveDeleteDeckSelection>)createSaveDeleteDeckSelectionWithDeckId:(int)dId withCardId:(int)cId filter:(SaveDeleteDeckSelectionEnum)filter;

@end
