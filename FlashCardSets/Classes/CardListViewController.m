//
//  CardListViewController.m
//  FlashNotes
//

#import "CardListViewController.h"
#import "CardEditViewController.h"
#import "ApplicationSetting.h"
#import "CardCell.h"
#import "DecksCardsJoin.h"
#import "Card.h"
#import "DebugOutput.h"

@interface CardListViewController (PrivateMethods)
- (int) getBannerHeight:(UIDeviceOrientation)orientation;
- (int) getBannerHeight;
- (void) createAdBannerView;
- (void) fixupAdView:(UIInterfaceOrientation)toInterfaceOrientation;
@end

@implementation CardListViewController
@synthesize cardList;
@synthesize foreignKeyDeckId;
@synthesize didComeFromDeckSelection;
@synthesize contentView = m_contentView;
@synthesize adBannerView = m_adBannerView;
@synthesize adBannerViewIsVisible = m_adBannerViewIsVisible;

- (void)dealloc 
{
	[self setCardList:nil];
	cardListData = nil;
	cardEditViewController = nil;
	self.contentView = nil;
	self.adBannerView = nil;
    [super dealloc];
}

- (void)viewDidUnload 
{
	self.cardList = nil;
	cardListData = nil;
	cardEditViewController = nil;
	
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
	self.title = @"Card List";
	
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Add Card" style:UIBarButtonItemStylePlain target:self action:@selector(addCard:)];
	
    [super viewDidLoad];
}

- (void)viewWillDisappear:(BOOL)animated
{
	self.didComeFromDeckSelection = NO;
	self.foreignKeyDeckId = 0;
	[cardListData release];
}

- (void)viewWillAppear:(BOOL)animated
{
	[self fixupAdView:[UIDevice currentDevice].orientation];
	[self loadCardListTableViewData];
}

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

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
#pragma mark - Custom Methods

- (void)loadCardListTableViewData
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	BOOL sortByFrontCard = [defaults boolForKey:@"SortByFrontCard"];
	
	if (cardListData != nil)
		cardListData = nil;
	
	if (self.foreignKeyDeckId == 0)
	{
		NSString *orderByColumn = (sortByFrontCard) ? [Card frontSideColumnIdentifier] : [Card backSideColumnIdentifier];

		[cardListData release];
		cardListData = [[Card findAllReturnNSArrayOfNSDictionariesWithWhereClause:[NSString stringWithFormat:@"ORDER BY %@.%@ ASC", [Card tableIdentifier], orderByColumn]] retain];
		
#if (APPLICATION_DEBUG_VERBOSE)
		debug(@"all cardListData ORDER BY %@ ASC : %@", orderByColumn, cardListData);
#endif
		
	}
	else
	{
		NSString *orderByColumn = (sortByFrontCard) ? [Card frontSideColumnIdentifier] : [Card backSideColumnIdentifier];
		NSArray *joins = [NSArray arrayWithObjects:[DecksCardsJoin tableIdentifier], [DecksCardsJoin foreignKeyCardIdColumnIdentifier],
						  [Card tableIdentifier], [Card primaryKeyIdentifier], nil];
		
		[cardListData release];
		cardListData = [[Card findWithArrayOfJoins:joins 
										withWhere:[NSString stringWithFormat:@"WHERE %@.%@ = %d ORDER BY %@.%@ ASC", [DecksCardsJoin tableIdentifier], 
												   [DecksCardsJoin foreignKeyDeckIdColumnIdentifier], self.foreignKeyDeckId, [Card tableIdentifier], orderByColumn]] retain];
		
#if (APPLICATION_DEBUG_VERBOSE)
		debug(@"cardListData by foreignKeyDeckId : %d, AND ORDER BY %@ ASC : %@", self.foreignKeyDeckId, orderByColumn, cardListData);
#endif
		
	}
	[self.cardList reloadData];
}

- (void)addCard:(id)sender
{
	cardEditViewController = [[CardEditViewController alloc] initWithNibName:@"CardEditViewController" bundle:nil];
	
	cardEditViewController.title = @"New Card";
	
	cardEditViewController.didComeFromDeckSelection = didComeFromDeckSelection;
	cardEditViewController.foreignKeyDeckId = foreignKeyDeckId;
	cardEditViewController.isNewCard = YES;
	
	[self.navigationController pushViewController:cardEditViewController animated:YES];
}
											  
											  
#pragma mark -
#pragma mark TableView Methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
	return [cardListData count];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
	return 0.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSDictionary *dict = [cardListData objectAtIndex:indexPath.row];
	
#if (APPLICATION_DEBUG_VERBOSE)
	debug(@"dict:%@", dict);
#endif
	
	NSString *frontSideDisplayLabelText = [[NSString alloc] initWithString:@"Front Side Header"];
	NSString *frontSideLabelText = [[NSString alloc] initWithString:[dict valueForKey:@"frontSide"]];
	NSString *backSideDisplayLabelText = [[NSString alloc] initWithString:@"Back Side Header"];
	NSString *backSideLabelText = [[NSString alloc] initWithString:[dict valueForKey:@"backSide"]];
	
	CGSize constraint = CGSizeMake(TABLE_VIEW_CELL_CONTENT_WIDTH - (TABLE_VIEW_CELL_CONTENT_MARGIN * 2), 20000.0f);
	
	CGSize frontSideDisplayLabelSize = [frontSideDisplayLabelText sizeWithFont:[UIFont systemFontOfSize:TABLE_VIEW_CELL_FONT_SIZE_SMALL_LARGE] constrainedToSize:constraint lineBreakMode:UILineBreakModeWordWrap];
	CGSize frontSideLabelSize = [frontSideLabelText sizeWithFont:[UIFont systemFontOfSize:TABLE_VIEW_CELL_FONT_SIZE_NORMAL_LARGE] constrainedToSize:constraint lineBreakMode:UILineBreakModeWordWrap];
	CGSize backSideDisplayLabelSize = [backSideDisplayLabelText sizeWithFont:[UIFont systemFontOfSize:TABLE_VIEW_CELL_FONT_SIZE_SMALL_LARGE] constrainedToSize:constraint lineBreakMode:UILineBreakModeWordWrap];
	CGSize backSideLabelSize = [backSideLabelText sizeWithFont:[UIFont systemFontOfSize:TABLE_VIEW_CELL_FONT_SIZE_NORMAL_LARGE] constrainedToSize:constraint lineBreakMode:UILineBreakModeWordWrap];
	
	CGFloat height = MAX(frontSideDisplayLabelSize.height + frontSideLabelSize.height + backSideDisplayLabelSize.height + backSideLabelSize.height, 44.0f);
	
	[frontSideDisplayLabelText release];
	[frontSideLabelText release];
	[backSideDisplayLabelText release];
	[backSideLabelText release];
	
	return height + (TABLE_VIEW_CELL_CONTENT_MARGIN * 2);
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	return @"Card List";
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSDictionary *dict = [cardListData objectAtIndex:indexPath.row];
	
	static NSString *cellIdentifier = @"CardCellIdentifier";
	
	CardCell *cell = (CardCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
	
	if (cell == nil)
	{
		cell = [[[CardCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier] autorelease];
		
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	}
	
	NSString *frontSideDisplayLabelText = [[NSString alloc] initWithString:@"Front Side Header"];
	NSString *frontSideLabelText = [[NSString alloc] initWithString:[dict valueForKey:@"frontSide"]];
	NSString *backSideDisplayLabelText = [[NSString alloc] initWithString:@"Back Side Header"];
	NSString *backSideLabelText = [[NSString alloc] initWithString:[dict valueForKey:@"backSide"]];
	
	CGSize constraint = CGSizeMake(TABLE_VIEW_CELL_CONTENT_WIDTH - (TABLE_VIEW_CELL_CONTENT_MARGIN * 2), 20000.0f);
	
	CGSize frontSideDisplayLabelSize = [frontSideDisplayLabelText sizeWithFont:[UIFont systemFontOfSize:TABLE_VIEW_CELL_FONT_SIZE_SMALL_LARGE] constrainedToSize:constraint lineBreakMode:UILineBreakModeWordWrap];
	CGSize frontSideLabelSize = [frontSideLabelText sizeWithFont:[UIFont systemFontOfSize:TABLE_VIEW_CELL_FONT_SIZE_NORMAL_LARGE] constrainedToSize:constraint lineBreakMode:UILineBreakModeWordWrap];
	CGSize backSideDisplayLabelSize = [backSideDisplayLabelText sizeWithFont:[UIFont systemFontOfSize:TABLE_VIEW_CELL_FONT_SIZE_SMALL_LARGE] constrainedToSize:constraint lineBreakMode:UILineBreakModeWordWrap];
	CGSize backSideLabelSize = [backSideLabelText sizeWithFont:[UIFont systemFontOfSize:TABLE_VIEW_CELL_FONT_SIZE_NORMAL_LARGE] constrainedToSize:constraint lineBreakMode:UILineBreakModeWordWrap];
	
	CGFloat frontSideLabelSizeHeight = frontSideDisplayLabelSize.height;
	CGFloat backSideDisplayLabelSizeHeight = frontSideDisplayLabelSize.height + frontSideLabelSize.height;
	CGFloat backSideLabelSizeHeight = frontSideDisplayLabelSize.height + frontSideLabelSize.height + backSideDisplayLabelSize.height;
	
	[cell.frontSideDisplayLabel setText:frontSideDisplayLabelText];
	[cell.frontSideDisplayLabel setFrame:CGRectMake(TABLE_VIEW_CELL_CONTENT_MARGIN, 5, TABLE_VIEW_CELL_CONTENT_WIDTH - (TABLE_VIEW_CELL_CONTENT_MARGIN * 2), frontSideDisplayLabelSize.height)];
	
	[cell.frontSideLabel setText:frontSideLabelText];
	[cell.frontSideLabel setFrame:CGRectMake(TABLE_VIEW_CELL_CONTENT_MARGIN, frontSideLabelSizeHeight + 4, TABLE_VIEW_CELL_CONTENT_WIDTH - (TABLE_VIEW_CELL_CONTENT_MARGIN * 2), frontSideLabelSize.height)];
	
	[cell.backSideDisplayLabel setText:backSideDisplayLabelText];
	[cell.backSideDisplayLabel setFrame:CGRectMake(TABLE_VIEW_CELL_CONTENT_MARGIN, backSideDisplayLabelSizeHeight + 12, TABLE_VIEW_CELL_CONTENT_WIDTH - (TABLE_VIEW_CELL_CONTENT_MARGIN * 2), backSideDisplayLabelSize.height)];
	
	[cell.backSideLabel setText:backSideLabelText];
	[cell.backSideLabel setFrame:CGRectMake(TABLE_VIEW_CELL_CONTENT_MARGIN, backSideLabelSizeHeight + 12 , TABLE_VIEW_CELL_CONTENT_WIDTH - (TABLE_VIEW_CELL_CONTENT_MARGIN * 2), backSideLabelSize.height)];
	
	[frontSideDisplayLabelText release];
	[frontSideLabelText release];
	[backSideDisplayLabelText release];
	[backSideLabelText release];
	
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSDictionary *dict = [cardListData objectAtIndex:indexPath.row];
	
	if (cardEditViewController == nil)
		cardEditViewController = [[CardEditViewController alloc] initWithNibName:@"CardEditViewController" bundle:nil];
	
	cardEditViewController.title = @"Edit Card";
	
	Card *selectedCard = [[Card alloc] init];
	NSNumber *pk = (NSNumber *)[dict valueForKey:[Card primaryKeyIdentifier]];
	selectedCard.cardId = [pk unsignedIntegerValue];
	selectedCard.frontSide = [dict valueForKey:[Card frontSideColumnIdentifier]];
	selectedCard.backSide = [dict valueForKey:[Card backSideColumnIdentifier]];
	selectedCard.foreignKeyCategoryId = [[dict valueForKey:[Card foreignKeyCategoryIdColumnIdentifier]] unsignedIntegerValue];
	selectedCard.savedInDatabase = YES;
	
	cardEditViewController.card = selectedCard;
	cardEditViewController.didComeFromDeckSelection = didComeFromDeckSelection;
	cardEditViewController.foreignKeyDeckId = foreignKeyDeckId;
	cardEditViewController.isNewCard = NO;
	
	[selectedCard release];
	
	[self.navigationController pushViewController:cardEditViewController animated:YES];
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
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
			cardList.contentInset = UIEdgeInsetsMake(50.0, 0.0, 0.0, 0.0);
			cardList.scrollIndicatorInsets = cardList.contentInset;
		} else {
			CGRect adBannerViewFrame = [m_adBannerView frame];
			adBannerViewFrame.origin.x = 0;
			adBannerViewFrame.origin.y = -[self getBannerHeight:toInterfaceOrientation];
			[m_adBannerView setFrame:adBannerViewFrame];
			CGRect contentViewFrame = m_contentView.frame;
			contentViewFrame.origin.y = 0;
			contentViewFrame.size.height = self.view.frame.size.height;
			m_contentView.frame = contentViewFrame;
			cardList.contentInset = UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0);
			cardList.scrollIndicatorInsets = cardList.contentInset;
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
