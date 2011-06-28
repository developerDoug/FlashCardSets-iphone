//
//  Cards.h
//  LangFlashCards
//
//  Created by Doug Mason on 12/16/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "CDLModel.h"
#import "Constants.h"

@interface Card : CDLModel {
	NSUInteger cardId;
	NSString *frontSide;
	NSString *backSide;
	NSUInteger foreignKeyCategoryId;
}

@property (nonatomic) NSUInteger cardId;
@property (nonatomic, retain) NSString *frontSide;
@property (nonatomic, retain) NSString *backSide;
@property (nonatomic) NSUInteger foreignKeyCategoryId;

+ (NSString *)tableIdentifier;
+ (NSString *)primaryKeyIdentifier;
+ (NSString *)frontSideColumnIdentifier;
+ (NSString *)backSideColumnIdentifier;
+ (NSString *)foreignKeyCategoryIdColumnIdentifier;

- (void)save;
- (void)remove;

@end
