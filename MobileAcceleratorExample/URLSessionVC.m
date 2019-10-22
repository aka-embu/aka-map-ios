//
//  URLSessionVC.m
//  MobileAcceleratorExample
//
//  Created by Brian Salomon on 11/13/15.
//  Copyright © 2015 Akamai. All rights reserved.
//

#import "URLSessionVC.h"
#import "AppDelegate.h"
#import <AkaMap/AkaMap.h>
#import <AkaCommon/AkaCommon.h>

@interface URLSessionVC ()

@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) NSMutableData *responseData;
@property (nonatomic, assign) NSInteger responseStatusCode;
@property (nonatomic) NSTimeInterval startTime;
@property (nonatomic) NSTimeInterval loadTimeElapsed;

@end

@implementation URLSessionVC

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.startTime = [NSDate timeIntervalSinceReferenceDate];

    // tell config to use Mobile Accelerator
    NSURLSessionConfiguration *sessionConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
	[[AkaCommon shared] interceptSessionsWithConfiguration:sessionConfig];

    NSURLSession *session = [NSURLSession sessionWithConfiguration:sessionConfig delegate:self delegateQueue:nil];

    NSMutableURLRequest *request;
    if ([self.sessionType isEqualToString:@"POST"]) {
        request = [NSMutableURLRequest requestWithURL:self.url];

        NSString *postParams = @"item1=value1&item2=value2";
        request.HTTPBody = [postParams dataUsingEncoding:NSUTF8StringEncoding];
        request.HTTPMethod = @"POST";
    } else {
        request = [NSMutableURLRequest requestWithURL:self.url];
    }

    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request];
    [dataTask resume];
	[session finishTasksAndInvalidate];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

// run on main thread due to UIKit reference
- (void) updateImage
{
    self.image = [UIImage imageWithData:self.responseData];
    [self.imageView setImage:self.image];
}

#pragma mark NSURLSessionDelegate

- (void)URLSession:(NSURLSession *)session didBecomeInvalidWithError:(NSError *)error
{
    NSLog(@"NSURLSessionDelegate error: %@", error);
}

#pragma mark NSURLSessionDataDelegate

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition))completionHandler
{
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse*)response;
    if (httpResponse) {
        self.responseStatusCode = httpResponse.statusCode;
    }

    self.responseData = [[NSMutableData alloc] init];
    completionHandler(NSURLSessionResponseAllow);
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data
{
    [self.responseData appendData:data];
}

#pragma mark NSURLSessionTaskDelegate

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error
{
    if (error) {
        NSLog(@"NSURLSessionTaskDelegate error: %@", [error localizedDescription]);
        dispatch_async(dispatch_get_main_queue(), ^{
            self.statusLabel.text = [error localizedDescription];
        });
        return;
    }

    NSTimeInterval timeNow = [NSDate timeIntervalSinceReferenceDate];
    self.loadTimeElapsed = timeNow - self.startTime;

    [self.sessionDelegate loadedSessionSiteName:self.siteName];

    dispatch_async(dispatch_get_main_queue(), ^{

        if ([self.sessionType isEqualToString:@"POST"]) {
            NSString *response = [NSString stringWithUTF8String:(char*)self.responseData.bytes];
            NSLog(@"response: %@", response);
            self.statusLabel.text = response;
        } else {
            [self updateImage];
            self.statusLabel.text = [NSString stringWithFormat:@"Status Code: %ld\nSize: %ld bytes",
                                     (long)self.responseStatusCode, (unsigned long)self.responseData.length];
        }
    });
}

@end
