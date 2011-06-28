//
//  SettingsViewController.h
//  FlashNotes
//
//  Created by Douglas Mason on 12/23/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Constants.h"

#define kSearchForCardsOrDecksSegmentedControlCardIndex			0
#define kSearchForCardsOrDecksSegmentedControlDeckIndex			1

#define kSortByFrontCardOrBackCardSegmentedControlFrontIndex	0
#define kSortByFrontCardOrBackCardSegmentedControlBackIndex		1

@interface SettingsViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>
{
	UITableView			*settingsTableView;
}

@property (nonatomic, retain) IBOutlet UITableView		*settingsTableView;

- (void)searchCardsOrDecksSegmentedControlValueChanged:(id)sender;
- (void)sortByFrontCardOrBackCardSegmentedControlValueChanged:(id)sender;

- (void)displayFrontCardsSwitchValueChanged:(id)sender;
- (void)alwaysShowExitButtonWhenPlayingCardsSwitchValueChanged:(id)sender;
- (void)continueWithOppositeSideWhenFlippedSwitchValueChanged:(id)sender;

@end
