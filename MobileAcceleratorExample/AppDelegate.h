//
//  AppDelegate.h
//  MobileAcceleratorExample
//
//  Created by Brian Salomon on 9/16/15.
//  Copyright © 2015 Akamai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>


@protocol AkaMapProtocol;

static NSString * const registrationUpdate = @"registrationUpdate";

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) id<AkaMapProtocol> akaService;

@end

static inline AppDelegate *appDelegate()
{
    return (AppDelegate *)[UIApplication sharedApplication].delegate;
}
