
#import <UIKit/UIKit.h>
#import "iAd/ADBannerView.h"
#import "Constants.h"

@class DownloadDetailViewController;

@interface DownloadViewController : UIViewController <UITableViewDataSource,
													  UITableViewDelegate,
													  UISearchBarDelegate,
													  UIPickerViewDelegate,
													  UIPickerViewDataSource,
													  UIActionSheetDelegate,
													  ADBannerViewDelegate>
{
	NSArray							*searchData;
	
	UISearchBar						*searchBar;
	UITableView						*tableView;
	
	//	For selecting which way to search
	UIActionSheet					*selectSearchTypeActionSheet;
	UIPickerView					*selectSearchTypePicker;
	NSArray							*selectSearchTypePickerData;
	
	BOOL							isSearchByCreator;
	
	NSMutableData					*receivedData;
	
	UIActivityIndicatorView			*spinner;
	
	DownloadDetailViewController	*detailController;
	
	UIView *m_contentView;
	id m_adBannerView;
	BOOL m_adBannerViewIsVisible;
	
}

@property (nonatomic, retain) IBOutlet UIView *contentView;
@property (nonatomic, retain) id adBannerView;
@property (nonatomic) BOOL adBannerViewIsVisible;


@property (nonatomic, retain) IBOutlet UISearchBar						*searchBar;
@property (nonatomic, retain) IBOutlet UITableView						*tableView;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView			*spinner;
@property (nonatomic, retain) IBOutlet DownloadDetailViewController		*detailController;
@property (nonatomic, retain) NSMutableData								*receivedData;

- (void) searchQuizlet:(NSString *)searchString;
- (void) determineTypeOfSearch;
- (void) searchByButtonClick:(id)sender;
- (void) searchByDoneButtonClick:(id)sender;

@end
