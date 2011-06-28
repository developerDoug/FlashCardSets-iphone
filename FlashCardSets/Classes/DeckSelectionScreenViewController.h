//
//  DeckPlayScreenViewController.h
//  FlashNotes
//

#import <UIKit/UIKit.h>
#import "iAd/ADBannerView.h"
#import "Constants.h"
#import "DMControllerCleanup.h"

@class Deck;
@class Favorite;
@class DecksCardsJoin;
@class DeckPlayScreenViewController;
@class CardListViewController;

@interface DeckSelectionScreenViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UIActionSheetDelegate, DMControllerCleanup, ADBannerViewDelegate> 
{
	UITableView *deckSelectionList;
	
	Deck *selectedDeck;
	DeckPlayScreenViewController *deckPlayScreenViewController;
	CardListViewController *cardListViewController;
	
	NSArray *categoryData;
	NSArray *filterCategoryData;
	
	UIView *m_contentView;
	id m_adBannerView;
	BOOL m_adBannerViewIsVisible;
}

@property (nonatomic, retain) IBOutlet UIView *contentView;
@property (nonatomic, retain) id adBannerView;
@property (nonatomic) BOOL adBannerViewIsVisible;

@property (nonatomic, retain) IBOutlet DeckPlayScreenViewController *deckPlayScreenViewController;
@property (nonatomic, retain) IBOutlet UITableView *deckSelectionList;
@property (nonatomic, retain) Deck *selectedDeck;

- (void)addToFavorites;
- (void)filterByCategory;
- (void)playDeck;

@end
