//
//  CustomTableViewCellDelegate.h
//  FlashNotes
//
//  Created by Douglas Mason on 12/23/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

@protocol CustomSearchDelegate

- (void)resetSearch;
- (void)handleSearchForTerm:(NSString *)searchTerm;
- (NSInteger)countForTableViewNumberOfRowsInSection:(NSInteger)section;
- (NSInteger)numberOfSectionsInTableView;
- (CGFloat)tableViewHeightForHeaderInSection:(NSInteger)section;
- (CGFloat)tableViewForHeightForRowAtIndexPath:(NSIndexPath *)indexPath;
- (UITableViewCell *)tableViewCellForRowAtIndexPath:(NSIndexPath *)indexPath;
- (UIViewController *)tableViewDidSelectRowAtIndexPath:(NSIndexPath *)indexPath;

@end
