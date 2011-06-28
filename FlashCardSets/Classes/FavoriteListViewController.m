//
//  FavoriteListViewController.m
//  FlashNotes
//

#import "FavoriteListViewController.h"
#import "DeckSelectionScreenViewController.h"
#import "Deck.h"
#import "Favorite.h"

@interface FavoriteListViewController (PrivateMethods)
- (int) getBannerHeight:(UIDeviceOrientation)orientation;
- (int) getBannerHeight;
- (void) createAdBannerView;
- (void) fixupAdView:(UIInterfaceOrientation)toInterfaceOrientation;
@end

@implementation FavoriteListViewController
@synthesize favoriteDecks, favoriteDecksData;
@synthesize contentView = m_contentView;
@synthesize adBannerView = m_adBannerView;
@synthesize adBannerViewIsVisible = m_adBannerViewIsVisible;

- (void)dealloc 
{
	[self setFavoriteDecks:nil];
	[self setFavoriteDecksData:nil];
	childController = nil;
	self.contentView = nil;
	self.adBannerView = nil;
    [super dealloc];
}

- (void)viewDidUnload 
{
	self.favoriteDecks = nil;
	self.favoriteDecksData = nil;
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
	self.title = @"Favorites";
	[self updateTableView:nil];
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated
{
	[self fixupAdView:[UIDevice currentDevice].orientation];
	[self updateTableView:nil];
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

- (void)updateTableView:(NSNotification *)notification
{
	NSArray *joins = [NSArray arrayWithObjects:[Deck tableIdentifier], [Deck primaryKeyIdentifier], [Favorite tableIdentifier], [Favorite foreignKeyDeckIdColumnIdentifier], nil];
	
	self.favoriteDecksData = [Favorite findAllWithArrayOfJoins:joins];
	[favoriteDecks reloadData];
}

#pragma mark -
#pragma mark TableView Methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return [self.favoriteDecksData count];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
	return 0.0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	return @"Favorites";
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSDictionary *dict = [self.favoriteDecksData objectAtIndex:indexPath.row];
	static NSString *cellIdentifier = @"FavoriteCell";
	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
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
	cell.textLabel.text = [NSString stringWithFormat:@"%@", [dict valueForKey:@"title"]];
#else
	cell.text = [NSString stringWithFormat:@"%@", [dict valueForKey:@"title"]];
#endif
	
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	// Get the appropriate deck record, but first we need to get the primary key from our dictionary row
	// because we are using [Favorite findAllWithArrayOfJoins:] method which returns an NSArray of 
	// NSDictionary objects containing our record information.
	NSDictionary *dict = [self.favoriteDecksData objectAtIndex:indexPath.row];
	
	// Now query database, and get Deck Record. (An Active Record Database Pattern Implementation)
	
	NSNumber *foreignKeyDeckId = (NSNumber *)[dict valueForKey:[Favorite foreignKeyDeckIdColumnIdentifier]];
	
	NSArray *selectedDeckArray = [Deck findByColumn:[Deck primaryKeyIdentifier] integerValue:[foreignKeyDeckId integerValue]];
	Deck *selectedDeck = [selectedDeckArray objectAtIndex:0];
	
	if (childController == nil)
		childController = [[DeckSelectionScreenViewController alloc] initWithNibName:@"DeckSelectionScreenViewController" bundle:nil];
	
	childController.title = @"Deck Selection";
	childController.selectedDeck = selectedDeck;
	
	[self.navigationController pushViewController:childController animated:YES];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath 
{
	if (editingStyle == UITableViewCellEditingStyleDelete)
	{
		NSDictionary *dict = [self.favoriteDecksData objectAtIndex:indexPath.row];
		NSNumber *primaryKey = (NSNumber *)[dict valueForKey:[Favorite primaryKeyIdentifier]];
		Favorite *favoriteToDelete = [[Favorite alloc] init];
		favoriteToDelete.favoriteId = [primaryKey unsignedIntegerValue];
		favoriteToDelete.foreignKeyDeckId = (NSNumber *)[dict valueForKey:[Favorite foreignKeyDeckIdColumnIdentifier]];
		favoriteToDelete.savedInDatabase = YES;
		[favoriteToDelete remove];
		[favoriteToDelete release];
		
		[self updateTableView:nil];
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
			favoriteDecks.contentInset = UIEdgeInsetsMake(0.0, 0.0, 40.0, 0.0);
			favoriteDecks.scrollIndicatorInsets = favoriteDecks.contentInset;
		} else {
			CGRect adBannerViewFrame = [m_adBannerView frame];
			adBannerViewFrame.origin.x = 0;
			adBannerViewFrame.origin.y = -[self getBannerHeight:toInterfaceOrientation];
			[m_adBannerView setFrame:adBannerViewFrame];
			CGRect contentViewFrame = m_contentView.frame;
			contentViewFrame.origin.y = 0;
			contentViewFrame.size.height = self.view.frame.size.height;
			m_contentView.frame = contentViewFrame;
			favoriteDecks.contentInset = UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0);
			favoriteDecks.scrollIndicatorInsets = favoriteDecks.contentInset;
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
