//
//  DeckListViewController.h
//  FlashNotes
//

#import <UIKit/UIKit.h>
#import "iAd/ADBannerView.h"
#import "Constants.h"

@class Deck;
@class Favorite;
@class DeckSelectionScreenViewController;

@interface DeckListViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate, ADBannerViewDelegate> {
	UITableView *deckList;
	NSArray *deckListData;
	
	DeckSelectionScreenViewController *childController;
	
	UIView *m_contentView;
	id m_adBannerView;
	BOOL m_adBannerViewIsVisible;
	
}

@property (nonatomic, retain) IBOutlet UIView *contentView;
@property (nonatomic, retain) id adBannerView;
@property (nonatomic) BOOL adBannerViewIsVisible;

@property (nonatomic, retain) IBOutlet UITableView *deckList;
@property (nonatomic, retain) NSArray *deckListData;
- (IBAction)addDeck:(id)sender;
- (void)updateTableView;
@end
