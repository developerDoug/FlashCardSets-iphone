//
//  CardCell.h
//  FlashNotes
//
//  Created by Douglas Mason on 12/20/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Constants.h"

@interface CardCell : UITableViewCell {
	UILabel *frontSideDisplayLabel;
	UILabel *backSideDisplayLabel;
	
	UILabel *frontSideLabel;
	UILabel *backSideLabel;
}

@property (nonatomic, retain) UILabel *frontSideDisplayLabel;
@property (nonatomic, retain) UILabel *backSideDisplayLabel;

@property (nonatomic, retain) UILabel *frontSideLabel;
@property (nonatomic, retain) UILabel *backSideLabel;

@end
