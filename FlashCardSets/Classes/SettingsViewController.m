//
//  SettingsViewController.m
//  FlashNotes
//
//  Created by Douglas Mason on 12/23/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "SettingsViewController.h"
#import "ApplicationSetting.h"

@implementation SettingsViewController

@synthesize settingsTableView;

- (void)dealloc 
{
	[self.settingsTableView release];
    [super dealloc];
}

- (void)viewDidUnload 
{
	self.settingsTableView = nil;
	[super viewDidUnload];
}

- (void)viewDidLoad 
{
	self.title = @"Settings";
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

#pragma mark -
#pragma mark Custom Methods

- (void)searchCardsOrDecksSegmentedControlValueChanged:(id)sender
{
	NSUInteger searchCardsOrDecksSegmentedControlIndex = [sender selectedSegmentIndex];
	
	// Query the database to get the record, put it in an Active Record Object and then save
	NSArray *searchCardsOrDecksArray = [ApplicationSetting findAllReturnNSArrayOfNSDictionariesWithWhereClause:[NSString stringWithFormat:@"WHERE %@ = %@",
																												[ApplicationSetting applicationSettingTagIdentifierColumnIdentifier],
																												@"'SearchForCardsOrDecks'"]];
	NSDictionary *dict = [searchCardsOrDecksArray objectAtIndex:0];
	
	ApplicationSetting *settingToSave = [[ApplicationSetting alloc] init];
	settingToSave.applicationSettingId = [(NSNumber *)[dict valueForKey:[ApplicationSetting primaryKeyColumnIdentifier]] unsignedIntegerValue];
	settingToSave.applicationSettingDisplayName = [dict valueForKey:[ApplicationSetting applicationSettingDisplayNameColumnIdentifier]];
	settingToSave.applicationSettingTagIdentifier = [dict valueForKey:[ApplicationSetting applicationSettingTagIdentifierColumnIdentifier]];
	settingToSave.savedInDatabase = YES;
	if (searchCardsOrDecksSegmentedControlIndex != kSearchForCardsOrDecksSegmentedControlCardIndex)
	{
		settingToSave.applicationSettingValue = kSearchForCardsOrDecksSegmentedControlDeckIndex;
	}
	else
	{
		settingToSave.applicationSettingValue = kSearchForCardsOrDecksSegmentedControlCardIndex;
	}
	[settingToSave save];
	[settingToSave release];
}

- (void)sortByFrontCardOrBackCardSegmentedControlValueChanged:(id)sender
{
	NSUInteger sortByFrontCardOrBackCardSegmentedControlIndex = [sender selectedSegmentIndex];
	
	// Query the database to get the record, put it in an Active Record Object and then save
	NSArray *sortByFrontCardOrBackCardArray = [ApplicationSetting findAllReturnNSArrayOfNSDictionariesWithWhereClause:[NSString stringWithFormat:@"WHERE %@ = %@",
																													   [ApplicationSetting applicationSettingTagIdentifierColumnIdentifier],
																													   @"'SortByFrontCard'"]];
	NSDictionary *dict = [sortByFrontCardOrBackCardArray objectAtIndex:0];
	
	ApplicationSetting *settingToSave = [[ApplicationSetting alloc] init];
	settingToSave.applicationSettingId = [(NSNumber*)[dict valueForKey:[ApplicationSetting primaryKeyColumnIdentifier]] unsignedIntegerValue];
	settingToSave.applicationSettingDisplayName = [dict valueForKey:[ApplicationSetting applicationSettingDisplayNameColumnIdentifier]];
	settingToSave.applicationSettingTagIdentifier = [dict valueForKey:[ApplicationSetting applicationSettingTagIdentifierColumnIdentifier]];
	settingToSave.savedInDatabase = YES;
	if (sortByFrontCardOrBackCardSegmentedControlIndex != kSortByFrontCardOrBackCardSegmentedControlFrontIndex)
	{
		settingToSave.applicationSettingValue = kSortByFrontCardOrBackCardSegmentedControlBackIndex;
	}
	else
	{
		settingToSave.applicationSettingValue = kSortByFrontCardOrBackCardSegmentedControlFrontIndex;
	}
	[settingToSave save];
	[settingToSave release];
}

- (void)displayFrontCardsSwitchValueChanged:(id)sender
{
	NSNumber *displayFrontCardsSwitchValue;
	
	UISwitch *displayFrontCardsSwitch = (UISwitch *)sender;
	if (displayFrontCardsSwitch.on)
		displayFrontCardsSwitchValue = [NSNumber numberWithUnsignedInteger:1];
	else
		displayFrontCardsSwitchValue = [NSNumber numberWithUnsignedInteger:0];
	
	// Query the database to get the record, put it in an Active Record Object and then save
	NSArray *displayFrontCardsArray = [ApplicationSetting findAllReturnNSArrayOfNSDictionariesWithWhereClause:[NSString stringWithFormat:@"WHERE %@ = %@",
																													  [ApplicationSetting applicationSettingTagIdentifierColumnIdentifier],
																													  @"'DisplayFrontCard'"]];
	NSDictionary *dict = [displayFrontCardsArray objectAtIndex:0];
	
	ApplicationSetting *settingToSave = [[ApplicationSetting alloc] init];
	settingToSave.applicationSettingId = [(NSNumber *)[dict valueForKey:[ApplicationSetting primaryKeyColumnIdentifier]] unsignedIntegerValue];
	settingToSave.applicationSettingDisplayName = [dict valueForKey:[ApplicationSetting applicationSettingDisplayNameColumnIdentifier]];
	settingToSave.applicationSettingTagIdentifier = [dict valueForKey:[ApplicationSetting applicationSettingTagIdentifierColumnIdentifier]];
	settingToSave.applicationSettingValue = [displayFrontCardsSwitchValue unsignedIntegerValue];
	settingToSave.savedInDatabase = YES;
	[settingToSave save];
	[settingToSave release];
}

- (void)alwaysShowExitButtonWhenPlayingCardsSwitchValueChanged:(id)sender
{
	NSNumber *alwaysShowExitButtonSwitchValue;
	
	UISwitch *alwaysShowExitButtonSwitch = (UISwitch*)sender;
	if (alwaysShowExitButtonSwitch.on)
		alwaysShowExitButtonSwitchValue = [NSNumber numberWithUnsignedInteger:1];
	else
		alwaysShowExitButtonSwitchValue = [NSNumber numberWithUnsignedInteger:0];
	
	// Query the database to get the record, put it in an Active Record Object and then save
	NSArray *alwaysShowExitButtonArray = [ApplicationSetting findAllReturnNSArrayOfNSDictionariesWithWhereClause:[NSString stringWithFormat:@"WHERE %@ = %@",
																												  [ApplicationSetting applicationSettingTagIdentifierColumnIdentifier],
																												  @"'AlwaysShowExitButtonWhenPlayingCards'"]];
	NSDictionary *dict = [alwaysShowExitButtonArray objectAtIndex:0];
	
	ApplicationSetting *settingToSave = [[ApplicationSetting alloc] init];
	settingToSave.applicationSettingId = [(NSNumber*)[dict valueForKey:[ApplicationSetting primaryKeyColumnIdentifier]] unsignedIntegerValue];
	settingToSave.applicationSettingDisplayName = [dict valueForKey:[ApplicationSetting applicationSettingDisplayNameColumnIdentifier]];
	settingToSave.applicationSettingTagIdentifier = [dict valueForKey:[ApplicationSetting applicationSettingTagIdentifierColumnIdentifier]];
	settingToSave.applicationSettingValue = [alwaysShowExitButtonSwitchValue unsignedIntegerValue];
	settingToSave.savedInDatabase = YES;
	[settingToSave save];
	[settingToSave release];
}

- (void)continueWithOppositeSideWhenFlippedSwitchValueChanged:(id)sender
{
	NSNumber *continueWithOppositeSideWhenFlippedSwitchValue;
	
	UISwitch *continueWithOppositeSideWhenFlippedSwitch = (UISwitch*)sender;
	if (continueWithOppositeSideWhenFlippedSwitch.on)
		continueWithOppositeSideWhenFlippedSwitchValue = [NSNumber numberWithUnsignedInteger:1];
	else
		continueWithOppositeSideWhenFlippedSwitchValue = [NSNumber numberWithUnsignedInteger:0];
	
	// Query the database to get the record, put it in an Active Record Object and then save
	NSArray *continueWithOppositeSideWhenFlippedArray = [ApplicationSetting findAllReturnNSArrayOfNSDictionariesWithWhereClause:[NSString stringWithFormat:@"WHERE %@ = %@",
																																 [ApplicationSetting applicationSettingTagIdentifierColumnIdentifier],
																																 @"'ContinueWithOppositeSideWhenFlipped'"]];
	NSDictionary *dict = [continueWithOppositeSideWhenFlippedArray objectAtIndex:0];
	
	ApplicationSetting *settingToSave = [[ApplicationSetting alloc] init];
	settingToSave.applicationSettingId = [(NSNumber*)[dict valueForKey:[ApplicationSetting primaryKeyColumnIdentifier]] unsignedIntegerValue];
	settingToSave.applicationSettingDisplayName = [dict valueForKey:[ApplicationSetting applicationSettingDisplayNameColumnIdentifier]];
	settingToSave.applicationSettingTagIdentifier = [dict valueForKey:[ApplicationSetting applicationSettingTagIdentifierColumnIdentifier]];
	settingToSave.applicationSettingValue = [continueWithOppositeSideWhenFlippedSwitchValue unsignedIntegerValue];
	settingToSave.savedInDatabase = YES;
	[settingToSave save];
	[settingToSave release];
}

#pragma mark -
#pragma mark TableView Methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	if (section == 0)
		return 1;
	if (section == 1)
		return 1;
	if (section == 2)
		return 3;
	
	return 0;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 3;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
	return 45.0f;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	if (section == 0)
		return @"Searching";
	if (section == 1)
		return @"Sorting";
	if (section == 2)
		return @"Cards";
	
	return @"";
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString *cellIdentifier = @"ApplicationSettingCell";
	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
	if (cell == nil)
	{
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier] autorelease];
	}
	
	if (indexPath.section == 0 && indexPath.row == 0)
	{
		NSArray *searchForCardsOrDecksArray = [ApplicationSetting findAllReturnNSArrayOfNSDictionariesWithWhereClause:[NSString stringWithFormat:@"WHERE %@ = %@", 
																															  [ApplicationSetting applicationSettingTagIdentifierColumnIdentifier],
																															  @"'SearchForCardsOrDecks'"]];
		NSDictionary *dict = [searchForCardsOrDecksArray objectAtIndex:0];
		
		UILabel *searchForCardsOrDecksLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0, 12.0, 152.0, 15.0)];
		searchForCardsOrDecksLabel.textAlignment = UITextAlignmentLeft;
		searchForCardsOrDecksLabel.text = [dict valueForKey:[ApplicationSetting applicationSettingDisplayNameColumnIdentifier]];
		searchForCardsOrDecksLabel.font = [UIFont systemFontOfSize:12.0];
		[cell.contentView addSubview:searchForCardsOrDecksLabel];
		[searchForCardsOrDecksLabel release];
										
		UISegmentedControl *searchForCardsOrDecksSegmentedControl = [[UISegmentedControl alloc] 
																	  initWithFrame:CGRectMake(172.0, 8.0, 120.0, 26.0)];
		[searchForCardsOrDecksSegmentedControl insertSegmentWithTitle:@"Cards" atIndex:0 animated:NO];
		[searchForCardsOrDecksSegmentedControl insertSegmentWithTitle:@"Decks" atIndex:1 animated:NO];
		searchForCardsOrDecksSegmentedControl.segmentedControlStyle = UISegmentedControlStyleBar;
		searchForCardsOrDecksSegmentedControl.selectedSegmentIndex = [(NSNumber *)[dict valueForKey:[ApplicationSetting applicationSettingValueColumnIdentifier]] unsignedIntegerValue];
		[searchForCardsOrDecksSegmentedControl addTarget:self action:@selector(searchCardsOrDecksSegmentedControlValueChanged:) forControlEvents:UIControlEventValueChanged];
		[cell.contentView addSubview:searchForCardsOrDecksSegmentedControl];
		[searchForCardsOrDecksSegmentedControl release];	
	}
	
	if (indexPath.section == 1 && indexPath.row == 0)
	{
		NSArray *sortByFrontCardOrBackCardArray = [ApplicationSetting findAllReturnNSArrayOfNSDictionariesWithWhereClause:[NSString stringWithFormat:@"WHERE %@ = %@",
																														   [ApplicationSetting applicationSettingTagIdentifierColumnIdentifier],
																														   @"'SortByFrontCard'"]];
		NSDictionary *dict = [sortByFrontCardOrBackCardArray objectAtIndex:0];
		
		UILabel *sortByFrontCardOrBackCardLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0, 12.0, 152.0, 15.0)];
		sortByFrontCardOrBackCardLabel.textAlignment = UITextAlignmentLeft;
		sortByFrontCardOrBackCardLabel.text = [dict valueForKey:[ApplicationSetting applicationSettingDisplayNameColumnIdentifier]];
		sortByFrontCardOrBackCardLabel.font = [UIFont systemFontOfSize:12.0];
		[cell.contentView addSubview:sortByFrontCardOrBackCardLabel];
		[sortByFrontCardOrBackCardLabel release];
		
		UISegmentedControl *sortByFrontCardOrBackCardSegmentedControl = [[UISegmentedControl alloc]
																		 initWithFrame:CGRectMake(172.0, 8.0, 120.0, 26.0)];
		[sortByFrontCardOrBackCardSegmentedControl insertSegmentWithTitle:@"Back" atIndex:0 animated:NO];
		[sortByFrontCardOrBackCardSegmentedControl insertSegmentWithTitle:@"Front" atIndex:1 animated:NO];
		sortByFrontCardOrBackCardSegmentedControl.segmentedControlStyle = UISegmentedControlStyleBar;
		sortByFrontCardOrBackCardSegmentedControl.selectedSegmentIndex = [(NSNumber*)[dict valueForKey:[ApplicationSetting applicationSettingValueColumnIdentifier]] unsignedIntegerValue];
		[sortByFrontCardOrBackCardSegmentedControl addTarget:self action:@selector(sortByFrontCardOrBackCardSegmentedControlValueChanged:) forControlEvents:UIControlEventValueChanged];
		[cell.contentView addSubview:sortByFrontCardOrBackCardSegmentedControl];
		[sortByFrontCardOrBackCardSegmentedControl release];
	}
	
	if (indexPath.section == 2 && indexPath.row == 0)
	{
		NSArray *displayFrontCardOrBack = [ApplicationSetting findAllReturnNSArrayOfNSDictionariesWithWhereClause:[NSString stringWithFormat:@"WHERE %@ = %@",
																														  [ApplicationSetting applicationSettingTagIdentifierColumnIdentifier],
																														  @"'DisplayFrontCard'"]];
		NSDictionary *dict = [displayFrontCardOrBack objectAtIndex:0];
		
		UILabel *displayFrontCardOrBackLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0, 14.0, 185.0, 15.0)];
		displayFrontCardOrBackLabel.textAlignment = UITextAlignmentLeft;
		displayFrontCardOrBackLabel.text = [dict valueForKey:[ApplicationSetting applicationSettingDisplayNameColumnIdentifier]];
		displayFrontCardOrBackLabel.font = [UIFont systemFontOfSize:12.0];
		[cell.contentView addSubview:displayFrontCardOrBackLabel];
		[displayFrontCardOrBackLabel release];
		
		UISwitch *displayFrontCardOrBackSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(195.0, 8.0, 120.0, 26.0)];
		NSUInteger intBoolForDisplayFrontCardOrBack = [(NSNumber *)[dict valueForKey:[ApplicationSetting applicationSettingValueColumnIdentifier]] unsignedIntegerValue];
		
		if (intBoolForDisplayFrontCardOrBack == 1)
			displayFrontCardOrBackSwitch.on = YES;
		else
			displayFrontCardOrBackSwitch.on = NO;
		
		[displayFrontCardOrBackSwitch addTarget:self action:@selector(displayFrontCardsSwitchValueChanged:) forControlEvents:UIControlEventValueChanged];
		[cell.contentView addSubview:displayFrontCardOrBackSwitch];
		[displayFrontCardOrBackSwitch release];
	}
	else if (indexPath.section == 2 && indexPath.row == 1)
	{
		NSArray *alwaysShowExitButtonArrayOfDicts = [ApplicationSetting findAllReturnNSArrayOfNSDictionariesWithWhereClause:[NSString stringWithFormat:@"WHERE %@ = %@",
																															 [ApplicationSetting applicationSettingTagIdentifierColumnIdentifier],
																															 @"'AlwaysShowExitButtonWhenPlayingCards'"]];
		NSDictionary *dict = [alwaysShowExitButtonArrayOfDicts objectAtIndex:0];
		
		UILabel *alwaysShowExitButtonLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0, 14.0, 185.0, 15.0)];
		alwaysShowExitButtonLabel.textAlignment = UITextAlignmentLeft;
		alwaysShowExitButtonLabel.text = [dict valueForKey:[ApplicationSetting applicationSettingDisplayNameColumnIdentifier]];
		alwaysShowExitButtonLabel.font = [UIFont systemFontOfSize:12.0];
		[cell.contentView addSubview:alwaysShowExitButtonLabel];
		[alwaysShowExitButtonLabel release];
		
		UISwitch *alwaysShowExitButtonSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(195.0, 8.0, 120.0, 26.0)];
		NSUInteger intBoolForAlwaysShowExitButtonSwitch = [(NSNumber*)[dict valueForKey:[ApplicationSetting applicationSettingValueColumnIdentifier]] unsignedIntegerValue];
		
		if (intBoolForAlwaysShowExitButtonSwitch == 1)
			alwaysShowExitButtonSwitch.on = YES;
		else
			alwaysShowExitButtonSwitch.on = NO;
		
		[alwaysShowExitButtonSwitch addTarget:self action:@selector(alwaysShowExitButtonWhenPlayingCardsSwitchValueChanged:) forControlEvents:UIControlEventValueChanged];
		[cell.contentView addSubview:alwaysShowExitButtonSwitch];
		[alwaysShowExitButtonSwitch release];
	}
	else if (indexPath.section == 2 && indexPath.row == 2)
	{
		NSArray *continueWithOppositeSideWhenFlippedArrayOfDicts = [ApplicationSetting findAllReturnNSArrayOfNSDictionariesWithWhereClause:[NSString stringWithFormat:@"WHERE %@ = %@",
																																			[ApplicationSetting applicationSettingTagIdentifierColumnIdentifier],
																																			@"'ContinueWithOppositeSideWhenFlipped'"]];
		NSDictionary *dict = [continueWithOppositeSideWhenFlippedArrayOfDicts objectAtIndex:0];
		
		UILabel *continueWithOppositeSideWhenFlippedLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0, 14.0, 185.0, 15.0)];
		continueWithOppositeSideWhenFlippedLabel.textAlignment = UITextAlignmentLeft;
		continueWithOppositeSideWhenFlippedLabel.text = [dict valueForKey:[ApplicationSetting applicationSettingDisplayNameColumnIdentifier]];
		continueWithOppositeSideWhenFlippedLabel.font = [UIFont systemFontOfSize:12.0];
		[cell.contentView addSubview:continueWithOppositeSideWhenFlippedLabel];
		[continueWithOppositeSideWhenFlippedLabel release];
		
		UISwitch *continueWithOppositeSideWhenFlippedSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(195.0, 8.0, 120.0, 26.0)];
		NSUInteger intBoolForContinueWithOppositeSideWhenFlippedSwitch = [(NSNumber*)[dict valueForKey:[ApplicationSetting applicationSettingValueColumnIdentifier]] unsignedIntegerValue];
		
		if (intBoolForContinueWithOppositeSideWhenFlippedSwitch == 1)
			continueWithOppositeSideWhenFlippedSwitch.on = YES;
		else
			continueWithOppositeSideWhenFlippedSwitch.on = NO;
		
		[continueWithOppositeSideWhenFlippedSwitch addTarget:self action:@selector(continueWithOppositeSideWhenFlippedSwitchValueChanged:) forControlEvents:UIControlEventValueChanged];
		[cell.contentView addSubview:continueWithOppositeSideWhenFlippedSwitch];
		[continueWithOppositeSideWhenFlippedSwitch release];
	}
	
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{		
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
