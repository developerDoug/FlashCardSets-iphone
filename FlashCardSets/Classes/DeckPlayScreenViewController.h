//
//  DeckPlayScreenViewController.h
//  FlashNotes
//

#import <UIKit/UIKit.h>
#import "cocos2d.h"
#import "DMControllerCleanup.h"

#define degreesToRadians(x) (M_PI * (x) / 180.0)

@class CardLayer;

@interface DeckPlayScreenViewController : UIViewController 
{
	NSArray						*cardList;
	BOOL						isFrontDisplayed;
	BOOL						continueWithOppositeSideWhenFlipped;
	BOOL						shouldShowExitButton;
	BOOL						hasCardBeenFlipped;
	NSInteger					cardIndex;
	
	id							controllerCleanupTarget;
}

@property (nonatomic, retain)	NSArray				*cardList;

- (void)previousCard:(id)sender;
- (void)nextCard:(id)sender;
- (void)backside:(id)sender;
- (void)exit:(id)sender;

- (void)setDMControllerCleanupTarget:(id<DMControllerCleanup>)target;

- (BOOL)hasPreviousCard;
- (BOOL)hasNextCard;

@end
