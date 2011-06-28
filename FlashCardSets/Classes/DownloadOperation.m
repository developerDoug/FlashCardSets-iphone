
#import "DownloadOperation.h"
#import "Deck.h"
#import "Card.h"
#import "DecksCardsJoin.h"

@interface DownloadOperation (PrivateMethods)
- (void) begin;
@end

@implementation DownloadOperation

@synthesize titleOfTerms;
@synthesize terms;
@synthesize delegate;

- (id) initWithTitle:(NSString *)title listOfTerms:(NSArray *)list delegate:(id)inDelegate
{
	if (self == [super init])
	{
		self.titleOfTerms = title;
		self.terms = list;
		self.delegate = inDelegate;
	}
	return self;
}

- (void) startDownload
{
	[NSThread detachNewThreadSelector:@selector(begin) toTarget:self withObject:nil];
}

- (void) begin
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	NSArray *decks = [Deck findAll];
	
	for (Deck *deck in decks)
	{
		if ([deck.title isEqualToString:titleOfTerms])
		{
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Can Not Download"
															message:@"Can not download because there are a set of cards with a deck title already in the app"
														   delegate:nil
												  cancelButtonTitle:@"OK"
												  otherButtonTitles:nil];
			[alert show];
			[alert release];
			[self.delegate stopSpinner];
			return;
		}
	}
	
	Deck *newlyAddedDeck = [[Deck alloc] init];
	newlyAddedDeck.title = titleOfTerms;
	newlyAddedDeck.savedInDatabase = NO;
	[newlyAddedDeck save];
	
	NSUInteger deckPrimaryKey = newlyAddedDeck.deckId;
	for (NSArray *array in terms)
	{
		Card *newCard = [[Card alloc] init];
		newCard.frontSide = [array objectAtIndex:1];
		newCard.backSide = [array objectAtIndex:0];
		newCard.foreignKeyCategoryId = 1;
		newCard.savedInDatabase = NO;
		[newCard save];
		
		NSUInteger cardPrimaryKey = newCard.cardId;
		
		DecksCardsJoin *join = [[DecksCardsJoin alloc] init];
		join.foreignKeyDeckId = [NSNumber numberWithUnsignedInteger:deckPrimaryKey];
		join.foreignKeyCardId = [NSNumber numberWithUnsignedInteger:cardPrimaryKey];
		join.savedInDatabase = NO;
		[join save];
		
		[join release];
		[newCard release];
	}
	
	[newlyAddedDeck release];
	
	if (delegate && [delegate respondsToSelector:@selector(downloadDidFinish:)])
	{
		[delegate performSelectorOnMainThread:@selector(downloadDidFinish:) withObject:nil waitUntilDone:NO];
	}
	
	[pool drain];
}

@end
