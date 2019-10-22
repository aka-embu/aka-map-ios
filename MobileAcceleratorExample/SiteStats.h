//
//  SiteStats.h
//  MobileAcceleratorExample
//
//  Created by Brian Salomon on 11/12/15.
//  Copyright © 2015 Akamai. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SiteStats : NSObject

@property (nonatomic, strong) NSString *resourceName;
@property (nonatomic, strong) NSString *connectionType;
@property (nonatomic, strong) NSNumber *loadTimeFromCache;
@property (nonatomic, strong) NSNumber *loadTimeFromNetwork;
@property (nonatomic, strong) NSNumber *dlFiles;
@property (nonatomic, strong) NSNumber *dlBytes;
@property (nonatomic, strong) NSNumber *cacheFiles;
@property (nonatomic, strong) NSNumber *cacheBytes;
@property (nonatomic, strong) NSNumber *skippedFiles;

@end
