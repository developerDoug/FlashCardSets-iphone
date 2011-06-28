//
//  DownloadDetailViewController.h
//  LanguageFlashCards
//
//  Created by Douglas Mason on 5/12/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "iAd/ADBannerView.h"
#import "DownloadOperationDelegate.h"

@interface DownloadDetailViewController : UIViewController <UIAlertViewDelegate, DownloadOperationDelegate, UITableViewDelegate, UITableViewDataSource, ADBannerViewDelegate>
{
	UITableView					*tableView;
	
	NSString					*titleOfSets;
	NSArray						*terms;
	
	UIActivityIndicatorView		*spinner;
	
	UIView *m_contentView;
	id m_adBannerView;
	BOOL m_adBannerViewIsVisible;
}

@property (nonatomic, retain) IBOutlet UIView *contentView;
@property (nonatomic, retain) id adBannerView;
@property (nonatomic) BOOL adBannerViewIsVisible;


@property (nonatomic, retain) NSString								*titleOfSets;
@property (nonatomic, retain) NSArray								*terms;

@property (nonatomic, retain) IBOutlet	UIActivityIndicatorView		*spinner;
@property (nonatomic, retain) IBOutlet	UITableView					*tableView;

- (void) beginDownload;
- (void) download:(NSString *)nameOfSet;

@end
