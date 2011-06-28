//
//  SearchCellForFavoriteDecks.m
//  FlashNotes
//
//  Created by Douglas Mason on 12/23/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "SearchCellForDecks.h"
#import "DeckSelectionScreenViewController.h"
#import "Deck.h"

@implementation SearchCellForDecks

@synthesize searchTableView;
@synthesize searchData;
@synthesize allSearchData;

- (void)dealloc
{
	[self.allSearchData release];
	[self.searchData release];
	[self.searchTableView release];
	[super dealloc];
}

- (id)initWithSearchData:(NSMutableArray *)_searchData 
				 allSearchData:(NSArray *)_allSearchData 
				  searchTable:(UITableView *)_searchTableView
{
	self = [super init];
	if (self != nil)
	{
		self.allSearchData = _allSearchData;
		self.searchData = _searchData;
		self.searchTableView = _searchTableView;
		[self resetSearch];
	}
	return self;
}

- (void)resetSearch
{
	NSMutableArray *allDeckInfo = [self.allSearchData mutableCopy];
	self.searchData = allDeckInfo;
	[allDeckInfo release];
}

- (void)handleSearchForTerm:(NSString *)searchTerm
{
	if ([searchTerm isEqualToString:@""])
	{
		[self resetSearch];
		[searchTableView reloadData];
		return;
	}
	
	NSMutableArray *toRemove = [[NSMutableArray alloc] init];
	[self resetSearch];
	
	for (Deck *deck in self.searchData)
	{
		if ([deck.title rangeOfString:searchTerm options:NSCaseInsensitiveSearch].location == NSNotFound)
			[toRemove addObject:deck];
	}
	
	[self.searchData removeObjectsInArray:toRemove];
	[toRemove release];
	
	// tell the table to reload it self
	[searchTableView reloadData];
}

- (NSInteger)countForTableViewNumberOfRowsInSection:(NSInteger)section 
{
	return [self.searchData count];
}

- (NSInteger)numberOfSectionsInTableView
{
	return 1;
}

- (CGFloat)tableViewHeightForHeaderInSection:(NSInteger)section
{		
	return 0.0f;
}

- (CGFloat)tableViewForHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return 40.0f;
}

- (UITableViewCell *)tableViewCellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	Deck *deck = [searchData objectAtIndex:indexPath.row];
	static NSString *cellIdentifier = @"FavoriteCell";
	
	UITableViewCell *cell = [searchTableView dequeueReusableCellWithIdentifier:cellIdentifier];
	if (cell == nil)
	{
#if __IPHONE_OS_VERSION_MIN_REQUIRED >= 30000
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier] autorelease];
#else
		cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:cellIdentifier] autorelease];
#endif
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	}
	
#if __IPHONE_OS_VERSION_MIN_REQUIRED >= 30000
	cell.textLabel.text = [NSString stringWithFormat:@"%@", deck.title];
#else
	cell.text = [NSString stringWithFormat:@"%@", deck.title];
#endif
	
	return cell;
}

- (UIViewController *)tableViewDidSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	// Get the appropriate deck record
	Deck *selectedDeck = [self.searchData objectAtIndex:indexPath.row];
	
	DeckSelectionScreenViewController *deckSelectionScreenViewController = [[DeckSelectionScreenViewController alloc] initWithNibName:@"DeckSelectionScreenViewController" bundle:nil];
	
	deckSelectionScreenViewController.title = @"Deck Selection";
	deckSelectionScreenViewController.selectedDeck = selectedDeck;
	
	return [deckSelectionScreenViewController autorelease];
}

@end
