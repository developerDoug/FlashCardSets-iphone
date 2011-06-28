//
//  DownloadViewController.m
//  LanguageFlashCards
//
//  Created by Douglas Mason on 5/11/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "DownloadViewController.h"
#import "JSON.h"
#import "ApplicationSetting.h"
#import "DownloadDetailViewController.h"

static NSString *QUIZLET_API_KEY = @"em30b3t7o2ogw08k";

@interface DownloadViewController (PrivateMethods)
- (void) loadSelectSearchTypePickerData;
- (void) info;
- (int) getBannerHeight:(UIDeviceOrientation)orientation;
- (int) getBannerHeight;
- (void) createAdBannerView;
- (void) fixupAdView:(UIInterfaceOrientation)toInterfaceOrientation;
@end

@implementation DownloadViewController

@synthesize searchBar;
@synthesize tableView;
@synthesize spinner;
@synthesize receivedData;
@synthesize detailController;
@synthesize contentView = m_contentView;
@synthesize adBannerView = m_adBannerView;
@synthesize adBannerViewIsVisible = m_adBannerViewIsVisible;

- (void) dealloc
{
	[searchData release];
	[searchBar release];
	[tableView release];
	[receivedData release];
	[spinner release];
	self.contentView = nil;
	self.adBannerView = nil;
	[super dealloc];
}

- (void) viewDidUnload
{
	self.searchBar = nil;
	self.tableView = nil;
	
	[super viewDidUnload];
}

- (void)viewDidLoad 
{
	[self createAdBannerView];
	self.title = @"Downloads";
	
	UIBarButtonItem *leftBarButton = [[UIBarButtonItem alloc] initWithTitle:@"Search By"
																	  style:UIBarButtonItemStylePlain
																	 target:self
																	 action:@selector(searchByButtonClick:)];
	self.navigationItem.leftBarButtonItem = leftBarButton;
	[leftBarButton release];
	
	UIBarButtonItem *rightBarButton = [[UIBarButtonItem alloc] initWithTitle:@"Info"
																	   style:UIBarButtonItemStylePlain
																	  target:self
																	  action:@selector(info)];
	self.navigationItem.rightBarButtonItem = rightBarButton;
	[rightBarButton release];
	
    [super viewDidLoad];
}

- (void) viewWillAppear:(BOOL)animated
{
	[self fixupAdView:[UIDevice currentDevice].orientation];
	[self determineTypeOfSearch];
	[self loadSelectSearchTypePickerData];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation 
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)didReceiveMemoryWarning 
{
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

- (void) searchQuizlet:(NSString *)searchString
{
	[spinner startAnimating];
	
	//	Build the string (url) to call the quizlet api
	NSMutableString *urlString = [NSMutableString stringWithFormat:@"http://quizlet.com/api/1.0/sets?dev_key=%@&q=%@&whitespace=on&extended=on", QUIZLET_API_KEY, (isSearchByCreator) ? [NSString stringWithFormat:@"creator:%@", searchString] : searchString];
	[urlString setString:[urlString stringByReplacingOccurrencesOfString:@" " withString:@"%20"]];
	
	
	//	Create NSURL string from formatted string
	NSURL *url = [NSURL URLWithString:urlString];
	
	NSLog(@"url: %@", url);
	
	//	Setup and start async download
	NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
	NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
	
	if (connection)
	{
		NSMutableData *data = [[NSMutableData alloc] init];
		self.receivedData = data;
		[data release];
	}
	else
	{
		[spinner stopAnimating];
		
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error!"
														message:@"Unable to connect to remote server"
													   delegate:nil
											  cancelButtonTitle:@"OK"
											  otherButtonTitles:nil];
		[alert show];
		[alert release];
	}
	
	[request release];
}

- (void) determineTypeOfSearch
{
	NSArray *searchByKeywordOrCreator = [ApplicationSetting findAllReturnNSArrayOfNSDictionariesWithWhereClause:[NSString stringWithFormat:@"WHERE %@ = %@",
																												 [ApplicationSetting applicationSettingTagIdentifierColumnIdentifier],
																												 @"'SearchByKeywordOrCreator'"]];
	NSDictionary *searchByKeywordOrCreatorDict = [searchByKeywordOrCreator objectAtIndex:0];
	NSUInteger searchByKeyword = [(NSNumber *)[searchByKeywordOrCreatorDict valueForKey:[ApplicationSetting applicationSettingValueColumnIdentifier]] unsignedIntegerValue];
	if (searchByKeyword == 1)
		isSearchByCreator = NO;
	else
		isSearchByCreator = YES;
}

- (void) searchByButtonClick:(id)sender
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
	
	// an array of bar buttons, which will be passed to setItems:animated: on the toolBar control
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

- (void) loadSelectSearchTypePickerData
{
	NSArray *array = [[NSArray alloc] initWithObjects:@"Keyword", @"Creator", nil];
	[selectSearchTypePickerData release];
	selectSearchTypePickerData = [array retain];
	[array release];
}

- (void) searchByDoneButtonClick:(id)sender
{
	[selectSearchTypeActionSheet dismissWithClickedButtonIndex:0 animated:YES];
	[self determineTypeOfSearch];
	[selectSearchTypePicker release];
	[selectSearchTypeActionSheet release];
}

- (void) info
{
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Usage"
													message:@"To search for flash cards created by your self, you need to go to http://quizlet.com and sign up for a free account. Then simply create public viewable sets and search by creator for those."
												   delegate:nil
										  cancelButtonTitle:@"OK"
										  otherButtonTitles:nil];
	[alert show];
	[alert release];
}

#pragma mark -
#pragma mark TableView Methods

- (NSInteger) tableView:(UITableView *)table numberOfRowsInSection:(NSInteger)section
{
	return [searchData count];
}

- (NSInteger) numberOfSectionsInTableView:(UITableView *)table
{
	return 1;
}

- (UITableViewCell *) tableView:(UITableView *)table cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString *cellIdentifier = @"CellIdentifier";
	
	NSDictionary *dict = [searchData objectAtIndex:[indexPath row]];
	
	UITableViewCell *cell = [table dequeueReusableCellWithIdentifier:cellIdentifier];
	if (cell == nil)
	{
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier] autorelease];
	}
	
	cell.textLabel.text = [dict valueForKey:@"title"];
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	
	return cell;
}

- (void) tableView:(UITableView *)table didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSDictionary *dict = [searchData objectAtIndex:[indexPath row]];
	NSArray *terms = [dict valueForKey:@"terms"];
	
	self.detailController.titleOfSets = [dict valueForKey:@"title"];
	self.detailController.terms = terms;
	
	[self.navigationController pushViewController:detailController animated:YES];
	[table deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark -
#pragma mark NSURLConnection Callbacks

- (void) connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
	[receivedData setLength:0];
}

- (void) connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
	[receivedData appendData:data];
}

- (void) connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
	[connection release];
	
	[spinner stopAnimating];
	
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error!"
													message:[NSString stringWithFormat:@"Connection failed! Error - %@ (URL: %@)", 
															 [error localizedDescription], [[error userInfo] objectForKey:NSErrorFailingURLStringKey]]
												   delegate:nil
										  cancelButtonTitle:@"OK"
										  otherButtonTitles:nil];
	[alert show];
	[alert release];
}

- (void) connectionDidFinishLoading:(NSURLConnection *)connection
{
	//	Store incoming data into a string
	NSString *jsonString = [[NSString alloc] initWithData:self.receivedData encoding:NSUTF8StringEncoding];
	
	//	Create a dictionary from the JSON string
	NSDictionary *results = [jsonString JSONValue];
	
	//	Create an NSArray to hold the sets
	NSArray *setsOfCards = [results valueForKey:@"sets"];
	
	[searchData release];
	searchData = [setsOfCards retain];
	
	[tableView reloadData];
	
	[jsonString release];
	
	[connection release];
	self.receivedData = nil;
	
	[spinner stopAnimating];
}

#pragma mark -
#pragma mark Search Bar Delegate Methods

- (void)searchBarSearchButtonClicked:(UISearchBar *)search
{
	[search resignFirstResponder];
	[self searchQuizlet:[search text]];
	[search setText:@""];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)search
{
	[search setText:@""];
	[search resignFirstResponder];
}

#pragma mark -
#pragma mark Picker Data Source Methods

- (NSInteger) numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
	return 1;
}

- (NSInteger) pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
	return [selectSearchTypePickerData count];
}

#pragma mark -
#pragma mark Picker Delegate Methods

- (NSString *) pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
	NSArray *searchByKeywordOrCreator = [ApplicationSetting findAllReturnNSArrayOfNSDictionariesWithWhereClause:[NSString stringWithFormat:@"WHERE %@ = %@",
																												 [ApplicationSetting applicationSettingTagIdentifierColumnIdentifier],
																												 @"'SearchByKeywordOrCreator'"]];
	NSString *pickerString = [selectSearchTypePickerData objectAtIndex:row];
	NSUInteger selectKeywordOrCreator = [[[searchByKeywordOrCreator objectAtIndex:0] valueForKey:[ApplicationSetting applicationSettingValueColumnIdentifier]] unsignedIntegerValue];
	
	if (selectKeywordOrCreator == 1 && [pickerString isEqualToString:@"Keyword"])
	{
		[pickerView selectRow:row inComponent:component animated:YES];
	}
	else if (selectKeywordOrCreator == 0 && [pickerString isEqualToString:@"Creator"])
	{
		[pickerView selectRow:row inComponent:component animated:YES];
	}
	
	return pickerString;
}

- (void) pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
	NSString *pickerString = [selectSearchTypePickerData objectAtIndex:row];
	NSArray *searchByKeywordOrCreator = [ApplicationSetting findAllReturnNSArrayOfNSDictionariesWithWhereClause:[NSString stringWithFormat:@"WHERE %@ = %@",
																												 [ApplicationSetting applicationSettingTagIdentifierColumnIdentifier],
																												 @"'SearchByKeywordOrCreator'"]];
	if ([pickerString isEqualToString:@"Keyword"])
	{
		if ([[[searchByKeywordOrCreator objectAtIndex:0] valueForKey:[ApplicationSetting applicationSettingValueColumnIdentifier]] unsignedIntegerValue] != 1)
		{
			NSDictionary *dict = [searchByKeywordOrCreator objectAtIndex:0];
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
	
	if ([pickerString isEqualToString:@"Creator"])
	{
		if ([[[searchByKeywordOrCreator objectAtIndex:0] valueForKey:[ApplicationSetting applicationSettingValueColumnIdentifier]] unsignedIntegerValue] != 0)
		{
			NSDictionary *dict = [searchByKeywordOrCreator objectAtIndex:0];
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
			tableView.contentInset = UIEdgeInsetsMake(0.0, 0.0, 40.0, 0.0);
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
