//
//  NoClipModalView.m
//  WordPuzzleGame2
//
//  Created by Douglas Mason on 1/8/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "NoClipModalView.h"


@implementation NoClipModalView


- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        // Initialization code
    }
    return self;
}


- (void)drawRect:(CGRect)rect {
    // Drawing code
}


- (void)dealloc {
    [super dealloc];
}

- (void)didMoveToSuperview
{
	self.superview.clipsToBounds = NO;
}


@end
