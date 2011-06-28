//
//  DownloadDetailViewController.m
//  LanguageFlashCards
//
//  Created by Douglas Mason on 5/12/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "DownloadDetailViewController.h"
#import "Deck.h"
#import "Card.h"
#import "DecksCardsJoin.h"
#import "AlertPrompt.h"
#import "DownloadOperation.h"

@interface DownloadDetailViewController (PrivateMethods)
- (int) getBannerHeight:(UIDeviceOrientation)orientation;
- (int) getBannerHeight;
- (void) createAdBannerView;
- (void) fixupAdView:(UIInterfaceOrientation)toInterfaceOrientation;
@end

@implementation DownloadDetailViewController

@synthesize titleOfSets;
@synthesize terms;
@synthesize spinner;
@synthesize tableView;
@synthesize contentView = m_contentView;
@synthesize adBannerView = m_adBannerView;
@synthesize adBannerViewIsVisible = m_adBannerViewIsVisible;

- (void)dealloc 
{
	[titleOfSets release];
	[terms release];
	self.contentView = nil;
	self.adBannerView = nil;
    [super dealloc];
}

#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad 
{
	[self createAdBannerView];
	UIBarButtonItem *download = [[UIBarButtonItem alloc] initWithTitle:@"Download"
																 style:UIBarButtonItemStylePlain
																target:self
																action:@selector(beginDownload)];
	self.navigationItem.rightBarButtonItem = download;
	[download release];
	
    [super viewDidLoad];
}

- (void) viewDidUnload
{
	self.titleOfSets = nil;
	self.terms = nil;
}

- (void) viewWillAppear:(BOOL)animated
{
	[self fixupAdView:[UIDevice currentDevice].orientation];
	self.title = titleOfSets;
	[self.tableView reloadData];
}

- (void) willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
	[self fixupAdView:toInterfaceOrientation];
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
    return [terms count];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)table cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"SetsCellIdentifier";
	
	NSArray	 *array = [terms objectAtIndex:[indexPath row]];
    
    UITableViewCell *cell = [table dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) 
	{
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
    }
    
	cell.textLabel.text = [array objectAtIndex:0];
	cell.detailTextLabel.text = [array objectAtIndex:1];
    
    return cell;
}

#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)table didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
    [table deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark -
#pragma mark UIAlertView Delegate

- (void)alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex
{
	if (buttonIndex != [alertView cancelButtonIndex])
	{
		[self download:[(AlertPrompt *)alertView enteredText]];
	}
}

#pragma mark -
#pragma mark Custom Methods

- (void) beginDownload
{
	AlertPrompt *prompt = [[AlertPrompt alloc] initWithTitle:@"Download Set" 
													 message:@"Download Set" 
													delegate:self
											   textFieldText:self.title
										   cancelButtonTitle:@"Cancel"
											   okButtonTitle:@"OK"];
	
	[prompt show];
	[prompt release];
}

- (void) download:(NSString *)nameOfSet
{
	[spinner startAnimating];
	
	DownloadOperation *operation = [[DownloadOperation alloc] initWithTitle:nameOfSet listOfTerms:terms delegate:self];
	[operation startDownload];
}

- (void) stopSpinner
{
	[spinner stopAnimating];
}

#pragma mark -
#pragma mark Download Operation Delegate

- (void) downloadDidFinish:(DownloadOperation *)downloadOp
{
	[spinner stopAnimating];
	[downloadOp release];
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
			tableView.contentInset = UIEdgeInsetsMake(0.0, 0.0, 55.0, 0.0);
			tableView.scrollIndicatorInsets = tableView.contentInset;
		} else {
			CGRect adBannerViewFrame = [m_adBannerView frame];
			adBannerViewFrame.origin.x = 0;
			adBannerViewFrame.origin.y = -[self getBannerHeight:toInterfaceOrientation];
			[m_adBannerView setFrame:adBannerViewFrame];
			CGRect contentViewFrame = m_contentView.frame;
			contentViewFrame.origin.y = 0;
			contentViewFrame.size.height = self.view.frame.size.height;
			m_contentView.frame = contentViewFrame;
			tableView.contentInset = UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0);
			tableView.scrollIndicatorInsets = tableView.contentInset;
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

