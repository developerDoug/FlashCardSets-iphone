//
//  AlertTableView.h
//  FlashNotes
//
//  Created by Douglas Mason on 12/21/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Card;

@interface AlertTableView : UIAlertView <UIAlertViewDelegate>
{
	UITableView *tableView;
	
	int dataCount;
	int tableHeight;
}

- (id)initWithTitle:(NSString *)title
  tableViewDelegate:(id<UITableViewDelegate>)tableDelegate 
tableViewDatasource:(id<UITableViewDataSource>)tableDatasource
 tableViewTagNumber:(int)tableTagNumber;
- (void)prepareWithTableDelegate:(id<UITableViewDelegate>)tableDelegate andTableDatasource:(id<UITableViewDataSource>)tableDatasource tableViewTagNumber:(int)tableTagNumber;

@end
