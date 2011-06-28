//
//  CardCell.m
//  FlashNotes
//
//  Created by Douglas Mason on 12/20/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "CardCell.h"

@implementation CardCell
@synthesize frontSideDisplayLabel;
@synthesize backSideDisplayLabel;
@synthesize frontSideLabel;
@synthesize backSideLabel;

- (void)dealloc 
{
	[self.frontSideDisplayLabel release];
	[self.frontSideLabel release];
	[self.backSideDisplayLabel release];
	[self.backSideLabel release];
    [super dealloc];
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
	if (self != nil) {
        // Initialization code
		
		self.frontSideDisplayLabel = [[UILabel alloc] initWithFrame:CGRectZero];
		[self.frontSideDisplayLabel setMinimumFontSize:TABLE_VIEW_CELL_FONT_SIZE_SMALL_SMALL];
		[self.frontSideDisplayLabel setFont:[UIFont systemFontOfSize:TABLE_VIEW_CELL_FONT_SIZE_SMALL_LARGE]];
		[self.frontSideDisplayLabel setTag:0];
		[self.contentView addSubview:self.frontSideDisplayLabel];
		
		self.frontSideLabel = [[UILabel alloc] initWithFrame:CGRectZero];
		[self.frontSideLabel setMinimumFontSize:TABLE_VIEW_CELL_FONT_SIZE_NORMAL_SMALL];
		[self.frontSideLabel setFont:[UIFont systemFontOfSize:TABLE_VIEW_CELL_FONT_SIZE_NORMAL]];
		[self.frontSideLabel setTag:1];
		[self.contentView addSubview:self.frontSideLabel];
		
		self.backSideDisplayLabel = [[UILabel alloc] initWithFrame:CGRectZero];
		[self.backSideDisplayLabel setMinimumFontSize:TABLE_VIEW_CELL_FONT_SIZE_SMALL_SMALL];
		[self.backSideDisplayLabel setFont:[UIFont systemFontOfSize:TABLE_VIEW_CELL_FONT_SIZE_SMALL_LARGE]];
		[self.backSideDisplayLabel setTag:2];
		[self.contentView addSubview:self.backSideDisplayLabel];
		
		self.backSideLabel = [[UILabel alloc] initWithFrame:CGRectZero];
		[self.backSideLabel setMinimumFontSize:TABLE_VIEW_CELL_FONT_SIZE_NORMAL_SMALL];
		[self.backSideLabel setFont:[UIFont systemFontOfSize:TABLE_VIEW_CELL_FONT_SIZE_NORMAL]];
		[self.backSideLabel setTag:3];
		[self.contentView addSubview:self.backSideLabel];
    }
    return self;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {

    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}





@end
