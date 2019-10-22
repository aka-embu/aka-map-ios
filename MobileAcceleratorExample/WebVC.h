//
//  WebVC.h
//  MobileAcceleratorExample
//
//  Created by Brian Salomon on 9/16/15.
//  Copyright © 2015 Akamai. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol WebVCDelegate <NSObject>
- (void) loadedWebSiteName:(NSString*)siteName;
@end

@interface WebVC : UIViewController <UIWebViewDelegate>

@property (nonatomic, strong) NSString *siteName;
@property (nonatomic, strong) NSURL *url;
@property (nonatomic, weak) id <WebVCDelegate> webDelegate;

@end
