//
//  AppSettings.m
//  MobileAcceleratorExample
//
//  Created by Brian Salomon on 2/2/16.
//  Copyright © 2016 Akamai. All rights reserved.
//

#import "AppSettings.h"
#import "AppDelegate.h"
#import <AkaMap/AkaMap.h>

@interface AppSettings ()

@property (nonatomic,strong) NSUserDefaults *userDefaults;

@end


@implementation AppSettings

static NSString * const kSettingsHost           = @"serverHost";
static NSString * const kSettingsLookup         = @"serverLookup";
static NSString * const kSettingsSDKLicense     = @"serverSDKLicense";
static NSString * const kSettingsSDKSegments    = @"serverSDKSegments";
static NSString * const kSettingsWebURL         = @"serverWebURL";


+ (instancetype)sharedInstance
{
    static AppSettings *_sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[AppSettings alloc] init];
        _sharedInstance.userDefaults = [NSUserDefaults standardUserDefaults];
    });

    return _sharedInstance;
}


#pragma mark Read/Write properties -- stored to NSUserDefaults

- (NSString *)serverLicenseKey
{
    NSString *license = [self.userDefaults valueForKey:kSettingsSDKLicense];
    if (! license) {
        license = appDelegate().akaService.config.license;
    }
    return license;
}
- (void)setServerLicenseKey:(NSString *)serverLicenseKey
{
    [self.userDefaults setValue:serverLicenseKey forKey:kSettingsSDKLicense];
    [self.userDefaults synchronize];
}


- (NSArray *)userSegments
{
    NSArray *segments = [self.userDefaults valueForKey:kSettingsSDKSegments];
    if (! segments) {
		segments = @[@"your_SDK_segment_id"];
    }
    return segments;
}
- (void)setUserSegments:(NSArray *)userSegments
{
    [self.userDefaults setValue:userSegments forKey:kSettingsSDKSegments];
    [self.userDefaults synchronize];
}


- (NSString *)webURL
{
    NSString *webURL = [self.userDefaults valueForKey:kSettingsWebURL];
    if (! webURL) {
        webURL = @"http://www.bestbuy.com/";
    }
    return webURL;
}
- (void)setWebURL:(NSString *)webURL
{
    [self.userDefaults setValue:webURL forKey:kSettingsWebURL];
    [self.userDefaults synchronize];
}


@end
