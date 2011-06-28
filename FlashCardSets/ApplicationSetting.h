//
//  ApplicationSetting.h
//  FlashNotes
//
//  Created by Douglas Mason on 12/23/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "CDLModel.h"
#import "Constants.h"

@interface ApplicationSetting : CDLModel 
{
	NSUInteger applicationSettingId;
	NSString *applicationSettingDisplayName;
	NSString *applicationSettingTagIdentifier;
	NSUInteger applicationSettingValue;
}

@property (nonatomic) NSUInteger applicationSettingId;
@property (nonatomic, retain) NSString *applicationSettingDisplayName;
@property (nonatomic, retain) NSString *applicationSettingTagIdentifier;
@property (nonatomic) NSUInteger applicationSettingValue;

+ (NSString *)tableIdentifier; 
+ (NSString *)primaryKeyColumnIdentifier;
+ (NSString *)applicationSettingDisplayNameColumnIdentifier;
+ (NSString *)applicationSettingTagIdentifierColumnIdentifier;
+ (NSString *)applicationSettingValueColumnIdentifier;

- (void)save;
- (void)remove;
@end
