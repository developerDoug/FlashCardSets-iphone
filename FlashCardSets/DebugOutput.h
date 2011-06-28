//
//  DebugOutput.h
//  FlashNotes
//
//  Created by Douglas Mason on 1/9/10.
//  Copyright 2010 All rights reserved.
//

#import <Foundation/Foundation.h>

// Show full path of filename?
#define DEBUG_SHOW_FULLPATH NO

// Enable debug (NSLog) wrapper code?
#define DEBUG 1

#if DEBUG
#define debug(format,...) [[DebugOutput sharedDebug] output:__FILE__ lineNumber:__LINE__ input:(format), ##__VA_ARGS__]
#else
#define debug(format,...)
#endif

@interface DebugOutput : NSObject {}
+ (DebugOutput*)sharedDebug;
- (void)output:(char*)fileName lineNumber:(int)lineNumber input:(NSString*)input, ...;
@end
