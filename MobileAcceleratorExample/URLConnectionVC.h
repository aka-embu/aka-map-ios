//
//  URLConnectionVC.h
//  MobileAcceleratorExample
//
//  Created by Brian Salomon on 11/13/15.
//  Copyright © 2015 Akamai. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ConnectionVCDelegate <NSObject>
- (void) loadedConnectionSiteName:(NSString*)siteName;
@end

@interface URLConnectionVC : UIViewController <NSURLConnectionDelegate, NSURLConnectionDataDelegate>

@property (nonatomic, strong) NSString *siteName;
@property (nonatomic, strong) NSURL *url;
@property (nonatomic, weak) id <ConnectionVCDelegate> connectionDelegate;

@property (nonatomic, strong) IBOutlet UIImageView *imageView;
@property (nonatomic, strong) IBOutlet UILabel *statusLabel;

@end
