//
//  AICVC.h
//  MobileAcceleratorExample
//
//  Created by Brian Salomon on 8/8/16.
//  Copyright © 2016 Akamai. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AICVC : UIViewController <NSURLSessionDelegate, NSURLSessionDataDelegate, NSURLSessionTaskDelegate>

@property (nonatomic, strong) NSURL *url;
@property (nonatomic, strong) IBOutlet UIImageView *imageView;

@property (nonatomic, strong) IBOutlet UILabel *labelURL;
@property (nonatomic, strong) IBOutlet UILabel *labelResponseCode;
@property (nonatomic, strong) IBOutlet UILabel *labelContentSize;
@property (nonatomic, strong) IBOutlet UILabel *labelStatus;

@property (nonatomic, strong) IBOutlet UIButton *buttonReload;
@property (nonatomic, strong) IBOutlet UIButton *buttonChangeURL;

@end
