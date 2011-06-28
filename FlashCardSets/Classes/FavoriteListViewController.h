//
//  FavoriteListViewController.h
//  FlashNotes
//

#import <UIKit/UIKit.h>
#import "iAd/ADBannerView.h"

@class Deck;
@class Favorite;
@class DeckSelectionScreenViewController;

@interface FavoriteListViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, ADBannerViewDelegate>
{
	UITableView *favoriteDecks;
	NSArray *favoriteDecksData;
	
	DeckSelectionScreenViewController *childController;
	
	UIView *m_contentView;
	id m_adBannerView;
	BOOL m_adBannerViewIsVisible;
}

@property (nonatomic, retain) IBOutlet UIView *contentView;
@property (nonatomic, retain) id adBannerView;
@property (nonatomic) BOOL adBannerViewIsVisible;

@property (nonatomic, retain) IBOutlet UITableView *favoriteDecks;
@property (nonatomic, retain) NSArray *favoriteDecksData;

- (void)updateTableView:(NSNotification *)notification;

@end
