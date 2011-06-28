//
//  CardLayer.m
//  FlashNotes
//
//  Created by Douglas Mason on 12/28/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "CardLayer.h"
#import "ExitButton.h"

@implementation CardLayer

//@synthesize backgroundSprite;

- (void)dealloc
{
	[super dealloc];
}

- (id)init
{
	self = [super init];
	if (self != nil)
	{		
		isTouchEnabled = YES;
		
		CGSize size = [[CCDirector sharedDirector] winSize];
		
		CCSprite *backgroundSprite = [CCSprite spriteWithFile:@"card.png"];
		
		[backgroundSprite setPosition:ccp(size.width/2,size.height/2)];
		[backgroundSprite setTag:0];
		[self addChild:backgroundSprite z:0];
		
		
	}
	return self;
}

- (void)setWithTarget:(id)_target withPrevious:(SEL)_selectorPrevious withNext:(SEL)_selectorNext withBackside:(SEL)_selectorBackside withExit:(SEL)_selectorExit shouldShowExitButton:(BOOL)_shouldShowExitButton
{
	target = _target;
	selectorPrevious = _selectorPrevious;
	selectorNext = _selectorNext;
	selectorBackside = _selectorBackside;
	selectorExit = _selectorExit;
	shouldShowExitButton = _shouldShowExitButton;
	
	exitButton = [ExitButton buttonAtPosition:ccp(40,290) taret:self selector:@selector(exit:)];
	
	if (!shouldShowExitButton)
		exitButton.position = ccp(40,600);
	
	[self addChild:exitButton z:1];
}

- (void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{	
	UITouch *touch = [touches anyObject];
	gestureStartPoint = [touch locationInView:[touch view]];
	
}

- (void)ccTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
	UITouch *touch = [touches anyObject];
	CGPoint currentPosition = [touch locationInView:[touch view]];
	
	CGFloat deltaMinimumGestureLength = fabsf(gestureStartPoint.x - currentPosition.x);
	CGFloat deltaMaximumVariance = fabsf(gestureStartPoint.y - currentPosition.y);
	
	if (deltaMinimumGestureLength >= kMinimumGestureLength && deltaMaximumVariance <= kMaximumVariance)
	{
		// Horizontal swipe detected
		
		// Now determine which direction is the swipe, so that we can either call over previous selector or next selector
		if (gestureStartPoint.x > currentPosition.x)
		{
			// this means that the swipe was toward the left
			// and the next card needs displaying
			// if there is a next card
			[target performSelector:selectorNext];
		}
		
		if (gestureStartPoint.x < currentPosition.x)
		{
			// this means that the swipe was toward the right
			// and the previous card needs displaying
			// if there is a previous card
			[target performSelector:selectorPrevious];
		}
	}
}

- (void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	NSUInteger numTaps = [[touches anyObject] tapCount];
	NSUInteger numTouches = [touches count];
	
	UITouch *touch = [touches anyObject];
	CGPoint currentPosition = [touch locationInView:[touch view]];
	
	// What we are doing here is making sure that the upper left corner of the screen has not been touched. HAS NOT!!!!
	// Because if it was we will show the exit button for a specific period of seconds.
	if (!(currentPosition.x >= 225 && currentPosition.x <= 300) && !(currentPosition.y >= 0 && currentPosition.y <= 75))
	{
		if (numTaps == 1 && numTouches == 1)
		{
			[target performSelector:selectorBackside];
		}
	}
	else
	{
		if (!shouldShowExitButton)
		{
			exitButton.position = ccp(40,290);
			[self performSelector:@selector(moveExitButtonOffScreen:) withObject:nil afterDelay:4];
		}
	}
}

- (void)setTextForLabel:(NSString *)text
{
	if ([self getChildByTag:1] != nil)
		[self removeChild:[self getChildByTag:1] cleanup:YES];
	
	CGSize size = [[CCDirector sharedDirector] winSize];
	
	if ([text length] < 15)
	{
		label = [CCLabel labelWithString:text dimensions:CGSizeMake(290, 235) alignment:UITextAlignmentLeft fontName:@"Helvetica" fontSize:40];
	}
	else if ([text length] > 14 && [text length] < 30)
	{
		label = [CCLabel labelWithString:text dimensions:CGSizeMake(290, 235) alignment:UITextAlignmentLeft fontName:@"Helvetica" fontSize:38];
	}
	else if ([text length] > 29 && [text length] < 45)
	{
		label = [CCLabel labelWithString:text dimensions:CGSizeMake(290, 235) alignment:UITextAlignmentLeft fontName:@"Helvetica" fontSize:36];
	}
	else if ([text length] > 44 && [text length] < 60)
	{
		label = [CCLabel labelWithString:text dimensions:CGSizeMake(290, 235) alignment:UITextAlignmentLeft fontName:@"Helvetica" fontSize:34];
	}
	else if ([text length] > 59 && [text length] < 75)
	{
		label = [CCLabel labelWithString:text dimensions:CGSizeMake(290, 235) alignment:UITextAlignmentLeft fontName:@"Helvetica" fontSize:32];
	}
	else if ([text length] > 74 && [text length] < 90)
	{
		label = [CCLabel labelWithString:text dimensions:CGSizeMake(290, 235) alignment:UITextAlignmentLeft fontName:@"Helvetica" fontSize:30];
	}
	else if ([text length] > 89 && [text length] < 105)
	{
		label = [CCLabel labelWithString:text dimensions:CGSizeMake(290, 235) alignment:UITextAlignmentLeft fontName:@"Helvetica" fontSize:28];
	}
	else if ([text length] > 104 && [text length] < 120)
	{
		label = [CCLabel labelWithString:text dimensions:CGSizeMake(290, 235) alignment:UITextAlignmentLeft fontName:@"Helvetica" fontSize:26];
	}
	else if ([text length] > 119 && [text length] < 135)
	{
		label = [CCLabel labelWithString:text dimensions:CGSizeMake(290, 235) alignment:UITextAlignmentLeft fontName:@"Helvetica" fontSize:24];
	}
	else if ([text length] > 134 && [text length] < 150)
	{
		label = [CCLabel labelWithString:text dimensions:CGSizeMake(290, 235) alignment:UITextAlignmentLeft fontName:@"Helvetica" fontSize:22];
	}
	else if ([text length] > 149 && [text length] < 165)
	{
		label = [CCLabel labelWithString:text dimensions:CGSizeMake(290, 235) alignment:UITextAlignmentLeft fontName:@"Helvetica" fontSize:20];
	}
	else if ([text length] > 164 && [text length] < 180)
	{
		label = [CCLabel labelWithString:text dimensions:CGSizeMake(290, 235) alignment:UITextAlignmentLeft fontName:@"Helvetica" fontSize:18];
	}
	else if ([text length] > 179 && [text length] < 195)
	{
		label = [CCLabel labelWithString:text dimensions:CGSizeMake(290, 235) alignment:UITextAlignmentLeft fontName:@"Helvetica" fontSize:16];
	}
	else if ([text length] > 194 && [text length] < 210)
	{
		label = [CCLabel labelWithString:text dimensions:CGSizeMake(290, 235) alignment:UITextAlignmentLeft fontName:@"Helvetica" fontSize:14];
	}
	else if ([text length] > 209 && [text length] < 225)
	{
		label = [CCLabel labelWithString:text dimensions:CGSizeMake(290, 235) alignment:UITextAlignmentLeft fontName:@"Helvetica" fontSize:12];
	}
	else
	{
		label = [CCLabel labelWithString:text dimensions:CGSizeMake(290, 235) alignment:UITextAlignmentLeft fontName:@"Helvetica" fontSize:10];
	}
	
	[label setColor:ccc3(0, 0, 0)];
	[label setOpacity:255];
	[label setTag:1];
	label.position = ccp(size.width/2, size.height/2);
	[self addChild:label z:0];
}

- (void)exit:(id)sender
{
	[target performSelector:selectorExit];
}

- (void)moveExitButtonOffScreen:(id)sender
{
	exitButton.position = ccp(50,600);
}

@end
