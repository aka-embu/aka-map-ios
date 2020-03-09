//
//  AppSettings.h
//  MobileAcceleratorExample
//
//  Created by Brian Salomon on 2/2/16.
//  Copyright © 2016 Akamai. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AppSettings : NSObject

@property (nonatomic,strong) NSString *serverLicenseKey;
@property (nonatomic,strong) NSArray *userSegments;
@property (nonatomic,strong) NSString *webURL;

+ (instancetype) sharedInstance;

@end
