//
//  SearchCellForCards.m
//  FlashNotes
//
//  Created by Douglas Mason on 12/23/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "SearchCellForCards.h"
#import "CardEditViewController.h"
#import "ApplicationSetting.h"
#import "Card.h"
#import "CardCell.h"

@interface SearchCellForCards(PrivateMethods)

- (void)determineIfShouldSearchByFront;

@end

@implementation SearchCellForCards

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
		[self determineIfShouldSearchByFront];
		[self resetSearch];
	}
	return self;
}

- (void)determineIfShouldSearchByFront
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	shouldSearchByFront = [defaults boolForKey:@"DisplayFrontCard"];
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
	
	for (NSDictionary *dict in self.searchData)
	{
		NSString *title = (shouldSearchByFront) ? [dict valueForKey:[Card frontSideColumnIdentifier]] : [dict valueForKey:[Card backSideColumnIdentifier]];
		
		if ([title rangeOfString:searchTerm options:NSCaseInsensitiveSearch].location == NSNotFound)
			[toRemove addObject:dict];
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
	NSDictionary *dict = [searchData objectAtIndex:indexPath.row];
	
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

- (UITableViewCell *)tableViewCellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSDictionary *dict = [searchData objectAtIndex:indexPath.row];
	
	static NSString *cellIdentifier = @"CardCellIdentifier";
	
	CardCell *cell = (CardCell *)[searchTableView dequeueReusableCellWithIdentifier:cellIdentifier];
	
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

- (UIViewController *)tableViewDidSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSDictionary *dict = [searchData objectAtIndex:indexPath.row];
	
	CardEditViewController *cardEditViewController = [[CardEditViewController alloc] initWithNibName:@"CardEditViewController" bundle:nil];
	
	cardEditViewController.title = @"Edit Card";
	
	Card *selectedCard = [[Card alloc] init];
	NSNumber *pk = (NSNumber *)[dict valueForKey:[Card primaryKeyIdentifier]];
	selectedCard.cardId = [pk unsignedIntegerValue];
	selectedCard.frontSide = [dict valueForKey:[Card frontSideColumnIdentifier]];
	selectedCard.backSide = [dict valueForKey:[Card backSideColumnIdentifier]];
	selectedCard.savedInDatabase = YES;
	
	cardEditViewController.card = selectedCard;
	cardEditViewController.didComeFromDeckSelection = NO;
	cardEditViewController.foreignKeyDeckId = 0;
	cardEditViewController.isNewCard = NO;
	
	[selectedCard release];
	
	return [cardEditViewController autorelease];
}

@end
