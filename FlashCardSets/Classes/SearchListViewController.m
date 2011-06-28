//
//  SearchTabViewController.m
//  FlashNotes
//

#import "SearchListViewController.h"
#import "DeckSelectionScreenViewController.h"
#import "CardEditViewController.h"
#import "SearchCellForDecks.h"
#import "SearchCellForCards.h"
#import "ApplicationSetting.h"
#import "Deck.h"
#import "Card.h"

@interface SearchListViewController(PrivateMethods)
- (void)loadSelectSearchTypePickerData;
- (int) getBannerHeight:(UIDeviceOrientation)orientation;
- (int) getBannerHeight;
- (void) createAdBannerView;
- (void) fixupAdView:(UIInterfaceOrientation)toInterfaceOrientation;
@end

@implementation SearchListViewController

@synthesize searchTableView, searchData, allSearchData, searchBar;
@synthesize contentView = m_contentView;
@synthesize adBannerView = m_adBannerView;
@synthesize adBannerViewIsVisible = m_adBannerViewIsVisible;

- (void)dealloc {
	
	[self setAllSearchData:nil];
	[self setSearchData:nil];
	[self setSearchTableView:nil];
	[self setSearchBar:nil];
	[childController release];
	
	self.contentView = nil;
	self.adBannerView = nil;
    [super dealloc];
}

- (void)viewDidUnload {
	self.allSearchData = nil;
	self.searchData = nil;
	self.searchTableView = nil;
	self.searchBar = nil;
	childController = nil;
	[super viewDidUnload];
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

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad 
{
	[self createAdBannerView];
	self.title = @"Search";
    [searchTableView setContentOffset:CGPointMake(0.0, 44.0) animated:NO];
//	UIBarButtonItem *rightBarButton = [[UIBarButtonItem alloc] initWithTitle:@"Search By" 
//																	   style:UIBarButtonItemStylePlain 
//																	  target:self 
//																	  action:@selector(searchByButtonClick:)];
//	self.navigationItem.rightBarButtonItem = rightBarButton;
//	[rightBarButton release];
	[super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated
{
	[self fixupAdView:[UIDevice currentDevice].orientation];
	[self determineTypeOfSearch];
	[searchDelegate resetSearch];
	[self loadSelectSearchTypePickerData];
}

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
}

- (void) willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
	[self fixupAdView:toInterfaceOrientation];
}

#pragma mark -
#pragma mark Custom Methods

- (void)determineTypeOfSearch
{
	NSArray *searchCardsOrDeckArray = [ApplicationSetting findAllReturnNSArrayOfNSDictionariesWithWhereClause:[NSString stringWithFormat:@"WHERE %@ = %@",
																											   [ApplicationSetting applicationSettingTagIdentifierColumnIdentifier],
																											   @"'SearchForCardsOrDecks'"]];
	NSDictionary *searchCardsOrDeckDictionary = [searchCardsOrDeckArray objectAtIndex:0];
	searchByDeck = [(NSNumber *)[searchCardsOrDeckDictionary valueForKey:[ApplicationSetting applicationSettingValueColumnIdentifier]] unsignedIntegerValue];
	if (searchByDeck == 1)
	{
		self.allSearchData = [Deck findAll];
		searchDelegate = [[SearchCellForDecks alloc] initWithSearchData:self.searchData allSearchData:self.allSearchData searchTable:self.searchTableView];
	}
	else
	{
		self.allSearchData = [Card findAllReturnNSArrayOfNSDictionariesWithWhereClause:[NSString stringWithFormat:@"ORDER BY %@.%@ DESC", [Card tableIdentifier], [Card frontSideColumnIdentifier]]];
		searchDelegate = [[SearchCellForCards alloc] initWithSearchData:self.searchData allSearchData:self.allSearchData searchTable:self.searchTableView];
	}
	[searchTableView reloadData];
}

- (void)loadSelectSearchTypePickerData
{
	NSArray *array = [[NSArray alloc] initWithObjects:@"Decks", @"Cards", nil];
	[selectSearchTypePickerData release];
	selectSearchTypePickerData = [array retain];
	[array release];
}

#pragma mark -
#pragma mark TableView Methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
	return [searchDelegate countForTableViewNumberOfRowsInSection:section];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return [searchDelegate numberOfSectionsInTableView];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
	return [searchDelegate tableViewHeightForHeaderInSection:section];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return [searchDelegate tableViewForHeightForRowAtIndexPath:indexPath];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return [searchDelegate tableViewCellForRowAtIndexPath:indexPath];
}

- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	childController = [searchDelegate tableViewDidSelectRowAtIndexPath:indexPath];
	[self.navigationController pushViewController:childController animated:YES];
}

#pragma mark -
#pragma mark Search Bar Delegate Methods

- (void)searchBarSearchButtonClicked:(UISearchBar *)search
{
	[search resignFirstResponder];
	[searchDelegate handleSearchForTerm:[search text]];
	[search setText:@""];
}

 // Implement this method if one wishes to do a live search.
 - (void)searchBar:(UISearchBar *)search textDidChange:(NSString *)searchTerm
 {
	if ([searchTerm length] == 0)
	{
		[searchDelegate resetSearch];
		[searchTableView reloadData];
		return;
	}
	[searchDelegate handleSearchForTerm:searchTerm];
 }
 

- (void)searchBarCancelButtonClicked:(UISearchBar *)search
{
	[search setText:@""];
	[search resignFirstResponder];
	[searchDelegate resetSearch];
	[searchTableView reloadData];
}

#pragma mark -
#pragma mark - Button Clicks

- (void)searchByButtonClick:(id)sender
{
	selectSearchTypeActionSheet = [[UIActionSheet alloc] initWithTitle:@"Search By" 
															  delegate:self 
													 cancelButtonTitle:nil 
												destructiveButtonTitle:nil 
													 otherButtonTitles:nil];
	
	selectSearchTypePicker = [[UIPickerView alloc] initWithFrame:CGRectMake(0.0, 44.0, 0.0, 0.0)];
	selectSearchTypePicker.delegate = self;
	selectSearchTypePicker.dataSource = self;
	[selectSearchTypePicker setShowsSelectionIndicator:YES];
	
	UIToolbar *pickerToolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
	pickerToolBar.barStyle = UIBarStyleBlackOpaque;
	[pickerToolBar sizeToFit];
	
	NSMutableArray *barItems = [[NSMutableArray alloc] init];
	
	UIBarButtonItem *flexSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace 
																			   target:self 
																			   action:nil];
	[barItems addObject:flexSpace];
	
	UIBarButtonItem *doneBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone 
																			 target:self 
																			 action:@selector(searchByDoneButtonClick:)];
	[barItems addObject:doneBtn];
	[pickerToolBar setItems:barItems animated:YES];
	
	[selectSearchTypeActionSheet addSubview:pickerToolBar];
	[selectSearchTypeActionSheet addSubview:selectSearchTypePicker];
	[selectSearchTypeActionSheet showInView:[self view]];
	[selectSearchTypeActionSheet setBounds:CGRectMake(0, 0, 320, 464)];
	
	[doneBtn release];
	[flexSpace release];
	[barItems release];
	[pickerToolBar release];
}

- (void)searchByDoneButtonClick:(id)sender
{
	[selectSearchTypeActionSheet dismissWithClickedButtonIndex:0 animated:YES];
	[self determineTypeOfSearch];
	[selectSearchTypePicker release];
	[selectSearchTypeActionSheet release];
}

#pragma mark -
#pragma mark Picker Data Source Methods

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
	return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
	return [selectSearchTypePickerData count];
}

#pragma mark -
#pragma mark Picker Delegate Methods

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
	NSArray *searchCardsOrDecksArray = [ApplicationSetting findAllReturnNSArrayOfNSDictionariesWithWhereClause:[NSString stringWithFormat:@"WHERE %@ = %@",
																												[ApplicationSetting applicationSettingTagIdentifierColumnIdentifier],
																												@"'SearchForCardsOrDecks'"]];
	NSString *pickerString = [selectSearchTypePickerData objectAtIndex:row];
	NSUInteger selectCardsOrDecks = [[[searchCardsOrDecksArray objectAtIndex:0] valueForKey:[ApplicationSetting applicationSettingValueColumnIdentifier]] unsignedIntegerValue];
	
	if (selectCardsOrDecks == 1 && [pickerString isEqualToString:@"Decks"])
	{
		[pickerView selectRow:row inComponent:component animated:YES];
	}
	else if (selectCardsOrDecks == 0 && [pickerString isEqualToString:@"Cards"])
	{
		[pickerView selectRow:row inComponent:component animated:YES];
	}
	
	return pickerString;
}


- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
	NSString *pickerString = [selectSearchTypePickerData objectAtIndex:row];
	NSArray *searchCardsOrDecksArray = [ApplicationSetting findAllReturnNSArrayOfNSDictionariesWithWhereClause:[NSString stringWithFormat:@"WHERE %@ = %@",
																												[ApplicationSetting applicationSettingTagIdentifierColumnIdentifier],
																												@"'SearchForCardsOrDecks'"]];
	
	if ([pickerString isEqualToString:@"Decks"])
	{
		if ([[[searchCardsOrDecksArray objectAtIndex:0] valueForKey:[ApplicationSetting applicationSettingValueColumnIdentifier]] unsignedIntegerValue] != 1)
		{
			NSDictionary *dict = [searchCardsOrDecksArray objectAtIndex:0];
			ApplicationSetting *settingToSave = [[ApplicationSetting alloc] init];
			settingToSave.applicationSettingId = [(NSNumber *)[dict valueForKey:[ApplicationSetting primaryKeyColumnIdentifier]] unsignedIntegerValue];
			settingToSave.applicationSettingDisplayName = [dict valueForKey:[ApplicationSetting applicationSettingDisplayNameColumnIdentifier]];
			settingToSave.applicationSettingTagIdentifier = [dict valueForKey:[ApplicationSetting applicationSettingTagIdentifierColumnIdentifier]];
			settingToSave.applicationSettingValue = 1;
			settingToSave.savedInDatabase = YES;
			[settingToSave save];
			[settingToSave release];
		}
	}
	
	if ([pickerString isEqualToString:@"Cards"])
	{
		if ([[[searchCardsOrDecksArray objectAtIndex:0] valueForKey:[ApplicationSetting applicationSettingValueColumnIdentifier]] unsignedIntegerValue] != 0)
		{
			NSDictionary *dict = [searchCardsOrDecksArray objectAtIndex:0];
			ApplicationSetting *settingToSave = [[ApplicationSetting alloc] init];
			settingToSave.applicationSettingId = [(NSNumber *)[dict valueForKey:[ApplicationSetting primaryKeyColumnIdentifier]] unsignedIntegerValue];
			settingToSave.applicationSettingDisplayName = [dict valueForKey:[ApplicationSetting applicationSettingDisplayNameColumnIdentifier]];
			settingToSave.applicationSettingTagIdentifier = [dict valueForKey:[ApplicationSetting applicationSettingTagIdentifierColumnIdentifier]];
			settingToSave.applicationSettingValue = 0;
			settingToSave.savedInDatabase = YES;
			[settingToSave save];
			[settingToSave release];
		}
	}
	
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
			searchTableView.contentInset = UIEdgeInsetsMake(0.0, 0.0, 40.0, 0.0);
			searchTableView.scrollIndicatorInsets = searchTableView.contentInset;
		} else {
			CGRect adBannerViewFrame = [m_adBannerView frame];
			adBannerViewFrame.origin.x = 0;
			adBannerViewFrame.origin.y = -[self getBannerHeight:toInterfaceOrientation];
			[m_adBannerView setFrame:adBannerViewFrame];
			CGRect contentViewFrame = m_contentView.frame;
			contentViewFrame.origin.y = 0;
			contentViewFrame.size.height = self.view.frame.size.height;
			m_contentView.frame = contentViewFrame;
			searchTableView.contentInset = UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0);
			searchTableView.scrollIndicatorInsets = searchTableView.contentInset;
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


















































