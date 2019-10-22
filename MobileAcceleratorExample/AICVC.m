//
//  AICVC.m
//  MobileAcceleratorExample
//
//  Created by Brian Salomon on 8/8/16.
//  Copyright © 2016 Akamai. All rights reserved.
//

#import "AICVC.h"
#import "AppDelegate.h"
#import <AkaMap/AkaMap.h>
#import <AkaCommon/AkaCommon.h>

@interface AICVC ()

@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) NSMutableData *responseData;
@property (nonatomic, assign) NSInteger responseStatusCode;
@property (nonatomic) NSTimeInterval startTime;
@property (nonatomic) NSTimeInterval loadTimeElapsed;

@end

@implementation AICVC

- (void)viewDidLoad
{
    [super viewDidLoad];

	self.labelURL.text = [NSString stringWithFormat:@"URL: %@", [self.url absoluteString]];

	[self beginDownload];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)beginDownload
{
	self.labelResponseCode.text = @"Response Code: ---";
	self.labelContentSize.text = @"Content Size: --- bytes";
	self.labelStatus.text = @"Status: reloading";

	self.startTime = [NSDate timeIntervalSinceReferenceDate];

	// Create config using Mobile Accelerator SDK
	NSURLSessionConfiguration *sessionConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
	[[AkaCommon shared] interceptSessionsWithConfiguration:sessionConfig];

	NSURLSession *session = [NSURLSession sessionWithConfiguration:sessionConfig delegate:self delegateQueue:nil];

	// Create a request that ignores the system cache. This allows
	// for reloading the image under different network conditions.
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:self.url];
	request.cachePolicy = NSURLRequestReloadIgnoringLocalCacheData;

	NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request];
	[dataTask resume];
	[session finishTasksAndInvalidate];
}

// run on main thread due to UIKit reference
- (void)updateImage
{
    self.image = [UIImage imageWithData:self.responseData];
    [self.imageView setImage:self.image];
}

- (IBAction)tappedReload:(id)sender
{
	self.responseData = nil;
	[self updateImage];

	[self beginDownload];
}

- (IBAction)tappedChangeURL:(id)sender
{
	UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Change URL"
																   message:nil
															preferredStyle:UIAlertControllerStyleAlert];

	[alert addAction:[UIAlertAction actionWithTitle:@"Done" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){

		// set and perform an immediate download of the new URL
		UITextField *textField = alert.textFields[0];
		self.url = [NSURL URLWithString:textField.text];
		self.labelURL.text = [NSString stringWithFormat:@"URL: %@", [self.url absoluteString]];
		[self beginDownload];

	}]];
	[alert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
	[alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
		textField.text = [self.url absoluteString];
	}];
	[self presentViewController:alert animated:YES completion:nil];
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

/**
 * Disable response from being cached.
 */
- (void)URLSession:(NSURLSession *)session
		  dataTask:(NSURLSessionDataTask *)dataTask
 willCacheResponse:(NSCachedURLResponse *)proposedResponse
 completionHandler:(void (^)(NSCachedURLResponse *cachedResponse))completionHandler
{
	completionHandler(NULL);
}

#pragma mark NSURLSessionTaskDelegate

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error
{
    if (error) {
        NSLog(@"NSURLSessionTaskDelegate error: %@", [error localizedDescription]);
        dispatch_async(dispatch_get_main_queue(), ^{
            self.labelStatus.text = [NSString stringWithFormat:@"Status: %@", [error localizedDescription]];
        });
        return;
    }

	NSDate *dateNow = [NSDate date];
    self.loadTimeElapsed = [dateNow timeIntervalSinceReferenceDate] - self.startTime;

    dispatch_async(dispatch_get_main_queue(), ^{
		[self updateImage];

		NSDateFormatter *dateFormat = [NSDateFormatter new];
		[dateFormat setDateFormat:@"hh:mm:ss a"];
		NSString *dateString = [dateFormat stringFromDate:dateNow];

		self.labelResponseCode.text = [NSString stringWithFormat:@"Response Code: %ld", (long)self.responseStatusCode];
		self.labelContentSize.text = [NSString stringWithFormat:@"Content Size: %ld bytes", (unsigned long)self.responseData.length];
		self.labelStatus.text = [NSString stringWithFormat:@"Status: updated %@\nLoad Time: %ld ms",
								 dateString, (long)(self.loadTimeElapsed * 1000.0)];
    });
}

@end
