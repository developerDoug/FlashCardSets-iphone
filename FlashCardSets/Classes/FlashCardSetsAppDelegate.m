//
//  FlashCardSetsAppDelegate.m
//  FlashCardSets
//
//  Created by Doug Mason on 8/5/10.
//  Copyright Code Monkeys 2010. All rights reserved.
//

#import "FlashCardSetsAppDelegate.h"
#import "cocos2d.h"
#import "FlashNotesDatabase.h"
#import "FavoriteListViewController.h"

@implementation FlashCardSetsAppDelegate

@synthesize window;
@synthesize tabBarController;

- (void) applicationDidFinishLaunching:(UIApplication*)application
{ 
	[[FlashNotesDatabase sharedLanguageCardsDatabase] runMigrations];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showModal:) name:kShowModal object:nil];
	[window addSubview:[tabBarController view]];
    [window makeKeyAndVisible];
}


- (void)applicationWillResignActive:(UIApplication *)application {
	[[CCDirector sharedDirector] pause];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
	[[CCDirector sharedDirector] resume];
}

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
	[[CCDirector sharedDirector] purgeCachedData];
}

-(void) applicationDidEnterBackground:(UIApplication*)application {
	[[CCDirector sharedDirector] stopAnimation];
}

-(void) applicationWillEnterForeground:(UIApplication*)application {
	[[CCDirector sharedDirector] startAnimation];
}

- (void)applicationWillTerminate:(UIApplication *)application {
	[[CCDirector sharedDirector] end];
}

- (void)applicationSignificantTimeChange:(UIApplication *)application {
	[[CCDirector sharedDirector] setNextDeltaTimeZero:YES];
}

- (void)dealloc {
	[[CCDirector sharedDirector] release];
	[tabBarController release];
	[window release];
	[super dealloc];
}

- (void)showModal:(NSNotification *)notification
{
	UIView *view = (UIView *)[notification object];
	UIWindow *mainWindow = (((FlashCardSetsAppDelegate *)[UIApplication sharedApplication].delegate).window);
	
	CGPoint middleCenter = view.center;
	CGSize offSize = [UIScreen mainScreen].bounds.size;
	CGPoint offScreenCenter = CGPointMake(offSize.width / 2.0, offSize.height * 1.5);
	view.center = offScreenCenter;
	[mainWindow addSubview:view];
	
	// Show it with a transition effect
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:0.7]; // animation duration in seconds
	view.center = middleCenter;
	[UIView commitAnimations];
}

- (void)hideModal:(UIView *)view
{
	CGSize offSize = [UIScreen mainScreen].bounds.size;
	CGPoint offScreenCenter = CGPointMake(offSize.width / 2.0, offSize.height * 1.5);
	[UIView beginAnimations:nil context:view];
	[UIView setAnimationDuration:0.7];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(hideModalEnded:finished:context:)];
	view.center = offScreenCenter;
	[UIView commitAnimations];
}

- (void)hideModalEnded:(NSString *)animationId finished:(NSNumber *)finished context:(void *)context
{
	UIView *view = (UIView *)context;
	[view removeFromSuperview];
}

@end
