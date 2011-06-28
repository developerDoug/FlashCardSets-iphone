//
//  FlashCardSetsAppDelegate.h
//  FlashCardSets
//
//  Created by Doug Mason on 8/5/10.
//  Copyright Code Monkeys 2010. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CDLDatabase;
@class FavoriteListViewController;
@class CCScene;

@interface FlashCardSetsAppDelegate : NSObject <UIApplicationDelegate> {
	UIWindow *window;
	UITabBarController *tabBarController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UITabBarController *tabBarController;

- (void) showModal:(NSNotification *)notification;
- (void) hideModal:(UIView *)view;
- (void) hideModalEnded:(NSString *)animationId finished:(NSNumber *)finished context:(void *)context;


@end
