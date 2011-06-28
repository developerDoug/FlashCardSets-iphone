//
//  DownloadOperationDelegate.h
//  LanguageFlashCards
//
//  Created by Douglas Mason on 5/12/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class DownloadOperation;
@protocol DownloadOperationDelegate
- (void) downloadDidFinish:(DownloadOperation *)downloadOp;
- (void) stopSpinner;
@end
