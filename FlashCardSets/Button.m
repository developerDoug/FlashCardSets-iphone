
//
//  Button.m
//  StickWars - Siege
//
//  Created by EricH on 8/3/09.
//

#import "Button.h"

@implementation Button
+ (id)buttonWithText:(NSString*)text atPosition:(CGPoint)position target:(id)target selector:(SEL)selector {
	CCMenu *menu = [CCMenu menuWithItems:[ButtonItem buttonWithText:text target:target selector:selector], nil];
	menu.position = position;
	return menu;
}

+ (id)buttonWithText:(NSString *)text atPosition:(CGPoint)position target:(id)target selector:(SEL)selector withNormalButtonImageFile:(NSString *)normalButtonFile withSelectedButtonImageFile:(NSString *)selectedButtonFile color:(ccColor3B)color
{
	CCMenu *menu = [CCMenu menuWithItems:[ButtonItem buttonWithText:text target:target selector:selector withNormalButtonImageFile:normalButtonFile withSelectedButtonImageFile:selectedButtonFile color:color], nil];
	menu.position = position;
	return menu;
}

+ (id)buttonWithImage:(NSString*)file atPosition:(CGPoint)position target:(id)target selector:(SEL)selector {
	CCMenu *menu = [CCMenu menuWithItems:[ButtonItem buttonWithImage:file target:target selector:selector], nil];
	menu.position = position;
	return menu;
}

+ (id)buttonWithTarget:(id)target selector:(SEL)selector atPosition:(CGPoint)position withNormalButtonImageFile:(NSString*)normalButtonFile withSelectedButtonImageFile:(NSString*)selectedButtonFile
{
	CCMenu *menu = [CCMenu menuWithItems:[ButtonItem buttonWithTarget:target selector:selector withNormalButtonImageFile:normalButtonFile withSelectedButtonImageFile:selectedButtonFile], nil];
	menu.position = position;
	return menu;
}

@end

@implementation ButtonItem
+ (id)buttonWithText:(NSString*)text target:(id)target selector:(SEL)selector {
	return [[[self alloc] initWithText:text target:target selector:selector] autorelease];
}

+ (id)buttonWithText:(NSString *)text target:(id)target selector:(SEL)selector withNormalButtonImageFile:(NSString *)normalButtonFile withSelectedButtonImageFile:(NSString *)selectedButtonFile color:(ccColor3B)color
{
	return [[[self alloc] initWithText:text target:target selector:selector withNormalButtonImageFile:normalButtonFile withSelectedButtonImageFile:selectedButtonFile color:color] autorelease];
}

+ (id)buttonWithImage:(NSString*)file target:(id)target selector:(SEL)selector {
	return [[[self alloc] initWithImage:file target:target selector:selector] autorelease];
}

+ (id)buttonWithTarget:(id)target selector:(SEL)selector withNormalButtonImageFile:(NSString*)normalButtonFile withSelectedButtonImageFile:(NSString*)selectedButtonFile
{
	return [[[self alloc] initWithTarget:target selector:selector withNormalButtonImageFile:normalButtonFile withSelectedButtonImageFile:selectedButtonFile] autorelease];
}

- (id)initWithText:(NSString*)text target:(id)target selector:(SEL)selector {
	self = [super initWithTarget:target selector:selector];
	if(self != nil) {
		back = [[CCSprite spriteWithFile:@"puzzleButton.png"] retain];
		back.anchorPoint = ccp(0,0);
		backPressed = [[CCSprite spriteWithFile:@"puzzleButton_p.png"] retain];
		backPressed.anchorPoint = ccp(0,0);
		[self addChild:back];
		
		self.contentSize = back.contentSize;
		
		CCLabel* textLabel = [CCLabel labelWithString:text fontName:@"Helvetica" fontSize:14];
		textLabel.position = ccp(self.contentSize.width / 2, self.contentSize.height / 2 - 3);
		textLabel.anchorPoint = ccp(0.5, 0.3);
		[textLabel setColor:ccc3(0, 0, 0)];
		[textLabel setOpacity:255];
		[self addChild:textLabel z:1];
	}
	return self;
}

- (id)initWithText:(NSString*)text target:(id)target selector:(SEL)selector withNormalButtonImageFile:(NSString*)normalButtonFile withSelectedButtonImageFile:(NSString*)selectedButtonFile color:(ccColor3B)color
{
	self = [super initWithTarget:target selector:selector];
	if (self != nil)
	{
		back = [[CCSprite spriteWithFile:normalButtonFile] retain];
		back.anchorPoint = ccp(0,0);
		backPressed = [[CCSprite spriteWithFile:selectedButtonFile] retain];
		backPressed.anchorPoint = ccp(0,0);
		[self addChild:back];
		
		self.contentSize = back.contentSize;
		
		CCLabel *textLabel = [CCLabel labelWithString:text fontName:@"Helvetica" fontSize:10];
		textLabel.position = ccp(self.contentSize.width/2,self.contentSize.height/2);
		textLabel.anchorPoint = ccp(0.5,0.3);
		[textLabel setColor:ccc3(color.r, color.g, color.b)];
		[textLabel setOpacity:255];
		[self addChild:textLabel z:1];
	}
	return self;
}

- (id)initWithImage:(NSString*)file target:(id)target selector:(SEL)selector {
	self = [super initWithTarget:target selector:selector];
	if(self != nil) {
		
		back = [[CCSprite spriteWithFile:@"puzzleButton.png"] retain];
		back.anchorPoint = ccp(0,0);
		backPressed = [[CCSprite spriteWithFile:@"puzzleButton_p.png"] retain];
		backPressed.anchorPoint = ccp(0,0);
		[self addChild:back];
		
		self.contentSize = back.contentSize;
		
		CCSprite* image = [CCSprite spriteWithFile:file];
		[self addChild:image z:1];
		image.position = ccp(self.contentSize.width / 2, self.contentSize.height / 2);
	}
	return self;
}

- (id)initWithTarget:(id)target selector:(SEL)selector withNormalButtonImageFile:(NSString*)normalButtonFile withSelectedButtonImageFile:(NSString*)selectedButtonFile
{
	self = [super initWithTarget:target selector:selector];
	if (self != nil)
	{
		back = [[CCSprite spriteWithFile:normalButtonFile] retain];
		back.anchorPoint = ccp(0,0);
		backPressed = [[CCSprite spriteWithFile:selectedButtonFile] retain];
		backPressed.anchorPoint = ccp(0,0);
		[self addChild:back];
		
		self.contentSize = back.contentSize;
	}
	return self;
}

-(void) selected {
	[self removeChild:back cleanup:NO];
	[self addChild:backPressed];
	[super selected];
}

-(void) unselected {
	[self removeChild:backPressed cleanup:NO];
	[self addChild:back];
	[super unselected];
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

- (void)dealloc {
	[back release];
	[backPressed release];
	[super dealloc];
}

@end
