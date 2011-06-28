//
//  CardLayer.h
//  FlashNotes
//
//  Created by Douglas Mason on 12/28/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "Constants.h"

// Define that the minimum distance between both
// x coordinates needs to be 20, for recogonizing 
// a swipe
#define kMinimumGestureLength		20

// Our variance, in terms of distance of y
// work detecting a swipe
#define kMaximumVariance			350

@class ExitButton;

@interface CardLayer : CCLayer {

	id target;
	SEL selectorPrevious;
	SEL selectorNext;
	SEL selectorBackside;
	SEL selectorExit;
	
	BOOL shouldShowExitButton;
	
	CGPoint gestureStartPoint;
	
	CCLabel *label;
	ExitButton *exitButton;
	
	//CCSprite		*backgroundSprite;
}

//@property (nonatomic, retain) CCSprite	*backgroundSprite;

- (void)setWithTarget:(id)_target withPrevious:(SEL)_selectorPrevious withNext:(SEL)_selectorNext withBackside:(SEL)_selectorBackside withExit:(SEL)_selectorExit shouldShowExitButton:(BOOL)_shouldShowExitButton;
- (void)setTextForLabel:(NSString*)text;
- (void)moveExitButtonOffScreen:(id)sender;
- (void)exit:(id)sender;

@end
