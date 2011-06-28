//
//  DeckListViewController.m
//  FlashNotes
//

#import "DeckListViewController.h"
#import "DeckSelectionScreenViewController.h"
#import "Deck.h"
#import "Favorite.h"
#import "AlertPrompt.h"
#import "cocos2d.h"

@interface DeckListViewController (PrivateMethods)
- (int) getBannerHeight:(UIDeviceOrientation)orientation;
- (int) getBannerHeight;
- (void) createAdBannerView;
- (void) fixupAdView:(UIInterfaceOrientation)toInterfaceOrientation;
@end

@implementation DeckListViewController
@synthesize deckList;
@synthesize deckListData;

@synthesize contentView = m_contentView;
@synthesize adBannerView = m_adBannerView;
@synthesize adBannerViewIsVisible = m_adBannerViewIsVisible;

- (void)dealloc 
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	childController = nil;
	[self setDeckList:nil];
	[self setDeckListData:nil];
	
	self.contentView = nil;
	self.adBannerView = nil;
    [super dealloc];
}

- (void)viewDidUnload {
	self.deckListData = nil;
	self.deckList = nil;
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
- (void)viewDidLoad {
	[self createAdBannerView];
	self.title = @"Decks";
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateTableView) name:kUpdateTableViewsUsingDeckData object:nil];
	[self updateTableView];
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated
{
	[self fixupAdView:[UIDevice currentDevice].orientation];
	[self updateTableView];
}

//- (void)viewDidAppear:(BOOL)animated
//{
//	[self updateTableView];
//}


// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
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

- (void)updateTableView
{
	[deckListData release];
	deckListData = [[NSArray alloc] init];
	self.deckListData = [Deck findAll];
	[deckList reloadData];
}

- (IBAction)addDeck:(id)sender
{
	AlertPrompt *prompt = [AlertPrompt alloc];
	prompt = [prompt initWithTitle:@"Add Deck" message:@"Insert Deck Title" delegate:self cancelButtonTitle:@"Cancel" okButtonTitle:@"OK"];
	[prompt show];
	[prompt release];
}

#pragma mark -
#pragma mark - Alert View Delegate Method

- (void)alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex
{
	if (buttonIndex != [alertView cancelButtonIndex])
	{
		NSString *enteredText = [(AlertPrompt *)alertView enteredText];
		Deck *newlyAddedDeck = [[Deck alloc] init];
		newlyAddedDeck.title = enteredText;
		[newlyAddedDeck save];
		[newlyAddedDeck release];
		
		[[NSNotificationCenter defaultCenter] postNotificationName:kUpdateTableViewsUsingDeckData object:nil];
	}
}

#pragma mark -
#pragma mark TableView Methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
	return [self.deckListData count];
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
	return @"Decks";
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	Deck *deck = [deckListData objectAtIndex:indexPath.row];
	static NSString *cellIdentifier = @"DecksCell";
	
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
		
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	}
	
#if __IPHONE_OS_VERSION_MIN_REQUIRED >= 30000
	cell.textLabel.text = [NSString stringWithFormat:@"%@", deck.title];
#else
	cell.text = [NSString stringWithFormat:@"%@", deck.title];
#endif
	
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
	// Get the appropriate deck record
	Deck *selectedDeck = [self.deckListData objectAtIndex:indexPath.row];
	
	if (childController == nil)
		childController = [[DeckSelectionScreenViewController alloc] initWithNibName:@"DeckSelectionScreenViewController" bundle:nil];
	
	childController.title = [NSString stringWithString:@"Deck Selection"];
	childController.selectedDeck = selectedDeck;
	
	[self.navigationController pushViewController:childController animated:YES];
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath 
{
	if (editingStyle == UITableViewCellEditingStyleDelete)
	{
		Deck *deckToBeDeleted = [self.deckListData objectAtIndex:indexPath.row];
		
		NSArray *deckFavoriteToBeDeletedArray = [Favorite findByColumn:[Favorite foreignKeyDeckIdColumnIdentifier] integerValue:deckToBeDeleted.deckId];
		if ([deckFavoriteToBeDeletedArray count] != 0 && [deckFavoriteToBeDeletedArray count] == 1)
		{
			Favorite *favoriteToBeDeleted = [deckFavoriteToBeDeletedArray objectAtIndex:0];
			[favoriteToBeDeleted remove];
		}
		
		[deckToBeDeleted remove];
		[self updateTableView];
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
			deckList.contentInset = UIEdgeInsetsMake(0.0, 0.0, 60.0, 0.0);
			deckList.scrollIndicatorInsets = deckList.contentInset;
		} else {
			CGRect adBannerViewFrame = [m_adBannerView frame];
			adBannerViewFrame.origin.x = 0;
			adBannerViewFrame.origin.y = -[self getBannerHeight:toInterfaceOrientation];
			[m_adBannerView setFrame:adBannerViewFrame];
			CGRect contentViewFrame = m_contentView.frame;
			contentViewFrame.origin.y = 0;
			contentViewFrame.size.height = self.view.frame.size.height;
			m_contentView.frame = contentViewFrame;
			deckList.contentInset = UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0);
			deckList.scrollIndicatorInsets = deckList.contentInset;
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
