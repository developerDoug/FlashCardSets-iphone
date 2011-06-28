//
//  DeleteCanNotDeckSelection.m
//  FlashNotes
//
//  Created by Douglas Mason on 12/21/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "DeleteCanNotDeckSelection.h"


@implementation DeleteCanNotDeckSelection

- (void)performDeckSelectionTask
{
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Can not delete" message:@"You can not remove this card from this deck because you came through the deck selection." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
	[alert show];
	[alert release];
}

@end
