//
//  SearchCellForFavoriteDecks.h
//  FlashNotes
//
//  Created by Douglas Mason on 12/23/09.
//  Copyright 2009 All rights reserved.
//
//	For SearchListViewController

#import <Foundation/Foundation.h>
#import "CustomSearchDelegate.h"

@interface SearchCellForDecks : NSObject <CustomSearchDelegate>
{
	UITableView			*searchTableView;
	NSMutableArray		*searchData;
	NSArray				*allSearchData;
}

@property (nonatomic, retain) UITableView			*searchTableView;
@property (nonatomic, retain) NSMutableArray		*searchData;
@property (nonatomic, retain) NSArray				*allSearchData;

- (id)initWithSearchData:(NSMutableArray *)_searchData 
		   allSearchData:(NSArray *)_allSearchData 
			   searchTable:(UITableView *)_searchTableView;

@end
