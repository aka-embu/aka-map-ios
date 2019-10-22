//
//  URLSessionVC.h
//  MobileAcceleratorExample
//
//  Created by Brian Salomon on 11/13/15.
//  Copyright © 2015 Akamai. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SessionVCDelegate <NSObject>
- (void) loadedSessionSiteName:(NSString*)siteName;
@end

@interface URLSessionVC : UIViewController <NSURLSessionDelegate, NSURLSessionDataDelegate, NSURLSessionTaskDelegate>

@property (nonatomic, strong) NSString *siteName;
@property (nonatomic, strong) NSString *sessionType;
@property (nonatomic, strong) NSURL *url;
@property (nonatomic, weak) id <SessionVCDelegate> sessionDelegate;

@property (nonatomic, strong) IBOutlet UIImageView *imageView;
@property (nonatomic, strong) IBOutlet UILabel *statusLabel;

@end
