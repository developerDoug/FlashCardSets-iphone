//
//  CardEditViewController.m
//  FlashNotes
//
//  Created by Douglas Mason on 12/20/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "CardEditViewController.h"
#import "DecksCardsJoin.h"
#import "Card.h"
#import "Deck.h"
#import "Category.h"
#import "AlertTableView.h"
#import "FlashCardSetsAppDelegate.h"
#import "CDLDatabase.h"
#import "SaveDeckSelection.h"
#import "DeleteDeckSelection.h"
#import "DeleteCanNotDeckSelection.h"
#import "ChangeCategorySelection.h"
#import "ChangeCategorySelectionForCard.h"

@implementation CardEditViewController

@synthesize backSideTextField;
@synthesize card;
@synthesize cardInDecksList;
@synthesize decksCardsJoinData;
@synthesize deckData;
@synthesize didComeFromDeckSelection;
@synthesize foreignKeyDeckId;
@synthesize frontSideTextField;
@synthesize isNewCard;

- (void)dealloc 
{
	[self setBackSideTextField:nil];
	[self setCard:nil];
	[self setCardInDecksList:nil];
	[self setDecksCardsJoinData:nil];
	[self setDeckData:nil];
	[self setFrontSideTextField:nil];
	[categoryData release];
    [super dealloc];
}

- (void)viewDidUnload 
{
	self.backSideTextField = nil;
	self.card = nil;
	self.cardInDecksList = nil;
	self.decksCardsJoinData = nil;
	self.deckData = nil;
	self.frontSideTextField = nil;
	categoryData = nil;
	[super viewDidUnload];
}

- (void)viewDidLoad 
{
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated
{
	self.frontSideTextField.text = self.card.frontSide;
	self.backSideTextField.text = self.card.backSide;
}

- (void)viewWillDisappear:(BOOL)animated
{
	self.didComeFromDeckSelection = NO;
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark -
#pragma mark Custom Methods

- (IBAction)remove:(id)sender
{
	UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Delete Card" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"OK" otherButtonTitles:nil];
	[actionSheet showInView:self.view];
	[actionSheet release];
}

- (IBAction)save:(id)sender
{
	if (!self.isNewCard)
	{
		self.card.frontSide = self.frontSideTextField.text;
		self.card.backSide = self.backSideTextField.text;
		[self.card save];
	}
	else
	{
		[self.card release];
		self.card = [[Card alloc] init];
		self.card.frontSide = self.frontSideTextField.text;
		self.card.backSide = self.backSideTextField.text;
		self.card.savedInDatabase = NO;
		[self.card save];
		
		if (self.didComeFromDeckSelection)
		{
			// Use the foreign key deckId. This will be used to add this card to the current deck in the DecksCardsJoin table
			id<SaveDeleteDeckSelection> addingToDeck = [[[SaveDeckSelection alloc] initWithDeckId:self.foreignKeyDeckId cardId:self.card.cardId] autorelease];
			[addingToDeck performDeckSelectionTask];
		}
		
		self.isNewCard = NO;
		self.title = @"Edit Card";
	}
	
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Save" message:@"Your card has been saved" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
	[alert show];
	[alert release];
}

- (IBAction)addToDecks:(id)sender
{
	self.deckData = [self loadDecksData];
	
	self.decksCardsJoinData = [self loadDecksCardsJoinData];
	
	AlertTableView *tableAlert = [[AlertTableView alloc] initWithTitle:@"Add Card to Decks" tableViewDelegate:self tableViewDatasource:self tableViewTagNumber:0];
	
	[tableAlert show];
	[tableAlert release];
}

- (IBAction)selectCategory:(id)sender
{
	categoryData = [[self loadCategoryData] retain];
	
	AlertTableView *tableAlert = [[AlertTableView alloc] initWithTitle:@"Category for Card" tableViewDelegate:self tableViewDatasource:self tableViewTagNumber:1];
	
	[tableAlert show];
	[tableAlert release];
}

- (IBAction)backgroundTap:(id)sender
{
	[self.frontSideTextField resignFirstResponder];
	[self.backSideTextField resignFirstResponder];
}

- (IBAction)textFieldDoneEditing:(id)sender
{
	[sender resignFirstResponder];
}

#pragma mark -
#pragma mark Action Sheet Delegate

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
	if ([[actionSheet title] isEqual:@"Delete Card"])
	{
		if (buttonIndex != [actionSheet cancelButtonIndex])
		{
			NSArray *joins = [NSArray arrayWithObjects:[DecksCardsJoin tableIdentifier], [DecksCardsJoin foreignKeyCardIdColumnIdentifier],
							  [Card tableIdentifier], [Card primaryKeyIdentifier], nil];
			
			NSArray *arrayOfDecksCardsJoin = [[Card findWithArrayOfJoins:joins withWhere:[NSString stringWithFormat:@"WHERE %@.%@ = %d", [Card tableIdentifier],
																						 [Card primaryKeyIdentifier], self.card.cardId]] retain];
			
			if ([arrayOfDecksCardsJoin count] > 0)
			{
				for (int i = 0; i < [arrayOfDecksCardsJoin count]; i++)
				{
					NSDictionary *dict = [arrayOfDecksCardsJoin objectAtIndex:i];
					NSNumber *primaryKeyForRow = (NSNumber *)[dict valueForKey:[DecksCardsJoin primaryKeyIdentifier]];
					NSNumber *deckIdForeignKey = (NSNumber *)[dict valueForKey:[DecksCardsJoin foreignKeyDeckIdColumnIdentifier]];
					NSNumber *cardIdForeignKey = (NSNumber *)[dict valueForKey:[DecksCardsJoin foreignKeyCardIdColumnIdentifier]];
					
					DecksCardsJoin *decksCardsJoinToBeDeleted = [[DecksCardsJoin alloc] init];
					decksCardsJoinToBeDeleted.decksCardsJoinId = [primaryKeyForRow unsignedIntegerValue];
					decksCardsJoinToBeDeleted.foreignKeyDeckId = deckIdForeignKey;
					decksCardsJoinToBeDeleted.foreignKeyCardId = cardIdForeignKey;
					decksCardsJoinToBeDeleted.savedInDatabase = YES;
					[decksCardsJoinToBeDeleted remove];
					[decksCardsJoinToBeDeleted release];
				}
			}
			
			[self.card remove];
			
			[arrayOfDecksCardsJoin release];
			
			[self.navigationController popViewControllerAnimated:YES];
		}
	}
}

#pragma mark Table View Methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	if ([tableView tag] == 0)
	{
		return [self.deckData count];
	}
	
	if ([tableView tag] == 1)
	{
		return [categoryData count];
	}
	
	return 0;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	if ([tableView tag] == 0)
	{
		return 1;
	}
	
	if ([tableView tag] == 1)
	{
		return 1;
	}
	
	return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	if ([tableView tag] == 0)
	{
		Deck *deck = [self.deckData objectAtIndex:indexPath.row];
		static NSString *cellIdentifier = @"AddCardToSelectedDecks";
	
		UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
		if (cell == nil)
		{
#if __IPHONE_OS_VERSION_MIN_REQUIRED >= 30000
			cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault 
									   reuseIdentifier:cellIdentifier] autorelease];
#else
			cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero
									   reuseIdentifier:cellIdentifier] autorelease];
#endif
		
		}
	
#if __IPHONE_OS_VERSION_MIN_REQUIRED >= 30000
		cell.textLabel.text = [NSString stringWithFormat:@"%@", deck.title];
#else
		cell.text = [NSString stringWithFormat:@"%@", deck.title];
#endif
	
		cell.accessoryType = UITableViewCellAccessoryNone;
		for (int i = 0; i < [self.decksCardsJoinData count]; i++)
		{
			NSDictionary *dict = [self.decksCardsJoinData objectAtIndex:i];
		
			NSNumber *foreignKeyDeckIdNumber = (NSNumber *)[dict valueForKey:[DecksCardsJoin foreignKeyDeckIdColumnIdentifier]];
			NSUInteger foreignKey = [foreignKeyDeckIdNumber unsignedIntegerValue];
		
			if (deck.deckId == foreignKey)
				cell.accessoryType = UITableViewCellAccessoryCheckmark;
		
		}
	
		return cell;
	}
	
	if ([tableView tag] == 1)
	{
		Category *category = [categoryData objectAtIndex:indexPath.row];
		static NSString *cellIdentifier = @"SelectCategoryForCard";
		
		UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
		if (cell == nil)
		{
#if __IPHONE_OS_VERSION_MIN_REQUIRED >= 30000
			cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier] autorelease];
#else
			cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:cellIdentifier] autorelease];
#endif
		}
		
#if __IPHONE_OS_VERSION_MIN_REQUIRED >= 30000
		cell.textLabel.text = [NSString stringWithFormat:@"%@", category.categoryName];
#else
		cell.text = [NSString stringWithFormat:@"%@", category.categoryName];
#endif
		
		if (card.foreignKeyCategoryId == category.categoryId)
		{
			cell.accessoryType = UITableViewCellAccessoryCheckmark;
		}
		else 
		{
			cell.accessoryType = UITableViewCellAccessoryNone;
		}
		
		return cell;
	}
	
	return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
	if ([tableView tag] == 0)
	{
		Deck *deck = [self.deckData objectAtIndex:indexPath.row];
	
		NSArray *results = [self findBySpecificDeckId:deck.deckId bySepcificCardId:self.card.cardId];
		id<SaveDeleteDeckSelection> selection;
	
		UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
	
		if (cell.accessoryType != UITableViewCellAccessoryCheckmark)
		{
			cell.accessoryType = UITableViewCellAccessoryCheckmark;
		
			if ([results count] != 1)
			{
				selection = [self createSaveDeleteDeckSelectionWithDeckId:deck.deckId withCardId:self.card.cardId filter:kSaveDeckSelection];
				[selection performDeckSelectionTask];
			}
		}
		else
		{
			if ([results count] == 1)
			{
				if (self.didComeFromDeckSelection && (deck.deckId != self.foreignKeyDeckId))
				{
					selection = [self createSaveDeleteDeckSelectionWithDeckId:deck.deckId withCardId:self.card.cardId filter:kDeleteDeckSelection];
					[selection performDeckSelectionTask];
				}
			
				if (self.didComeFromDeckSelection && deck.deckId == self.foreignKeyDeckId)
				{
					selection = [self createSaveDeleteDeckSelectionWithDeckId:0 withCardId:0 filter:kDeleteCanNotDeckSelection];
					[selection performDeckSelectionTask];
					return;
				}
			
				if (!self.didComeFromDeckSelection)
				{
					selection = [self createSaveDeleteDeckSelectionWithDeckId:deck.deckId withCardId:self.card.cardId filter:kDeleteDeckSelection];
					[selection performDeckSelectionTask];
				}
			}
		
			cell.accessoryType = UITableViewCellAccessoryNone;
		}
	
		[tableView deselectRowAtIndexPath:indexPath animated:YES];
	}
	
	if ([tableView tag] == 1)
	{
		Category *category = [categoryData objectAtIndex:indexPath.row];
		
		id<ChangeCategorySelection> selection = [[ChangeCategorySelectionForCard alloc] initWithCard:self.card category:category.categoryId];
		
		[selection performCategorySelection];
		free(selection);
		
		[tableView reloadData];
	}
}


- (NSArray *)loadDecksData
{
	return [Deck findAll];
}

- (NSArray *)loadCategoryData
{
	return [Category findAll];
}

- (NSArray *)loadDecksCardsJoinData
{
	NSArray *array = [[NSArray alloc] init];
	if (self.card != nil)
	{
		
		
		NSArray *joinsArray = [NSArray arrayWithObjects:
							   [Card tableIdentifier], 
							   [Card primaryKeyIdentifier], 
							   [DecksCardsJoin tableIdentifier], 
							   [DecksCardsJoin foreignKeyCardIdColumnIdentifier], nil];
		
		
		
		NSString *whereClause = [NSString stringWithFormat:@"WHERE %@.%@ = %d", [Card tableIdentifier], [Card primaryKeyIdentifier], self.card.cardId];
		
		
		array = [DecksCardsJoin findWithArrayOfJoins:joinsArray withWhere:whereClause];
	}
	return array;
}

- (NSArray *)loadJoinsArray
{
	return [NSArray arrayWithObjects:
						   [Card tableIdentifier],
						   [Card primaryKeyIdentifier],
						   [DecksCardsJoin tableIdentifier],
						   [DecksCardsJoin foreignKeyCardIdColumnIdentifier], nil];
}

- (NSArray *)findBySpecificDeckId:(int)deckId bySepcificCardId:(int)cardId
{
	NSArray *joinsArray = [self loadJoinsArray];
	
	NSString *whereClause = [NSString stringWithFormat:@"WHERE %@.%@ = %d AND %@.%@ = %d", [Card tableIdentifier],
							 [Card primaryKeyIdentifier], cardId, [DecksCardsJoin tableIdentifier], 
							 [DecksCardsJoin foreignKeyDeckIdColumnIdentifier], deckId];
	
	return [DecksCardsJoin findWithArrayOfJoins:joinsArray withWhere:whereClause];
}

- (id<SaveDeleteDeckSelection>)createSaveDeleteDeckSelectionWithDeckId:(int)dId withCardId:(int)cId filter:(SaveDeleteDeckSelectionEnum)filter
{
	switch (filter)
	{
		case kSaveDeckSelection:
			return [[[SaveDeckSelection alloc] initWithDeckId:dId cardId:cId] autorelease];
		case kDeleteDeckSelection:
			return [[[DeleteDeckSelection alloc] initWithDeckId:dId cardId:cId] autorelease];
		case kDeleteCanNotDeckSelection:
			return [[[DeleteCanNotDeckSelection alloc] init] autorelease];
		default:
			return nil;
	}
}

@end
