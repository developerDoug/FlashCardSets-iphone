
#import <Foundation/Foundation.h>
#import "DownloadOperationDelegate.h"

@interface DownloadOperation : NSObject
{
	NSString		*titleOfTerms;
	NSArray			*terms;
	
	id				delegate;
}

@property (retain) NSString				*titleOfTerms;
@property (retain) NSArray				*terms;
@property (assign) id<DownloadOperationDelegate>	delegate;

- (id) initWithTitle:(NSString *)title listOfTerms:(NSArray *)list delegate:(id<DownloadOperationDelegate>)inDelegate;

- (void) startDownload;

@end
