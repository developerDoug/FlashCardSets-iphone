//
//  DeckPlayScreenViewController.m
//  FlashNotes
//

#import "DeckPlayScreenViewController.h"
#import "ApplicationSetting.h"
#import "Card.h"
#import "CardLayer.h"
#import "ExitButton.h"
#import "NoClipModalView.h"
#import "DebugOutput.h"
#import "Common.h"
#import "FlashCardSetsAppDelegate.h"

@interface CCFlipYUpOver : CCFlipYTransition
+ (id)transitionWithDuration:(ccTime)t scene:(CCScene*)s;
@end

@implementation CCFlipYUpOver
+ (id)transitionWithDuration:(ccTime)t scene:(CCScene*)s {
	return [self transitionWithDuration:t scene:s orientation:kOrientationUpOver];
}
@end

#define TRANSITION_DURATION (.4f)

static NSString *transitions[] = {
	@"CCSlideInLTransition",
	@"CCSlideInRTransition",
	@"CCFlipYUpOver"
};

Class nextTransition()
{
	Class c = NSClassFromString(transitions[1]);
	return c;
}

Class backTransition()
{
	Class c = NSClassFromString(transitions[0]);
	return c;
}

Class flipTransition()
{
	Class c = NSClassFromString(transitions[2]);
	return c;
}

@implementation DeckPlayScreenViewController

@synthesize cardList;

- (void)dealloc 
{
	[self.cardList release];
    [super dealloc];
}

- (void)viewDidUnload 
{
	self.cardList = nil;
	[super viewDidUnload];
}

/*
// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
    }
    return self;
}
*/

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView 
{
}
*/

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
//- (void)viewDidLoad 
//{
//   [super viewDidLoad];
//}

- (void)viewDidAppear:(BOOL)animated
{	
	[[CCDirector sharedDirector] resume];
	
	cardIndex = 0;
	
	if ([self.cardList count] > 0)
	{
		NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
		
		isFrontDisplayed = [defaults boolForKey:@"DisplayFrontCard"];
		continueWithOppositeSideWhenFlipped = [defaults boolForKey:@"ContinueWithOppositeSideWhenFlipped"];
		shouldShowExitButton = [defaults boolForKey:@"AlwaysShowExitButtonWhenPlayingCards"];
		NSDictionary *dict = [self.cardList objectAtIndex:cardIndex];
		
		[[CCDirector sharedDirector] setDeviceOrientation:CCDeviceOrientationLandscapeLeft];
		[[CCDirector sharedDirector] attachInView:[self view]];
		
		CCScene *scene = [[CCScene alloc] init];
		CardLayer *layer = [CardLayer node]; 
		[layer setWithTarget:self 
				withPrevious:@selector(previousCard:) 
					withNext:@selector(nextCard:) 
				withBackside:@selector(backside:) 
					withExit:@selector(exit:) 
		shouldShowExitButton:shouldShowExitButton];
		
		hasCardBeenFlipped = NO;
		
		if (isFrontDisplayed)
		{
			[layer setTextForLabel:[dict valueForKey:[Card frontSideColumnIdentifier]]];
		}
		else
		{
			[layer setTextForLabel:[dict valueForKey:[Card backSideColumnIdentifier]]];
		}
		[scene addChild:layer];	
		[[CCDirector sharedDirector] runWithScene:scene];
	}
	else
	{
		[self dismissModalViewControllerAnimated:YES];
	}
	
	[super viewDidAppear:animated];
}

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation 
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationLandscapeLeft);
}
*/

- (void) viewDidDisappear:(BOOL)animated
{
	[[CCDirector sharedDirector] setDeviceOrientation:CCDeviceOrientationPortrait];
	[[CCDirector sharedDirector] end];
	[[CCDirector sharedDirector] pause];
	
	
	[super viewDidDisappear:animated];
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
	[[CCTextureCache sharedTextureCache] removeAllTextures];
}

#pragma mark - Custom Methods

- (void)previousCard:(id)sender
{
	if ([self hasPreviousCard])
	{
		cardIndex--;
		NSDictionary *dict = [self.cardList objectAtIndex:cardIndex];
		Class transition = backTransition();	
		
		hasCardBeenFlipped = NO;
		
		CCScene *scene = [CCScene node];
		CardLayer *layer = [CardLayer node]; 
		[layer setWithTarget:self 
				withPrevious:@selector(previousCard:) 
					withNext:@selector(nextCard:) 
				withBackside:@selector(backside:) 
					withExit:@selector(exit:) 
		shouldShowExitButton:shouldShowExitButton];
		
		if (isFrontDisplayed)
		{
			[layer setTextForLabel:[dict valueForKey:[Card frontSideColumnIdentifier]]];
		}
		else
		{
			[layer setTextForLabel:[dict valueForKey:[Card backSideColumnIdentifier]]];
		}
		[scene addChild:layer];
		[[CCDirector sharedDirector] replaceScene:[transition transitionWithDuration:TRANSITION_DURATION scene:scene]];
	}
}

- (void)nextCard:(id)sender
{
	if ([self hasNextCard])
	{
		cardIndex++;
		NSDictionary *dict = [self.cardList objectAtIndex:cardIndex];
		Class transition = nextTransition();
		
		hasCardBeenFlipped = NO;
		
		CCScene *scene = [CCScene node];
		CardLayer *layer = [CardLayer node]; 
		[layer setWithTarget:self 
				withPrevious:@selector(previousCard:) 
					withNext:@selector(nextCard:) 
				withBackside:@selector(backside:) 
					withExit:@selector(exit:) 
		shouldShowExitButton:shouldShowExitButton];

		if (isFrontDisplayed)
		{
			[layer setTextForLabel:[dict valueForKey:[Card frontSideColumnIdentifier]]];
		}
		else
		{
			[layer setTextForLabel:[dict valueForKey:[Card backSideColumnIdentifier]]];
		}
		[scene addChild:layer];
		[[CCDirector sharedDirector] replaceScene:[transition transitionWithDuration:TRANSITION_DURATION scene:scene]];
	}
}

- (void)backside:(id)sender
{	
	NSDictionary *dict = [self.cardList objectAtIndex:cardIndex];
	Class transition = flipTransition();
	
	CCScene *scene = [CCScene node];
	CardLayer *layer = [CardLayer node]; 
	[layer setWithTarget:self 
			withPrevious:@selector(previousCard:) 
				withNext:@selector(nextCard:) 
			withBackside:@selector(backside:) 
				withExit:@selector(exit:) 
	shouldShowExitButton:shouldShowExitButton];
	
	if (isFrontDisplayed)
	{
		if (!hasCardBeenFlipped)
		{
			[layer setTextForLabel:[dict valueForKey:[Card backSideColumnIdentifier]]];
			hasCardBeenFlipped = YES;
		}
		else
		{
			[layer setTextForLabel:[dict valueForKey:[Card frontSideColumnIdentifier]]];
			hasCardBeenFlipped = NO;
		}
		
	}
	else 
	{
		if (!hasCardBeenFlipped)
		{
			[layer setTextForLabel:[dict valueForKey:[Card frontSideColumnIdentifier]]];
			hasCardBeenFlipped = YES;
		}
		else
		{
			[layer setTextForLabel:[dict valueForKey:[Card backSideColumnIdentifier]]];
			hasCardBeenFlipped = NO;
		}
		
	}
	
	if (continueWithOppositeSideWhenFlipped)
	{
		if (isFrontDisplayed)
		{
			isFrontDisplayed = NO;
			hasCardBeenFlipped = NO;
		}
		else
		{
			isFrontDisplayed = YES;
			hasCardBeenFlipped = NO;
		}
	}
	
	[scene addChild:layer];	
	[[CCDirector sharedDirector] replaceScene:[transition transitionWithDuration:TRANSITION_DURATION scene:scene]];
}

- (void)exit:(id)sender
{
	[self dismissModalViewControllerAnimated:YES];
//	[controllerCleanupTarget performSelector:@selector(cleanUpDeckPlayController:) withObject:self afterDelay:0.0];
}

- (BOOL)hasPreviousCard
{
	return (cardIndex > 0);
}

- (BOOL)hasNextCard
{
	return (cardIndex+1 < [self.cardList count]);
}

- (void)setDMControllerCleanupTarget:(id<DMControllerCleanup>)target
{
	controllerCleanupTarget = target;
}


@end
