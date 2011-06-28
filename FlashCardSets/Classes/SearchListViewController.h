//
//  SearchTabViewController.h
//  FlashNotes
//

#import <UIKit/UIKit.h>
#import "iAd/ADBannerView.h"
#import "CustomSearchDelegate.h"
#import "Constants.h"

@class Deck;
@class DeckSelectionScreenViewController;
@class CardEditViewController;

@interface SearchListViewController : UIViewController <UITableViewDataSource, 
														UITableViewDelegate, 
														UISearchBarDelegate,
														UIPickerViewDelegate,
														UIPickerViewDataSource,
														UIActionSheetDelegate,
														ADBannerViewDelegate> 
{
	UITableView					*searchTableView;
	UISearchBar					*searchBar;
	
	NSMutableArray				*searchData;
	NSArray						*allSearchData;
	
	UIViewController			*childController;
	
	id<CustomSearchDelegate>	searchDelegate;
	
	NSUInteger					searchByDeck;
	
	// For selecting which way to search
	UIActionSheet				*selectSearchTypeActionSheet;
	UIPickerView				*selectSearchTypePicker;
	NSArray						*selectSearchTypePickerData;
	
	UIView *m_contentView;
	id m_adBannerView;
	BOOL m_adBannerViewIsVisible;
}

@property (nonatomic, retain) IBOutlet UIView *contentView;
@property (nonatomic, retain) id adBannerView;
@property (nonatomic) BOOL adBannerViewIsVisible;

@property (nonatomic, retain) IBOutlet	UITableView		*searchTableView;
@property (nonatomic, retain) IBOutlet	UISearchBar		*searchBar;
@property (nonatomic, retain)			NSMutableArray	*searchData;
@property (nonatomic, retain)			NSArray			*allSearchData;

- (void)determineTypeOfSearch;

// For Selecting Which Way to Search - Methods
- (void)searchByButtonClick:(id)sender;
- (void)searchByDoneButtonClick:(id)sender;

@end
