//
//  ExitButton.h
//  FlashNotes
//
//  Created by Douglas Mason on 12/28/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "cocos2d.h"

@interface ExitButton : CCMenu {}
+ (id)buttonAtPosition:(CGPoint)position taret:(id)target selector:(SEL)selector;
@end

@interface ExitButtonItem : CCMenuItem {
	CCSprite *back;
	CCSprite *backPressed;
}
+ (id)buttonWithTarget:(id)target selector:(SEL)selector;
- (id)initButtonWithTarget:(id)target selector:(SEL)selector;
@end
