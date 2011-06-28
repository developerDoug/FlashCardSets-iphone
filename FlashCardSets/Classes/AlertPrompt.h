//
//  AlertPrompt.h
//  FlashNotes
//
//  Created by Douglas Mason on 12/21/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AlertPrompt : UIAlertView 
{
	UITextField *textField;
	NSString *enteredText;
}

@property (nonatomic, retain) UITextField *textField;
@property (readonly) NSString *enteredText;

- (id) initWithTitle:(NSString *)title message:(NSString *)message delegate:(id)delegate 
  cancelButtonTitle:(NSString *)cancelButtonTitle okButtonTitle:(NSString *)okButtonTitle;

- (id) initWithTitle:(NSString *)title message:(NSString *)message delegate:(id)delegate textFieldText:(NSString *)textFieldText
   cancelButtonTitle:(NSString *)cancelButtonTitle okButtonTitle:(NSString *)okButtonTitle;

@end
