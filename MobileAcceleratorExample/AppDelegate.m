//
//  AppDelegate.m
//  MobileAcceleratorExample
//
//  Created by Brian Salomon on 9/16/15.
//  Copyright © 2015 Akamai. All rights reserved.
//

#import <AkaCommon/AkaCommon.h>
#import <AkaMap/AkaMap.h>

#import "AppDelegate.h"

@interface AppDelegate () <VocServiceDelegate>

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
	[[UIApplication sharedApplication] registerForRemoteNotifications];

	AkaCommon *akaCommon = [AkaCommon shared];
	akaCommon.debugConsoleEnabled = YES;
	[AkaCommon configure];

	self.akaService = [AkaMap shared];

    // example one-time event log
    [self.akaService logEvent:@"APP_LAUNCHED"];

    // example timed event log
	NSString *eventName = @"Sample Event";
    [self.akaService startEvent:eventName];
	// perform actions to time between startEvent and stopEvent
	[self.akaService stopEvent:eventName];

    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
}

- (void)applicationWillTerminate:(UIApplication *)application {
}


#pragma mark Push Notifications

- (void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken
{
	NSLog(@"Device Token: %@", deviceToken);
}

- (void)application:(UIApplication*)application didFailToRegisterForRemoteNotificationsWithError:(NSError*)error
{
	NSLog(@"Failed to get push token. Error: %@", error);
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult result))completionHandler
{
	AkaCommon *akaCommon = [AkaCommon shared];
	BOOL sdkHandled = [akaCommon didReceiveRemoteNotification:userInfo fetchCompletionHandler:completionHandler];
	if (sdkHandled) {
		NSLog(@"AkaCommon will handle notification & call completion.");
	} else {
		NSLog(@"AkaCommon ignored notification.  App should handle & call completion.");
		if (completionHandler) {
			completionHandler(UIBackgroundFetchResultNoData);
		}
	}
}

- (void)application:(UIApplication *)application handleActionWithIdentifier:(NSString *)identifier forRemoteNotification:(NSDictionary *)userInfo completionHandler:(void(^)())completionHandler
{
	NSLog(@"Remote notification with identifier: %@, payload: %@", identifier, userInfo);

	[self application:application didReceiveRemoteNotification:userInfo fetchCompletionHandler:completionHandler];
}


@end
