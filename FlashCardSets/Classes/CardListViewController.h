//
//  CardListViewController.h
//  FlashNotes
//

#import <UIKit/UIKit.h>
#import "iAd/ADBannerView.h"
#import "Constants.h"

@class CardCell;
@class CardEditViewController;
@class DecksCardsJoin;
@class Card;

@interface CardListViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, ADBannerViewDelegate>
{
	UITableView *cardList;
	NSArray *cardListData;
	
	CardEditViewController *cardEditViewController;
	
	NSUInteger foreignKeyDeckId;
	
	BOOL didComeFromDeckSelection;
	
	UIView *m_contentView;
	id m_adBannerView;
	BOOL m_adBannerViewIsVisible;
}

@property (nonatomic, retain) IBOutlet UIView *contentView;
@property (nonatomic, retain) id adBannerView;
@property (nonatomic) BOOL adBannerViewIsVisible;

@property (nonatomic) BOOL didComeFromDeckSelection;
@property (nonatomic, retain) IBOutlet UITableView *cardList;
@property (nonatomic) NSUInteger foreignKeyDeckId;

- (void)loadCardListTableViewData;
- (void)addCard:(id)sender;

@end
