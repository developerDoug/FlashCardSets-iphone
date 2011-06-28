
//
//  Button.h
//  StickWars - Siege
//
//  Created by EricH on 8/3/09.
//

#import "cocos2d.h"

@interface Button : CCMenu {
}
+ (id)buttonWithText:(NSString*)text atPosition:(CGPoint)position target:(id)target selector:(SEL)selector;
+ (id)buttonWithText:(NSString*)text atPosition:(CGPoint)position target:(id)target selector:(SEL)selector withNormalButtonImageFile:(NSString*)normalButtonFile withSelectedButtonImageFile:(NSString*)selectedButtonFile color:(ccColor3B)color;
+ (id)buttonWithImage:(NSString*)file atPosition:(CGPoint)position target:(id)target selector:(SEL)selector;
+ (id)buttonWithTarget:(id)target selector:(SEL)selector atPosition:(CGPoint)position withNormalButtonImageFile:(NSString*)normalButtonFile withSelectedButtonImageFile:(NSString*)selectedButtonFile;
@end

@interface ButtonItem : CCMenuItem {
	CCSprite *back;
	CCSprite *backPressed;
}
+ (id)buttonWithText:(NSString*)text target:(id)target selector:(SEL)selector;
+ (id)buttonWithText:(NSString*)text target:(id)target selector:(SEL)selector withNormalButtonImageFile:(NSString*)normalButtonFile withSelectedButtonImageFile:(NSString*)selectedButtonFile color:(ccColor3B)color;
+ (id)buttonWithImage:(NSString*)file target:(id)target selector:(SEL)selector;
+ (id)buttonWithTarget:(id)target selector:(SEL)selector withNormalButtonImageFile:(NSString*)normalButtonFile withSelectedButtonImageFile:(NSString*)selectedButtonFile;
- (id)initWithText:(NSString*)text target:(id)target selector:(SEL)selector;
- (id)initWithText:(NSString*)text target:(id)target selector:(SEL)selector withNormalButtonImageFile:(NSString*)normalButtonFile withSelectedButtonImageFile:(NSString*)selectedButtonFile color:(ccColor3B)color;
- (id)initWithImage:(NSString*)file target:(id)target selector:(SEL)selector;
- (id)initWithTarget:(id)target selector:(SEL)selector withNormalButtonImageFile:(NSString*)normalButtonFile withSelectedButtonImageFile:(NSString*)selectedButtonFile;
@end
