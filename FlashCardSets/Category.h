//
//  Category.h
//  LanguageCards
//
//  Created by Douglas Mason on 1/12/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "CDLModel.h"
#import "Constants.h"

@interface Category : CDLModel 
{
	NSUInteger categoryId;
	NSString *categoryName;
}

@property (nonatomic) NSUInteger categoryId;
@property (nonatomic, retain) NSString *categoryName;

+ (NSString*)tableIdentifier;
+ (NSString*)primaryKeyIdentifier;
+ (NSString*)categoryNameColumnIdentifier;

- (void)save;
- (void)remove;

@end
