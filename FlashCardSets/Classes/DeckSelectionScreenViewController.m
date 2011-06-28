//
//  DeckPlayScreenViewController.m
//  FlashNotes
//

#import "DeckSelectionScreenViewController.h"
#import "DeckPlayScreenViewController.h"
#import "CardListViewController.h"
#import "Favorite.h"
#import "Deck.h"
#import "Card.h"
#import "DecksCardsJoin.h"
#import "DecksCategoryFilterJoin.h"
#import "FlashCardSetsAppDelegate.h"
#import "Category.h"
#import "AlertTableView.h"
#import "DebugOutput.h"
#import "Common.h"

@interface DeckSelectionScreenViewController()

- (NSArray*)getJoinArrayForDecksCardsJoin;
- (NSString*)getWhereClauseForDecksCardsJoin;
- (NSArray*)getArrayOfDecksCardsJoinData;

- (NSArray*)getJoinArrayForDecksCardsCategoryFilterJoin;
- (NSString*)getWhereClauseForDecksCardsCategoryFilterJoin;
- (NSArray*)getArrayOfDecksCardsCategoryFilterJoinData;

- (void)loadCategoryData;
- (void)loadFilterCategoryData;

- (int) getBannerHeight:(UIDeviceOrientation)orientation;
- (int) getBannerHeight;
- (void) createAdBannerView;
- (void) fixupAdView:(UIInterfaceOrientation)toInterfaceOrientation;

@end

@implementation DeckSelectionScreenViewController
@synthesize deckSelectionList;
@synthesize selectedDeck;
@synthesize deckPlayScreenViewController;
@synthesize contentView = m_contentView;
@synthesize adBannerView = m_adBannerView;
@synthesize adBannerViewIsVisible = m_adBannerViewIsVisible;

- (void)dealloc {
	
	[self setDeckSelectionList:nil];
	[self setSelectedDeck:nil];
	cardListViewController = nil;
	self.contentView = nil;
	self.adBannerView = nil;
    [super dealloc];
}

- (void)viewDidUnload {
	self.deckSelectionList = nil;
	self.selectedDeck = nil;
	[super viewDidUnload];
}

- (void) viewDidLoad
{
	[self createAdBannerView];
	[super viewDidLoad];
}

- (void) viewWillAppear:(BOOL)animated
{
	[self fixupAdView:[UIDevice currentDevice].orientation];
	[super viewWillAppear:animated];
}

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
    }
    return self;
}
*/

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation 
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
	[[CCTextureCache sharedTextureCache] removeAllTextures];
}

- (void) willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
	[self fixupAdView:toInterfaceOrientation];
}

#pragma mark -
#pragma mark Custom Methods

- (void)addToFavorites
{
	NSArray *favoriteAlreadyInArray = [Favorite findByColumn:[Favorite foreignKeyDeckIdColumnIdentifier] integerValue:self.selectedDeck.deckId];
	if ([favoriteAlreadyInArray count] != 1 && [favoriteAlreadyInArray count] == 0)
	{
		Favorite *newFavorite = [[[Favorite alloc] init] retain];
		NSNumber *key = [NSNumber numberWithUnsignedInteger:self.selectedDeck.deckId];
		newFavorite.foreignKeyDeckId = key;
		[newFavorite save];
		[newFavorite release];
		
		[[NSNotificationCenter defaultCenter] postNotificationName:kUpdateTableViewsUsingFavoriteData object:nil];
	}
	else 
	{
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"In Favorites" message:@"This deck is already in favorites." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[alert show];
		[alert release];
	}
	
}

- (void)deleteDeck
{
	UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Delete Deck" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"OK" otherButtonTitles:nil];
	[actionSheet showInView:self.view];
	[actionSheet release];
}

- (void)filterByCategory
{
	[self loadCategoryData];
	[self loadFilterCategoryData];
	
	AlertTableView *tableAlert = [[AlertTableView alloc] initWithTitle:@"Filter by Category" tableViewDelegate:self tableViewDatasource:self tableViewTagNumber:1];
	
	[tableAlert show];
	[tableAlert release];
}

- (void)playDeck
{	
	deckPlayScreenViewController.title = @"Play";
	
	deckPlayScreenViewController.cardList = [self getArrayOfDecksCardsJoinData];
	[deckPlayScreenViewController setDMControllerCleanupTarget:self];
	
	[self.navigationController presentModalViewController:deckPlayScreenViewController animated:YES];
}

#pragma mark - 
#pragma mark Action Sheet Delegate

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
	if (buttonIndex != [actionSheet cancelButtonIndex])
	{
		NSArray *deckFavoriteToBeDeletedArray = [Favorite findByColumn:[Favorite foreignKeyDeckIdColumnIdentifier] integerValue:selectedDeck.deckId];
		if ([deckFavoriteToBeDeletedArray count] != 0 && [deckFavoriteToBeDeletedArray count] == 1)
		{
			Favorite *favoriteToBeDeleted = [deckFavoriteToBeDeletedArray objectAtIndex:0];
			[favoriteToBeDeleted remove];
		}
		
		[selectedDeck remove];
		
		[self.navigationController popViewControllerAnimated:YES];
	}
}

#pragma mark -
#pragma mark TableView Methods

- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)aSection
{
	if ([aTableView tag] == 0)
	{
		return 4;
	}
	
	if ([aTableView tag] == 1)
	{
		return [categoryData count];
	}
	
	return 0;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)aTableView 
{
	return 1;
}

- (CGFloat)tableView:(UITableView *)aTableView heightForHeaderInSection:(NSInteger)aSection
{
	return 35.0;
}

- (NSString *)tableView:(UITableView *)aTableView titleForHeaderInSection:(NSInteger)aSection
{
	if ([aTableView tag] == 0)
	{
		return @"Deck Selection";
	}
	
	return @"";
}

- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)aIndexPath
{
	if ([aTableView tag] == 0)
	{
		NSUInteger aRow = aIndexPath.row;
	
		static NSString *cellIdentifier = @"DeckSelectionCell";
	
		UITableViewCell *aCell = [aTableView dequeueReusableCellWithIdentifier:cellIdentifier];
		if (aCell == nil)
		{
#if __IPHONE_OS_VERSION_MIN_REQUIRED >= 30000
			aCell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault 
										reuseIdentifier:cellIdentifier] autorelease];
#else
			aCell = [[[UITableViewCell alloc] initWithFrame:CGRectZero 
										reuseIdentifier:cellIdentifier] autorelease];
#endif
		
			if (aIndexPath.row != 2 && aIndexPath.row != 3 &&  aIndexPath.row != 4)
				aCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		}
	
		NSString *aCellTitle = @"";
		if (aRow == 0)
			aCellTitle = @"Play";
		//else if (aRow == 1)
		//	aCellTitle = @"Play Word Puzzle";
		else if (aRow == 1)
			aCellTitle = @"List";
		else if (aRow == 2)
			aCellTitle = @"Add to Favorites";
		else if (aRow == 3)
			aCellTitle = @"Delete";
	
#if __IPHONE_OS_VERSION_MIN_REQUIRED >= 30000
		aCell.textLabel.text = aCellTitle;
#else
		aCell.text = aCellTitle;
#endif
	
		return aCell;
	}
	
	if ([aTableView tag] == 1)
	{
		Category *category = [categoryData objectAtIndex:aIndexPath.row];
		static NSString *cellIdentifier = @"FilterByCategory";
		
		UITableViewCell *cell = [aTableView dequeueReusableCellWithIdentifier:cellIdentifier];
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
		
		cell.accessoryType = UITableViewCellAccessoryNone;
		for (NSDictionary *dict in filterCategoryData)
		{
			NSUInteger foreignKeyCategoryId = [[dict valueForKey:[DecksCategoryFilterJoin foreignKeyCategoryIdColumnIdentifier]] unsignedIntegerValue];
			if (category.categoryId == foreignKeyCategoryId)
			{
				cell.accessoryType = UITableViewCellAccessoryCheckmark;
			}
		}
		
		return cell;
	}
	
	return nil;
}

- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)aIndexPath
{
	if ([aTableView tag] == 0)
	{
		NSUInteger aRow = aIndexPath.row;
	
		if (aRow == 0)
		{
			[self playDeck];
		}
		else if (aRow == 1)
		{
			cardListViewController = [[CardListViewController alloc] initWithNibName:@"CardListViewController" bundle:nil];		
			cardListViewController.title = @"Card List";
			cardListViewController.foreignKeyDeckId = selectedDeck.deckId;
			cardListViewController.didComeFromDeckSelection = YES;
		
			[self.navigationController pushViewController:cardListViewController animated:YES];
		}
		else if (aRow == 2)
		{
			[self addToFavorites];
		}
		else if (aRow == 3)
		{
			[self deleteDeck];
		}
	
		[aTableView deselectRowAtIndexPath:aIndexPath animated:YES];
	}
	
	if ([aTableView tag] == 1)
	{
		Category *category = [categoryData objectAtIndex:aIndexPath.row];
		
		if (category.categoryId != 1)
		{
			NSArray *arrayOfDecksCategories = [DecksCategoryFilterJoin findByColumn:[DecksCategoryFilterJoin foreignKeyDeckIdColumnIdentifier] unsignedIntegerValue:self.selectedDeck.deckId];
			for (DecksCategoryFilterJoin *decksCategory in arrayOfDecksCategories)
			{
				if (decksCategory.foreignKeyCategoryId == 1)
				{
					[decksCategory remove];
				}
			}
			
			arrayOfDecksCategories = [DecksCategoryFilterJoin findByColumn:[DecksCategoryFilterJoin foreignKeyCategoryIdColumnIdentifier] unsignedIntegerValue:category.categoryId];
			if ([arrayOfDecksCategories count] == 1)
			{
				DecksCategoryFilterJoin *filterToBeRemoved = [arrayOfDecksCategories objectAtIndex:0];
				[filterToBeRemoved remove];
				[self loadFilterCategoryData];
				[aTableView reloadData];
				return;
			}
			
			DecksCategoryFilterJoin *filter = [[DecksCategoryFilterJoin alloc] init];
			filter.savedInDatabase = NO;
			filter.foreignKeyDeckId = self.selectedDeck.deckId;
			filter.foreignKeyCategoryId = category.categoryId;
			[filter save];
			[filter release];
			
			[self loadFilterCategoryData];
			[aTableView reloadData];
			
			return;
		}
		else
		{
			NSArray *arrayOfDecksCategories = [DecksCategoryFilterJoin findByColumn:[DecksCategoryFilterJoin foreignKeyDeckIdColumnIdentifier] unsignedIntegerValue:self.selectedDeck.deckId];
			for (DecksCategoryFilterJoin *decksCategory in arrayOfDecksCategories)
			{
				if (decksCategory.foreignKeyCategoryId != 1)
				{
					[decksCategory remove];
				}
			}
			
			arrayOfDecksCategories = [DecksCategoryFilterJoin findByColumn:[DecksCategoryFilterJoin foreignKeyCategoryIdColumnIdentifier] unsignedIntegerValue:category.categoryId];
			if ([arrayOfDecksCategories count] == 1)
			{
				return;
			}
			
			DecksCategoryFilterJoin *filter = [[DecksCategoryFilterJoin alloc] init];
			filter.savedInDatabase = NO;
			filter.foreignKeyDeckId = self.selectedDeck.deckId;
			filter.foreignKeyCategoryId = category.categoryId;
			[filter save];
			[filter release];
			
			[self loadFilterCategoryData];
			[aTableView reloadData];
			return;
		}
		
		
	}
}

#pragma mark -
#pragma mark DMControllerCleanup Methods

- (void)cleanUpDeckPlayController:(DeckPlayScreenViewController *)controller;
{
}

#pragma mark -
#pragma mark Private Methods

- (NSArray*)getJoinArrayForDecksCardsJoin
{
	return [NSArray arrayWithObjects:[Card tableIdentifier], [Card primaryKeyIdentifier], 
					  [DecksCardsJoin tableIdentifier], [DecksCardsJoin foreignKeyCardIdColumnIdentifier], nil];
	
	
}

- (NSString*)getWhereClauseForDecksCardsJoin
{
	return [NSString stringWithFormat:@"WHERE %@.%@ = %d ORDER BY %@.%@ DESC", [DecksCardsJoin tableIdentifier],
							 [DecksCardsJoin foreignKeyDeckIdColumnIdentifier], self.selectedDeck.deckId,
							 [Card tableIdentifier], [Card frontSideColumnIdentifier]];
}

- (NSArray*)getArrayOfDecksCardsJoinData
{
	[self loadFilterCategoryData];
	NSArray *data =	[DecksCardsJoin findWithArrayOfJoins:[self getJoinArrayForDecksCardsJoin] withWhere:[self getWhereClauseForDecksCardsJoin]];
	
	if (filterCategoryData == nil)
		return data;
	
	debug(@"[filterCategoryData count] = %d", [filterCategoryData count]);
	debug(@"filterCategoryData = %@", filterCategoryData);
	if ([filterCategoryData count] == 1)
	{
		// check if that NSDictionary in filterCategoryData contains the foreignKeyCategoryId of 1
		if ([[[filterCategoryData objectAtIndex:0] valueForKey:[DecksCategoryFilterJoin foreignKeyCategoryIdColumnIdentifier]] unsignedIntegerValue] == kDB_Category_NONE)
		{
			return data;
		}
	}
	
	// if filter is not set to NONE, then only particular cards should be permitted to be added to the cardList NSArray in the DeckPlayScreenViewController variable.
	NSMutableArray *selectedCardData = [NSMutableArray array];
	for (NSDictionary *dictOfCategoriesToFilter in filterCategoryData)
	{
		debug(@"dictOfCategoriesToFilter = %@", dictOfCategoriesToFilter);
		for (NSDictionary *dictOfCards in data)
		{
			debug(@"dictOfCards = %@", dictOfCards);
			if ([[dictOfCards valueForKey:[Card foreignKeyCategoryIdColumnIdentifier]] unsignedIntegerValue] == 
				[[dictOfCategoriesToFilter valueForKey:[DecksCategoryFilterJoin foreignKeyCategoryIdColumnIdentifier]] unsignedIntegerValue])
			{
				[selectedCardData addObject:dictOfCards];
			}
		}
	}
		
	if ([selectedCardData count] == 0)
		return data;

	return selectedCardData;
}

- (NSArray*)getJoinArrayForDecksCardsCategoryFilterJoin
{
	return [NSArray arrayWithObjects:[Deck tableIdentifier], [Deck primaryKeyIdentifier],
			[DecksCategoryFilterJoin tableIdentifier], [DecksCategoryFilterJoin foreignKeyDeckIdColumnIdentifier], nil];
}

- (NSString*)getWhereClauseForDecksCardsCategoryFilterJoin
{
	return [NSString stringWithFormat:@"WHERE %@.%@ = %d", [DecksCategoryFilterJoin tableIdentifier],
			[DecksCategoryFilterJoin foreignKeyDeckIdColumnIdentifier], self.selectedDeck.deckId];
}

- (NSArray*)getArrayOfDecksCardsCategoryFilterJoinData
{
	return [DecksCategoryFilterJoin findWithArrayOfJoins:[self getJoinArrayForDecksCardsCategoryFilterJoin] withWhere:[self getWhereClauseForDecksCardsCategoryFilterJoin]];
}

- (void)loadCategoryData
{
	categoryData = [[Category findAll] retain];
}

- (void)loadFilterCategoryData
{
	[filterCategoryData release];
	filterCategoryData = [[self getArrayOfDecksCardsCategoryFilterJoinData] retain];
}

#pragma mark -
#pragma mark - iAd's Methods

- (int) getBannerHeight:(UIDeviceOrientation)orientation {
	if (UIInterfaceOrientationIsLandscape(orientation)) {
		return 32;
	} else {
		return 50;
	}
}

- (int) getBannerHeight {
	return [self getBannerHeight:[UIDevice currentDevice].orientation];
}

- (void) createAdBannerView {
	Class classAdBannerView = NSClassFromString(@"ADBannerView");
	if (classAdBannerView != nil) {
		self.adBannerView = [[[classAdBannerView alloc] initWithFrame:CGRectZero] autorelease];
		[m_adBannerView setRequiredContentSizeIdentifiers:[NSSet setWithObjects:ADBannerContentSizeIdentifier320x50,
														   ADBannerContentSizeIdentifier480x32, nil]];
		if (UIInterfaceOrientationIsLandscape([UIDevice currentDevice].orientation))
			[m_adBannerView setCurrentContentSizeIdentifier:ADBannerContentSizeIdentifier480x32];
		else
			[m_adBannerView setCurrentContentSizeIdentifier:ADBannerContentSizeIdentifier320x50];
		
		[m_adBannerView setFrame:CGRectOffset([m_adBannerView frame], 0, -[self getBannerHeight])];
		[m_adBannerView setDelegate:self];
		
		[self.view addSubview:m_adBannerView];
	}
}

- (void) fixupAdView:(UIInterfaceOrientation)toInterfaceOrientation {
	if (m_adBannerView != nil) {
		if (UIInterfaceOrientationIsLandscape(toInterfaceOrientation)) 
			[m_adBannerView setCurrentContentSizeIdentifier:ADBannerContentSizeIdentifier480x32];
		else
			[m_adBannerView setCurrentContentSizeIdentifier:ADBannerContentSizeIdentifier320x50];
		
		[UIView beginAnimations:@"fixupViews" context:nil];
		if (m_adBannerViewIsVisible) {
			CGRect adBannerViewFrame = [m_adBannerView frame];
			adBannerViewFrame.origin.x = 0;
			adBannerViewFrame.origin.y = 0;
			[m_adBannerView setFrame:adBannerViewFrame];
			CGRect contentViewFrame = m_contentView.frame;
			contentViewFrame.origin.y = [self getBannerHeight:toInterfaceOrientation];
			contentViewFrame.size.height = self.view.frame.size.height - [self getBannerHeight:toInterfaceOrientation];
			m_contentView.frame = contentViewFrame;
			deckSelectionList.contentInset = UIEdgeInsetsMake(0.0, 0.0, 75.0, 0.0);
			deckSelectionList.scrollIndicatorInsets = deckSelectionList.contentInset;
		} else {
			CGRect adBannerViewFrame = [m_adBannerView frame];
			adBannerViewFrame.origin.x = 0;
			adBannerViewFrame.origin.y = -[self getBannerHeight:toInterfaceOrientation];
			[m_adBannerView setFrame:adBannerViewFrame];
			CGRect contentViewFrame = m_contentView.frame;
			contentViewFrame.origin.y = 0;
			contentViewFrame.size.height = self.view.frame.size.height;
			m_contentView.frame = contentViewFrame;
			deckSelectionList.contentInset = UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0);
			deckSelectionList.scrollIndicatorInsets = deckSelectionList.contentInset;
		}
		[UIView commitAnimations];
	}
}

#pragma mark -
#pragma mark ADBannerViewDelegate Methods

- (void) bannerViewDidLoadAd:(ADBannerView *)banner {
	if (!m_adBannerViewIsVisible) {
		m_adBannerViewIsVisible = YES;
		[self fixupAdView:[UIDevice currentDevice].orientation];
	}
}

- (void) bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error
{
	if (m_adBannerViewIsVisible)
	{
		m_adBannerViewIsVisible = NO;
		[self fixupAdView:[UIDevice currentDevice].orientation];
	}
}

@end
