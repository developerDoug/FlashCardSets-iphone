//
//  AlertPrompt.m
//  FlashNotes
//
//  Created by Douglas Mason on 12/21/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "AlertPrompt.h"
#import "CustomMacros.h"

@implementation AlertPrompt
@synthesize textField;
@synthesize enteredText;

- (void)dealloc
{
	[textField release];
	[super dealloc];
}

- (id)initWithTitle:(NSString *)title message:(NSString *)message delegate:(id)delegate cancelButtonTitle:(NSString *)cancelButtonTitle okButtonTitle:(NSString *)okButtonTitle
{
	self = [super initWithTitle:title message:message delegate:delegate cancelButtonTitle:cancelButtonTitle otherButtonTitles:okButtonTitle, nil];
	if (self != nil)
	{
		UITextField *aTextField = [[UITextField alloc] initWithFrame:CGRectMake(12.0, 45.0, 260.0, 25.0)];		
		[aTextField setBackgroundColor:[UIColor whiteColor]];
		[self addSubview:aTextField];																			
		self.textField = aTextField;																			
		[aTextField release];																					
		CGAffineTransform translate;																			
		if (kCFCoreFoundationVersionNumber >= kCFCoreFoundationVersionNumber_iPhoneOS_4_0)						
			translate = CGAffineTransformMakeTranslation(0.0, 0.0);												
		else																									
			translate = CGAffineTransformMakeTranslation(0.0, 55.0);											
		[self setTransform:translate];
	}
	return self;
}

- (id) initWithTitle:(NSString *)title message:(NSString *)message delegate:(id)delegate textFieldText:(NSString *)textFieldText
   cancelButtonTitle:(NSString *)cancelButtonTitle okButtonTitle:(NSString *)okButtonTitle
{
	self = [super initWithTitle:title message:message delegate:delegate cancelButtonTitle:cancelButtonTitle otherButtonTitles:okButtonTitle, nil];
	if (self != nil)
	{
		UITextField *aTextField = [[UITextField alloc] initWithFrame:CGRectMake(12.0, 45.0, 260.0, 25.0)];		
		[aTextField setBackgroundColor:[UIColor whiteColor]];	
		[aTextField setText:textFieldText];
		[self addSubview:aTextField];																			
		self.textField = aTextField;																			
		[aTextField release];																					
		CGAffineTransform translate;																			
		if (kCFCoreFoundationVersionNumber >= kCFCoreFoundationVersionNumber_iPhoneOS_4_0)						
			translate = CGAffineTransformMakeTranslation(0.0, 0.0);												
		else																									
			translate = CGAffineTransformMakeTranslation(0.0, 55.0);											
		[self setTransform:translate];
	}
	return self;
}

- (void)show
{
	[textField becomeFirstResponder];
	[super show];
}

- (NSString *)enteredText
{
	return textField.text;
}

@end
