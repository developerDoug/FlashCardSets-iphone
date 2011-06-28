//
//  ExitButton.m
//  FlashNotes
//
//  Created by Douglas Mason on 12/28/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "ExitButton.h"

@implementation ExitButton

+ (id)buttonAtPosition:(CGPoint)position taret:(id)target selector:(SEL)selector
{
	CCMenu *menu = [CCMenu menuWithItems:[ExitButtonItem buttonWithTarget:target selector:selector], nil];
	menu.position = position;
	return menu;
}

@end

@implementation ExitButtonItem

- (void)dealloc 
{
	[back release];
	[backPressed release];
	[super dealloc];
}

+ (id)buttonWithTarget:(id)target selector:(SEL)selector
{
	return [[[self alloc] initButtonWithTarget:target selector:selector] autorelease];
}

- (id)initButtonWithTarget:(id)target selector:(SEL)selector
{
	self = [super initWithTarget:target selector:selector];
	if (self != nil)
	{
		back = [[CCSprite spriteWithFile:@"exit.png"] retain];
		back.anchorPoint = ccp(0,0);
		backPressed = [[CCSprite spriteWithFile:@"exit_p.png"] retain];
		backPressed.anchorPoint = ccp(0,0);
		[self addChild:back];
		
		self.contentSize = back.contentSize;
	}
	return self;
}

- (void)selected {
	[self removeChild:back cleanup:NO];
	[self addChild:backPressed];
	[super selected];
}

- (void)unselected {
	[self removeChild:backPressed cleanup:NO];
	[self addChild:back];
	[super selected];
}

// this prevents double taps
- (void)activate {
	[super activate];
	[self setIsEnabled:NO];
	[self schedule:@selector(resetButton:) interval:0.5];
}

- (void)resetButton:(ccTime)dt {
	[self unschedule:@selector(resetButton:)];
	[self setIsEnabled:YES];
}



@end
