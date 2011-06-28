//
//  AlertTableView.m
//  FlashNotes
//
//  Created by Douglas Mason on 12/21/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "AlertTableView.h"
#import "Deck.h"
#import "Card.h"
#import "DecksCardsJoin.h"

@implementation AlertTableView

- (void)dealloc
{
	tableView = nil;
	[super dealloc];
}

- (id)initWithTitle:(NSString *)title
  tableViewDelegate:(id<UITableViewDelegate>)tableDelegate 
tableViewDatasource:(id<UITableViewDataSource>)tableDatasource
 tableViewTagNumber:(int)tableTagNumber
{
	NSMutableString *messageString = [NSMutableString stringWithString:@"\n"];
	tableHeight = 0;
	
	//NSArray *decksData = [self loadDecksData];
	
	//if (count < 6)
	//{
	//	for (int i = 0; i < [decksData count]; i++)
	//	{
	//		[messageString appendString:@"\n\n"];
	//		tableHeight += 46;
	//	}
	//}
	//else
	//{
		[messageString appendString:@"\n\n\n\n\n\n\n\n\n"];
		tableHeight = 207;
	//}
	
	self = [super initWithTitle:title message:messageString delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
	if (self != nil)
	{
		[self prepareWithTableDelegate:tableDelegate andTableDatasource:tableDatasource tableViewTagNumber:tableTagNumber];	
	}
	
	return self;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if (buttonIndex == [alertView cancelButtonIndex])
	{
		[self dismissWithClickedButtonIndex:buttonIndex animated:YES];
	}
}

- (void)prepareWithTableDelegate:(id<UITableViewDelegate>)tableDelegate andTableDatasource:(id<UITableViewDataSource>)tableDatasource tableViewTagNumber:(int)tableTagNumber
{
	tableView = [[UITableView alloc] initWithFrame:CGRectMake(11, 50, 261, tableHeight) style:UITableViewStylePlain];
	
	tableView.tag = tableTagNumber;
	tableView.delegate = tableDelegate;
	tableView.dataSource = tableDatasource;
	[self addSubview:tableView];
	
	UIImageView *imgView = [[[UIImageView alloc] initWithFrame:CGRectMake(11, 50, 261, 4)] autorelease];
	imgView.image = [UIImage imageNamed:@"alertTableView_top.png"];
	[self addSubview:imgView];
	
	imgView = [[[UIImageView alloc] initWithFrame:CGRectMake(11, tableHeight + 46, 261, 4)] autorelease];
	imgView.image = [UIImage imageNamed:@"alertTableView_bottom.png"];
	[self addSubview:imgView];
	
	CGAffineTransform transform = CGAffineTransformMakeTranslation(0.0, 10);
	[self setTransform:transform];
}

@end
